import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import 'login_state.dart';
import '../data/login_repository.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/errors/exceptions.dart';
import 'package:fahman_app/core/services/fcm_service.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repository;
  LoginCubit({required this.repository}) : super(const LoginState());

  /// Update identifier field and optionally validate
  void updateIdentifier(String value, {bool validateNow = true}) {
    emit(state.copyWith(identifier: value, error: null));
    if (validateNow) validateIdentifier();
  }

  /// Update password field and optionally validate
  void updatePassword(String value, {bool validateNow = true}) {
    emit(state.copyWith(password: value, error: null));
    if (validateNow) validatePassword();
  }

  /// Toggle remember me
  void toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  /// Validate identifier field
  void validateIdentifier() {
    final id = state.identifier.trim();
    String? msg;
    if (id.isEmpty) {
      msg = 'Identifier is required';
    } else if (id.length < 3) {
      msg = 'Identifier too short';
    }
    emit(state.copyWith(identifierError: msg));
  }

  /// Validate password field
  void validatePassword() {
    final pw = state.password;
    String? msg;
    if (pw.isEmpty) {
      msg = 'Password is required';
    } else if (pw.length < 6) {
      msg = 'Password must be at least 6 characters';
    }
    emit(state.copyWith(passwordError: msg));
  }

  /// Validate both fields. Returns true when valid.
  bool validateAll() {
    validateIdentifier();
    validatePassword();
    return state.copyWith().isValid;
  }

  Future<void> login() async {
    // run validation first
    validateIdentifier();
    validatePassword();
    if (!state.copyWith().isValid) return;

    emit(state.copyWith(loading: true, error: null));
    try {
      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await FCMService().getToken();
        print('🔔 [LOGIN] FCM Token: $fcmToken');
      } catch (e) {
        print('Error getting FCM token: $e');
      }

      // Get device name
      String? deviceName;
      try {
        if (Platform.isAndroid) {
          deviceName = 'Android';
        } else if (Platform.isIOS) {
          deviceName = 'iOS';
        } else {
          deviceName = 'Unknown';
        }
        print('📱 [LOGIN] Device Name: $deviceName');
      } catch (e) {
        print('Error getting device name: $e');
        deviceName = 'Unknown';
      }

      print(
        '🚀 [LOGIN] Sending to API - FCM: ${fcmToken != null ? "✓" : "✗"}, Device: $deviceName',
      );

      final res = await repository.login(
        identifier: state.identifier,
        password: state.password,
        rememberMe: state.rememberMe,
        fcmToken: fcmToken,
        deviceName: deviceName,
      );

      // Save authentication data if login successful
      if (res['success'] == true) {
        // server uses keys: accessToken, refreshToken, userID
        final accessToken =
            res['accessToken'] as String? ?? res['token'] as String?;
        final refreshToken = res['refreshToken'] as String?;
        final userId = res['userID'] as String? ?? res['userId'] as String?;
        await AuthSession().setAuthData(
          token: accessToken,
          refreshToken: refreshToken,
          username: res['username'] as String?,
          userId: userId,
        );
      }

      if (res['success'] == true) {
        emit(state.copyWith(loading: false, data: res));
      } else {
        final apiMsg =
            (res['message'] != null && res['message'].toString().isNotEmpty)
            ? res['message'].toString()
            : 'Login failed.';
        emit(state.copyWith(loading: false, data: res, error: apiMsg));
      }
    } on ServerException catch (se) {
      final apiMsg = se.errModel.message.isNotEmpty
          ? se.errModel.message
          : se.errModel.status?.toString() ?? 'Login failed.';
      emit(state.copyWith(loading: false, error: apiMsg));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
