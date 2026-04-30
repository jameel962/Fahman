import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/forget_password/data/forgot_password_repository.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepository repository;

  ForgotPasswordCubit({required this.repository})
    : super(const ForgotPasswordState());

  // Update identifier (email/phone)
  void updateIdentifier(String value) {
    emit(state.copyWith(identifier: value, errorMessage: null));
  }

  // Update OTP
  void updateOtp(String value) {
    emit(state.copyWith(otp: value, errorMessage: null));
  }

  // Update new password
  void updateNewPassword(String value) {
    emit(state.copyWith(newPassword: value, errorMessage: null));
  }

  // Update confirm password
  void updateConfirmPassword(String value) {
    emit(state.copyWith(confirmPassword: value, errorMessage: null));
  }

  // Step 1: Send OTP
  Future<bool> sendOtp() async {
    // 🔒 Prevent duplicate calls while loading
    if (state.isLoading) return false;

    // Validate email format
    if (state.identifier.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'auth_email_required'));
      return false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(state.identifier.trim())) {
      emit(state.copyWith(errorMessage: 'auth_email_invalid'));
      return false;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await repository.sendOtp(
        identifier: state.identifier.trim(),
      );

      final success = response['success'] as bool? ?? false;
      final apiMessage = response['message'] as String? ?? '';

      if (success) {
        emit(
          state.copyWith(isLoading: false, otpSent: true, errorMessage: null),
        );
        return true;
      } else {
        // Check if the error is "Active OTP exists" - this means we can proceed
        if (apiMessage.toLowerCase().contains('active otp') ||
            apiMessage.toLowerCase().contains('otp exists')) {
          // Allow user to proceed to OTP screen with existing OTP
          emit(
            state.copyWith(isLoading: false, otpSent: true, errorMessage: null),
          );
          return true;
        }

        // For other errors, show error message
        final errorMsg = apiMessage.isNotEmpty
            ? apiMessage
            : 'auth_otp_send_failed';
        emit(
          state.copyWith(
            isLoading: false,
            otpSent: false,
            errorMessage: errorMsg,
          ),
        );
        return false;
      }
    } catch (e) {
      // Try to extract message from error
      String errorMsg = 'auth_otp_send_failed';
      if (e.toString().contains('message:')) {
        errorMsg = e.toString().split('message:').last.trim();
      }
      emit(
        state.copyWith(
          isLoading: false,
          otpSent: false,
          errorMessage: errorMsg,
        ),
      );
      return false;
    }
  }

  // Step 2: Verify OTP
  Future<bool> verifyOtp() async {
    // 🔒 Prevent duplicate calls while loading
    if (state.isLoading) return false;

    if (state.otp.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'auth_otp_required'));
      return false;
    }

    if (state.otp.trim().length != 4) {
      emit(state.copyWith(errorMessage: 'auth_otp_invalid'));
      return false;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await repository.verifyOtp(
        otp: state.otp.trim(),
        identifier: state.identifier.trim(),
      );

      final success = response['success'] as bool? ?? false;

      if (success) {
        // Extract reset token from response
        final resetToken =
            response['resetToken'] as String? ??
            response['token'] as String? ??
            '';

        emit(
          state.copyWith(
            isLoading: false,
            otpVerified: true,
            resetToken: resetToken,
            errorMessage: null,
          ),
        );
        return true;
      } else {
        // Always get error from API message field
        final apiMessage =
            response['message'] as String? ?? 'auth_otp_verify_error';
        emit(
          state.copyWith(
            isLoading: false,
            otpVerified: false,
            errorMessage: apiMessage,
          ),
        );
        return false;
      }
    } catch (e) {
      // Try to extract message from error
      String errorMsg = 'auth_otp_verify_failed';
      if (e.toString().contains('message:')) {
        errorMsg = e.toString().split('message:').last.trim();
      }
      emit(
        state.copyWith(
          isLoading: false,
          otpVerified: false,
          errorMessage: errorMsg,
        ),
      );
      return false;
    }
  }

  // Step 3: Reset Password
  Future<bool> resetPassword() async {
    // 🔒 Prevent duplicate calls while loading
    if (state.isLoading) return false;

    // Validation
    if (state.newPassword.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'auth_new_password_required'));
      return false;
    }

    if (state.newPassword.trim().length < 8) {
      emit(state.copyWith(errorMessage: 'auth_password_weak'));
      return false;
    }

    if (state.newPassword.trim() != state.confirmPassword.trim()) {
      emit(state.copyWith(errorMessage: 'auth_password_mismatch'));
      return false;
    }

    if (state.resetToken.isEmpty) {
      emit(state.copyWith(errorMessage: 'auth_reset_password_failed'));
      return false;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await repository.resetPassword(
        resetToken: state.resetToken,
        identifier: state.identifier.trim(),
        newPassword: state.newPassword.trim(),
        confirmPassword: state.confirmPassword.trim(),
      );

      final success = response['success'] as bool? ?? false;

      if (success) {
        emit(
          state.copyWith(
            isLoading: false,
            passwordReset: true,
            errorMessage: null,
          ),
        );
        return true;
      } else {
        // Always get error from API message field
        final apiMessage =
            response['message'] as String? ?? 'auth_reset_password_failed';
        emit(
          state.copyWith(
            isLoading: false,
            passwordReset: false,
            errorMessage: apiMessage,
          ),
        );
        return false;
      }
    } catch (e) {
      // Try to extract message from error
      String errorMsg = 'auth_reset_password_failed';
      if (e.toString().contains('message:')) {
        errorMsg = e.toString().split('message:').last.trim();
      }
      emit(
        state.copyWith(
          isLoading: false,
          passwordReset: false,
          errorMessage: errorMsg,
        ),
      );
      return false;
    }
  }

  // Reset state
  void reset() {
    emit(const ForgotPasswordState());
  }
}
