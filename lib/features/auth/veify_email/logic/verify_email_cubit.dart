import 'package:fahman_app/features/auth/veify_email/data/verify_email_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/networking/errors/exceptions.dart';
import 'package:fahman_app/core/helpers/cache_helper.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/app_logger.dart';
import 'verify_email_state.dart';
import 'package:fahman_app/core/auth/auth_session.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final VerifyEmailRepo _verifyEmailRepo;

  VerifyEmailCubit(this._verifyEmailRepo) : super(const VerifyEmailState());

  void updateOtp(String otp) {
    emit(state.copyWith(otp: otp, error: null));
  }

  Future<bool> verifyOtp({required String userId}) async {
    if (state.otp.length != 4) {
      emit(state.copyWith(error: 'Verification code must be 4 digits.'));
      return false;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final response = await _verifyEmailRepo.verifyOtp(
        otp: state.otp,
        userId: userId,
      );
      if (response['success'] == true) {
        // Save tokens and userID
        final accessToken = response['accessToken'] as String? ?? '';
        final refreshToken = response['refreshToken'] as String? ?? '';
        final returnedUserId = response['userID'] as String? ?? userId;

        // Persist into CacheHelper (existing behavior)
        if (accessToken.isNotEmpty) {
          await CacheHelper().saveData(key: ApiKey.token, value: accessToken);
          AppLogger.d(
            'Saved accessToken to cache (truncated): ${accessToken.substring(0, 16)}...',
          );
        }

        if (refreshToken.isNotEmpty) {
          await CacheHelper().saveData(
            key: ApiKey.refreshToken,
            value: refreshToken,
          );
          AppLogger.d(
            'Saved refreshToken to cache (truncated): ${refreshToken.substring(0, 16)}...',
          );
        }

        if (returnedUserId.isNotEmpty) {
          await CacheHelper().saveData(
            key: ApiKey.userID,
            value: returnedUserId,
          );
          AppLogger.d('Saved userID to cache: $returnedUserId');
        }

        // Also update in-memory AuthSession immediately so subsequent
        // repository calls use the fresh access/refresh tokens.
        try {
          // Lazily import to avoid circular deps in some builds
          // (AuthSession is a small singleton wrapper around SharedPreferences)
          // We call setAuthData which will save and update in-memory values.
          await AuthSession().setAuthData(
            token: accessToken.isNotEmpty ? accessToken : null,
            refreshToken: refreshToken.isNotEmpty ? refreshToken : null,
            userId: returnedUserId.isNotEmpty ? returnedUserId : null,
          );
          AppLogger.d('AuthSession updated with verifyOtp tokens');
        } catch (e, st) {
          AppLogger.w(
            'Failed to update AuthSession from verifyOtp response: $e\n$st',
          );
        }

        emit(state.copyWith(loading: false));
        return true;
      } else {
        emit(state.copyWith(loading: false, error: response['message']));
        return false;
      }
    } on ServerException catch (se) {
      final apiMsg = se.errModel.message.isNotEmpty
          ? se.errModel.message
          : 'Verification failed.';
      emit(state.copyWith(loading: false, error: apiMsg));
      return false;
    } catch (e) {
      emit(
        state.copyWith(loading: false, error: 'An unexpected error occurred.'),
      );
      return false;
    }
  }

  Future<bool> reSendOtp({required String identifier}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final response = await _verifyEmailRepo.reSendOtp(identifier: identifier);
      if (response['success'] == true) {
        emit(state.copyWith(loading: false));
        return true;
      } else {
        emit(state.copyWith(loading: false, error: response['message']));
        return false;
      }
    } on ServerException catch (se) {
      final apiMsg = se.errModel.message.isNotEmpty
          ? se.errModel.message
          : 'Failed to resend OTP.';
      emit(state.copyWith(loading: false, error: apiMsg));
      return false;
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to resend OTP.'));
      return false;
    }
  }
}
