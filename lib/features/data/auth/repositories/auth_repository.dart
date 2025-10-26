import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/features/data/auth/datasources/remote/auth_api.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';
import 'package:fahman_app/core/auth/auth_session.dart';

// AuthResult is now defined in auth_models.dart

class AuthRepository {
  final AuthApi _api;
  AuthRepository({AuthApi? api}) : _api = api ?? AuthApi();

  Future<AuthResult> login(LoginRequest request) async {
    try {
      final Response res = await _api.login(request);

      final data = res.data;
      final token = (data is Map<String, dynamic>)
          ? (data['token'] as String?)
          : null;
      final refreshToken = (data is Map<String, dynamic>)
          ? (data['refreshToken'] as String?)
          : null;

      if (token != null && token.isNotEmpty) {
        final session = AuthSession();
        session.setToken(token);
        if (refreshToken != null) {
          session.setRefreshToken(refreshToken);
        }
        return AuthResult(success: true, token: token);
      }
      return AuthResult(success: false, message: 'auth_no_token_response'.tr());
    } on AuthApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  Future<AuthResult> registerCustomer(RegisterCustomerRequest request) async {
    try {
      print('AuthRepository: Starting register customer for ${request.email}');

      // Validate request data
      if (request.username.isEmpty) {
        return AuthResult(
          success: false,
          message: 'auth_username_required'.tr(),
        );
      }
      if (request.email.isEmpty) {
        return AuthResult(success: false, message: 'auth_email_required'.tr());
      }
      if (request.password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'auth_password_required'.tr(),
        );
      }
      if (request.password != request.confirmPassword) {
        return AuthResult(
          success: false,
          message: 'auth_passwords_not_match'.tr(),
        );
      }

      final Response res = await _api.registerCustomer(request);
      print('AuthRepository: Received response with status: ${res.statusCode}');

      final data = res.data;
      print('AuthRepository: Response data: $data');

      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String?;

        print('AuthRepository: Token: $token');
        print('AuthRepository: RefreshToken: $refreshToken');
        print('AuthRepository: Success: $success');
        print('AuthRepository: Message: $message');

        if (success || token != null) {
          final session = AuthSession();
          if (token != null && token.isNotEmpty) {
            session.setToken(token);
          }
          session.setUsername(request.username);
          if (refreshToken != null) {
            session.setRefreshToken(refreshToken);
          }
          return AuthResult(success: true, token: token, message: message);
        } else {
          // إذا لم تُعد API توكن عند التسجيل، نُخزن الاسم على الأقل.
          AuthSession().setUsername(request.username);
          return AuthResult(
            success: false,
            message: message ?? 'auth_no_token_register'.tr(),
          );
        }
      } else {
        print('AuthRepository: Unexpected response format: $data');
        AuthSession().setUsername(request.username);
        return AuthResult(
          success: false,
          message: 'auth_no_token_register'.tr(),
        );
      }
    } on AuthApiException catch (e) {
      print('AuthRepository: AuthApiException: ${e.message}');
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      print('AuthRepository: Unexpected error: $e');
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Logout
  Future<AuthResult> logout(String refreshToken) async {
    try {
      await _api.logout(refreshToken);

      final session = AuthSession();
      session.clear();
      return AuthResult(success: true, message: 'auth_logout_success'.tr());
    } on AuthApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Change Password
  Future<AuthResult> changePassword(ChangePasswordRequest request) async {
    try {
      await _api.changePassword(request);
      return AuthResult(success: true, message: 'auth_password_changed'.tr());
    } on AuthApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Refresh Token
  Future<AuthResult> refreshToken(String refreshToken) async {
    try {
      final Response res = await _api.refreshToken(refreshToken);
      final data = res.data;
      final token = (data is Map<String, dynamic>)
          ? (data['token'] as String?)
          : null;
      final newRefreshToken = (data is Map<String, dynamic>)
          ? (data['refreshToken'] as String?)
          : null;

      if (token != null && token.isNotEmpty) {
        final session = AuthSession();
        session.setToken(token);
        if (newRefreshToken != null) {
          session.setRefreshToken(newRefreshToken);
        }
        return AuthResult(success: true, token: token);
      }
      return AuthResult(
        success: false,
        message: 'auth_token_update_failed'.tr(),
      );
    } on AuthApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Validate Username
  Future<ValidateResponse> validateUsername(String username) async {
    try {
      final Response res = await _api.validateUsername(username);
      return ValidateResponse.fromJson(res.data);
    } on AuthApiException catch (e) {
      return ValidateResponse(isValid: false, message: e.message);
    } catch (e) {
      return ValidateResponse(
        isValid: false,
        message: 'auth_unexpected_error'.tr(),
      );
    }
  }

  // Validate Email
  Future<ValidateResponse> validateEmail(String email) async {
    try {
      final Response res = await _api.validateEmail(email);
      return ValidateResponse.fromJson(res.data);
    } on AuthApiException catch (e) {
      return ValidateResponse(isValid: false, message: e.message);
    } catch (e) {
      return ValidateResponse(
        isValid: false,
        message: 'auth_unexpected_error'.tr(),
      );
    }
  }

  // Validate Phone
  Future<ValidateResponse> validatePhone(String phone) async {
    try {
      final Response res = await _api.validatePhone(phone);
      return ValidateResponse.fromJson(res.data);
    } on AuthApiException catch (e) {
      return ValidateResponse(isValid: false, message: e.message);
    } catch (e) {
      return ValidateResponse(
        isValid: false,
        message: 'auth_unexpected_error'.tr(),
      );
    }
  }

  // Verify OTP
  Future<OtpResponse> verifyOtp(OtpRequest request) async {
    try {
      final Response res = await _api.verifyOtp(request);
      return OtpResponse.fromJson(res.data);
    } on AuthApiException catch (e) {
      return OtpResponse(success: false, message: e.message);
    } catch (e) {
      return OtpResponse(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Resend Auth OTP
  Future<OtpResponse> resendAuthOtp(ResendOtpRequest request) async {
    try {
      print('AuthRepository: Starting resendAuthOtp for ${request.identifier}');

      final Response res = await _api.resendAuthOtp(request);
      print('AuthRepository: Received response with status: ${res.statusCode}');

      final data = res.data;
      print('AuthRepository: Response data: $data');

      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String?;

        print('AuthRepository: Success: $success');
        print('AuthRepository: Message: $message');

        return OtpResponse(success: success, message: message);
      } else {
        print('AuthRepository: Unexpected response format: $data');
        return OtpResponse(
          success: false,
          message: 'auth_unexpected_error'.tr(),
        );
      }
    } on AuthApiException catch (e) {
      print('AuthRepository: AuthApiException: ${e.message}');
      return OtpResponse(success: false, message: e.message);
    } catch (e) {
      print('AuthRepository: Unexpected error: $e');
      return OtpResponse(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Get User Info
  Future<UserInfo?> getUserInfo() async {
    try {
      final Response res = await _api.getUserInfo();
      return UserInfo.fromJson(res.data);
    } on AuthApiException {
      return null;
    } catch (e) {
      return null;
    }
  }

  // Send Password OTP
  Future<OtpResponse> sendPasswordOtp(PasswordResetRequest request) async {
    try {
      final Response res = await _api.sendPasswordOtp(request);
      return OtpResponse.fromJson(res.data);
    } on AuthApiException catch (e) {
      return OtpResponse(success: false, message: e.message);
    } catch (e) {
      return OtpResponse(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Verify Password OTP
  Future<OtpResponse> verifyPasswordOtp(
    PasswordResetVerifyRequest request,
  ) async {
    try {
      final Response res = await _api.verifyPasswordOtp(request);
      return OtpResponse.fromJson(res.data);
    } on AuthApiException catch (e) {
      return OtpResponse(success: false, message: e.message);
    } catch (e) {
      return OtpResponse(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Reset Password
  Future<AuthResult> resetPassword(
    PasswordResetConfirmRequest request,
    String resetToken,
    String identifier,
  ) async {
    try {
      await _api.resetPassword(request, resetToken, identifier);
      return AuthResult(
        success: true,
        message: 'auth_password_reset_success'.tr(),
      );
    } on AuthApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }

  // Update User Info
  Future<AuthResult> updateUserInfo(UpdateUserInfoRequest request) async {
    try {
      await _api.updateUserInfo(request);
      return AuthResult(success: true, message: 'auth_user_info_updated'.tr());
    } on AuthApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    } catch (e) {
      return AuthResult(success: false, message: 'auth_unexpected_error'.tr());
    }
  }
}
