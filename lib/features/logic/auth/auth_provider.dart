import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/features/data/auth/auth_service.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';
import 'package:fahman_app/core/auth/auth_session.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthSession _session = AuthSession();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  UserInfo? _userInfo;
  bool _isAuthenticated = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize authentication state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = _session.token;
      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
        await _loadUserInfo();
      }
    } catch (e) {
      _errorMessage = 'auth_auth_loading_error'.tr();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({
    required String identifer,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        identifer: identifer,
        password: password,
        rememberMe: rememberMe,
      );

      if (result.success) {
        _isAuthenticated = true;
        await _loadUserInfo();
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_login_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> registerCustomer({
    required String username,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    List<int>? personalImageBytes,
    String? personalImageFilename,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.registerCustomer(
        username: username,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        personalImageBytes: personalImageBytes,
        personalImageFilename: personalImageFilename,
      );

      if (result.success) {
        _isAuthenticated = true;
        await _loadUserInfo();
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_register_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final refreshToken = _session.getRefreshToken();
      if (refreshToken != null) {
        await _authService.logout(refreshToken);
      }

      _session.clear();
      _isAuthenticated = false;
      _userInfo = null;
      return true;
    } catch (e) {
      _errorMessage = 'auth_logout_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result.success) {
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_change_password_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh Token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _session.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final result = await _authService.refreshToken(refreshToken);
      if (result.success) {
        return true;
      } else {
        // If refresh fails, logout user
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Validate Username
  Future<bool> validateUsername(String username) async {
    try {
      final result = await _authService.validateUsername(username);
      return result.isValid;
    } catch (e) {
      return false;
    }
  }

  // Validate Email
  Future<bool> validateEmail(String email) async {
    try {
      final result = await _authService.validateEmail(email);
      return result.isValid;
    } catch (e) {
      return false;
    }
  }

  // Validate Phone
  Future<bool> validatePhone(String phone) async {
    try {
      final result = await _authService.validatePhone(phone);
      return result.isValid;
    } catch (e) {
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({required String otp, required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOtp(otp: otp, userId: userId);
      if (result.success) {
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_otp_verify_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resend Auth OTP
  Future<bool> resendAuthOtp(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resendAuthOtp(identifier);
      if (result.success) {
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_otp_resend_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send Password OTP
  Future<bool> sendPasswordOtp(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.sendPasswordOtp(identifier);
      if (result.success) {
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_otp_send_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify Password OTP
  Future<bool> verifyPasswordOtp({
    required String otp,
    required String identifer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyPasswordOtp(
        otp: otp,
        identifer: identifer,
      );
      if (result.success) {
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_otp_verify_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword({
    required String resetToken,
    required String identifier,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(
        resetToken: resetToken,
        identifier: identifier,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result.success) {
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_reset_password_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update User Info
  Future<bool> updateUserInfo({
    String? userName,
    List<int>? profileImageBytes,
    String? profileImageFilename,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateUserInfo(
        userName: userName,
        profileImageBytes: profileImageBytes,
        profileImageFilename: profileImageFilename,
      );

      if (result.success) {
        await _loadUserInfo(); // Reload user info
        return true;
      } else {
        _errorMessage = result.message ?? 'auth_update_user_failed'.tr();
        return false;
      }
    } catch (e) {
      _errorMessage = 'auth_unexpected_error'.tr();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load User Info
  Future<void> _loadUserInfo() async {
    try {
      _userInfo = await _authService.getUserInfo();
    } catch (e) {
      // User info loading failed, but don't show error to user
      _userInfo = null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user is authenticated
  bool checkAuthStatus() {
    final token = _session.token;
    _isAuthenticated = token != null && token.isNotEmpty;
    return _isAuthenticated;
  }
}
