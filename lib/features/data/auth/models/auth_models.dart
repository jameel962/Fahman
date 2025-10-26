class LoginRequest {
  final String identifer; // Note: API uses "identifer" not "identifier"
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.identifer,
    required this.password,
    required this.rememberMe,
  });

  Map<String, dynamic> toJson() => {
    'identifer': identifer,
    'password': password,
    'rememberMe': rememberMe,
  };
}

class LoginResponse {
  final String? token;
  final String? refreshToken;
  final String? message;
  final bool success;

  LoginResponse({
    this.token,
    this.refreshToken,
    this.message,
    required this.success,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'],
    refreshToken: json['refreshToken'],
    message: json['message'],
    success: json['success'] ?? false,
  );
}

class RegisterCustomerRequest {
  final String username;
  final String phoneNumber;
  final String email;
  final String password;
  final String confirmPassword;
  final List<int>? personalImageBytes;
  final String? personalImageFilename;

  RegisterCustomerRequest({
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.personalImageBytes,
    this.personalImageFilename,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'phoneNumber': phoneNumber,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
  };
}

class RegisterResponse {
  final String? token;
  final String? message;
  final bool success;

  RegisterResponse({this.token, this.message, required this.success});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        token: json['token'],
        message: json['message'],
        success: json['success'] ?? false,
      );
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});
}

class RefreshTokenResponse {
  final String? token;
  final String? refreshToken;
  final String? message;
  final bool success;

  RefreshTokenResponse({
    this.token,
    this.refreshToken,
    this.message,
    required this.success,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      RefreshTokenResponse(
        token: json['token'],
        refreshToken: json['refreshToken'],
        message: json['message'],
        success: json['success'] ?? false,
      );
}

class ValidateResponse {
  final bool isValid;
  final String? message;

  ValidateResponse({required this.isValid, this.message});

  factory ValidateResponse.fromJson(Map<String, dynamic> json) =>
      ValidateResponse(
        isValid: json['isValid'] ?? false,
        message: json['message'],
      );
}

class OtpRequest {
  final String otp;
  final String userId;

  OtpRequest({required this.otp, required this.userId});

  Map<String, dynamic> toJson() => {'otp': otp, 'userId': userId};
}

class OtpResponse {
  final bool success;
  final String? message;

  OtpResponse({required this.success, this.message});

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      OtpResponse(success: json['success'] ?? false, message: json['message']);
}

class ResendOtpRequest {
  final String identifier;

  ResendOtpRequest({required this.identifier});

  Map<String, dynamic> toJson() => {'identifier': identifier};
}

class UserInfo {
  final String? id;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? role;

  UserInfo({
    this.id,
    this.username,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    profileImage: json['profileImage'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'phoneNumber': phoneNumber,
    'firstName': firstName,
    'lastName': lastName,
    'profileImage': profileImage,
    'role': role,
  };
}

class PasswordResetRequest {
  final String identifier;

  PasswordResetRequest({required this.identifier});

  Map<String, dynamic> toJson() => {'identifier': identifier};
}

class PasswordResetVerifyRequest {
  final String otp;
  final String identifer;

  PasswordResetVerifyRequest({required this.otp, required this.identifer});

  Map<String, dynamic> toJson() => {'otp': otp, 'identifer': identifer};
}

class PasswordResetConfirmRequest {
  final String newPassword;
  final String confirmPassword;

  PasswordResetConfirmRequest({
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class UpdateUserInfoRequest {
  final String? userName;
  final List<int>? profileImageBytes;
  final String? profileImageFilename;

  UpdateUserInfoRequest({
    this.userName,
    this.profileImageBytes,
    this.profileImageFilename,
  });

  Map<String, dynamic> toJson() => {if (userName != null) 'userName': userName};
}

// Common response types
class AuthResult {
  final bool success;
  final String? message;
  final String? token;
  final String? refreshToken;

  AuthResult({
    required this.success,
    this.message,
    this.token,
    this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    success: json['success'] ?? false,
    message: json['message'],
    token: json['token'],
    refreshToken: json['refreshToken'],
  );
}

// Logout request
class LogoutRequest {
  final String refreshToken;

  LogoutRequest({required this.refreshToken});
}

// Refresh token request (duplicate removed - already defined above)

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) => ApiResponse(
    success: json['success'] ?? false,
    message: json['message'],
    data: json['data'] != null && fromJsonT != null
        ? fromJsonT(json['data'])
        : null,
  );
}
