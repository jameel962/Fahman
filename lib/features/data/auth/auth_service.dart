import 'package:fahman_app/features/data/auth/repositories/auth_repository.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';

/// خدمة Auth الرئيسية للاستخدام في التطبيق
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthRepository _repository = AuthRepository();

  // Login
  Future<AuthResult> login({
    required String identifer,
    required String password,
    required bool rememberMe,
  }) async {
    final request = LoginRequest(
      identifer: identifer,
      password: password,
      rememberMe: rememberMe,
    );
    return await _repository.login(request);
  }

  // Register Customer
  Future<AuthResult> registerCustomer({
    required String username,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    List<int>? personalImageBytes,
    String? personalImageFilename,
  }) async {
    final request = RegisterCustomerRequest(
      username: username,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      personalImageBytes: personalImageBytes,
      personalImageFilename: personalImageFilename,
    );
    return await _repository.registerCustomer(request);
  }

  // Logout
  Future<AuthResult> logout(String refreshToken) async {
    return await _repository.logout(refreshToken);
  }

  // Change Password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    return await _repository.changePassword(request);
  }

  // Refresh Token
  Future<AuthResult> refreshToken(String refreshToken) async {
    return await _repository.refreshToken(refreshToken);
  }

  // Validate Username
  Future<ValidateResponse> validateUsername(String username) async {
    return await _repository.validateUsername(username);
  }

  // Validate Email
  Future<ValidateResponse> validateEmail(String email) async {
    return await _repository.validateEmail(email);
  }

  // Validate Phone
  Future<ValidateResponse> validatePhone(String phone) async {
    return await _repository.validatePhone(phone);
  }

  // Verify Auth OTP for registration
  Future<OtpResponse> verifyAuthOtp({
    required String otp,
    required String userId,
  }) async {
    final request = OtpRequest(otp: otp, userId: userId);
    return await _repository.verifyOtp(request);
  }

  // Verify OTP
  Future<OtpResponse> verifyOtp({
    required String otp,
    required String userId,
  }) async {
    final request = OtpRequest(otp: otp, userId: userId);
    return await _repository.verifyOtp(request);
  }

  // Resend Auth OTP
  Future<OtpResponse> resendAuthOtp(String identifier) async {
    final request = ResendOtpRequest(identifier: identifier);
    return await _repository.resendAuthOtp(request);
  }

  // Get User Info
  Future<UserInfo?> getUserInfo() async {
    return await _repository.getUserInfo();
  }

  // Send Auth OTP for registration
  Future<OtpResponse> sendAuthOtp(String identifier) async {
    print('AuthService: Sending Auth OTP for identifier: $identifier');
    final request = ResendOtpRequest(identifier: identifier);
    final result = await _repository.resendAuthOtp(request);
    print(
      'AuthService: Auth OTP result - Success: ${result.success}, Message: ${result.message}',
    );
    return result;
  }

  // Send Password OTP
  Future<OtpResponse> sendPasswordOtp(String identifier) async {
    final request = PasswordResetRequest(identifier: identifier);
    return await _repository.sendPasswordOtp(request);
  }

  // Verify Password OTP
  Future<OtpResponse> verifyPasswordOtp({
    required String otp,
    required String identifer,
  }) async {
    final request = PasswordResetVerifyRequest(otp: otp, identifer: identifer);
    return await _repository.verifyPasswordOtp(request);
  }

  // Reset Password
  Future<AuthResult> resetPassword({
    required String resetToken,
    required String identifier,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = PasswordResetConfirmRequest(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    return await _repository.resetPassword(request, resetToken, identifier);
  }

  // Update User Info
  Future<AuthResult> updateUserInfo({
    String? userName,
    List<int>? profileImageBytes,
    String? profileImageFilename,
  }) async {
    final request = UpdateUserInfoRequest(
      userName: userName,
      profileImageBytes: profileImageBytes,
      profileImageFilename: profileImageFilename,
    );
    return await _repository.updateUserInfo(request);
  }
}
