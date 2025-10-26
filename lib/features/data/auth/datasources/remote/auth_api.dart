import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/network/dio_client.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';

class AuthApi {
  final Dio _dio;

  AuthApi({Dio? dio}) : _dio = dio ?? DioClient().dio;

  // POST /Auth/login
  Future<Response> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/Auth/login', data: request.toJson());
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Login failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/register/customer
  Future<Response> registerCustomer(RegisterCustomerRequest request) async {
    try {
      final formData = FormData.fromMap({
        'Username': request.username,
        'PhoneNumber': request.phoneNumber,
        'Email': request.email,
        'Password': request.password,
        'ConfirmPassword': request.confirmPassword,
        if (request.personalImageBytes != null &&
            request.personalImageBytes!.isNotEmpty)
          'personalImage': MultipartFile.fromBytes(
            request.personalImageBytes!,
            filename: request.personalImageFilename ?? 'avatar.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
      });

      // Validate required fields
      if (request.username.isEmpty) {
        throw AuthApiException(
          statusCode: 400,
          message: 'Username is required',
        );
      }
      if (request.email.isEmpty) {
        throw AuthApiException(statusCode: 400, message: 'Email is required');
      }
      if (request.password.isEmpty) {
        throw AuthApiException(
          statusCode: 400,
          message: 'Password is required',
        );
      }
      if (request.password != request.confirmPassword) {
        throw AuthApiException(
          statusCode: 400,
          message: 'Passwords do not match',
        );
      }

      print('DIO: Sending register request to /Auth/register/customer');
      print('DIO: Username: ${request.username}');
      print('DIO: Email: ${request.email}');

      final response = await _dio.post(
        '/Auth/register/customer',
        data: formData,
      );

      print('DIO: Register response status: ${response.statusCode}');
      print('DIO: Register response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      print('DIO: Register error: ${e.toString()}');
      print('DIO: Error response: ${e.response?.data}');
      print('DIO: Error status code: ${e.response?.statusCode}');

      final statusCode = e.response?.statusCode;
      String message = 'Register failed';

      if (e.response?.data is Map<String, dynamic>) {
        message =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Register failed';
      } else if (e.message != null) {
        message = e.message!;
      }

      throw AuthApiException(statusCode: statusCode, message: message);
    } catch (e) {
      print('DIO: Unexpected error during register: $e');
      throw AuthApiException(statusCode: null, message: 'Unexpected error: $e');
    }
  }

  // POST /Auth/logout/{refreshToken}
  Future<Response> logout(String refreshToken) async {
    try {
      final response = await _dio.post('/Auth/logout/$refreshToken');
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Logout failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/change-password
  Future<Response> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _dio.post(
        '/Auth/change-password',
        data: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Change password failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/refresh-token/{refreshToken}
  Future<Response> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/Auth/refresh-token/$refreshToken');
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Refresh token failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // GET /Auth/validate-username/{username}
  Future<Response> validateUsername(String username) async {
    try {
      final response = await _dio.get('/Auth/validate-username/$username');
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Username validation failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // GET /Auth/validate-email/{email}
  Future<Response> validateEmail(String email) async {
    try {
      final response = await _dio.get('/Auth/validate-email/$email');
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Email validation failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // GET /Auth/validate-phone/{phone}
  Future<Response> validatePhone(String phone) async {
    try {
      final response = await _dio.get('/Auth/validate-phone/$phone');
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Phone validation failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/verfiyOtp
  Future<Response> verifyOtp(OtpRequest request) async {
    try {
      final response = await _dio.post(
        '/Auth/verfiyOtp',
        queryParameters: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'OTP verification failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/reSendAuth-otp
  Future<Response> resendAuthOtp(ResendOtpRequest request) async {
    try {
      print('DIO: Sending resendAuthOtp request to /Auth/reSendAuth-otp');
      print('DIO: Identifier: ${request.identifier}');

      final response = await _dio.post(
        '/Auth/reSendAuth-otp',
        queryParameters: request.toJson(),
      );

      print('DIO: ResendAuthOtp response status: ${response.statusCode}');
      print('DIO: ResendAuthOtp response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      print('DIO: ResendAuthOtp error: ${e.toString()}');
      print('DIO: Error response: ${e.response?.data}');
      print('DIO: Error status code: ${e.response?.statusCode}');

      final statusCode = e.response?.statusCode;
      String message = 'Resend OTP failed';

      if (e.response?.data is Map<String, dynamic>) {
        message =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Resend OTP failed';
      } else if (e.message != null) {
        message = e.message!;
      }

      throw AuthApiException(statusCode: statusCode, message: message);
    } catch (e) {
      print('DIO: Unexpected error during resendAuthOtp: $e');
      throw AuthApiException(statusCode: null, message: 'Unexpected error: $e');
    }
  }

  // GET /Auth/GetUserInfo
  Future<Response> getUserInfo() async {
    try {
      final response = await _dio.get('/Auth/GetUserInfo');
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Get user info failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/password/send-otp
  Future<Response> sendPasswordOtp(PasswordResetRequest request) async {
    try {
      final response = await _dio.post(
        '/Auth/password/send-otp',
        queryParameters: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Send password OTP failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/password/verify-otp
  Future<Response> verifyPasswordOtp(PasswordResetVerifyRequest request) async {
    try {
      final response = await _dio.post(
        '/Auth/password/verify-otp',
        queryParameters: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Verify password OTP failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // POST /Auth/password/reset
  Future<Response> resetPassword(
    PasswordResetConfirmRequest request,
    String resetToken,
    String identifier,
  ) async {
    try {
      final response = await _dio.post(
        '/Auth/password/reset',
        queryParameters: {'resetToken': resetToken, 'identifier': identifier},
        data: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Reset password failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }

  // PUT /Auth/UpdateUserInfo
  Future<Response> updateUserInfo(UpdateUserInfoRequest request) async {
    try {
      final formData = FormData.fromMap({
        if (request.userName != null) 'UserName': request.userName,
        if (request.profileImageBytes != null &&
            request.profileImageBytes!.isNotEmpty)
          'ProfileImage': MultipartFile.fromBytes(
            request.profileImageBytes!,
            filename: request.profileImageFilename ?? 'profile.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
      });
      final response = await _dio.put('/Auth/UpdateUserInfo', data: formData);
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? 'Update user info failed')
          : e.message ?? 'Network error';
      throw AuthApiException(statusCode: statusCode, message: message);
    }
  }
}

class AuthApiException implements Exception {
  final int? statusCode;
  final String message;
  AuthApiException({this.statusCode, required this.message});
  @override
  String toString() =>
      'AuthApiException(statusCode: $statusCode, message: $message)';
}
