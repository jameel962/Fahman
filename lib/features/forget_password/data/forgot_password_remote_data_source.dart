import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

class ForgotPasswordRemoteDataSource {
  final ApiConsumer api;

  ForgotPasswordRemoteDataSource({required this.api});

  /// Send OTP to email/phone
  Future<Map<String, dynamic>> sendOtp({required String identifier}) async {
    final response = await api.post(
      EndPoints.passwordSendOtp,
      queryParameters: {'Identifier': identifier},
    );
    return response as Map<String, dynamic>;
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String identifier,
  }) async {
    final response = await api.post(
      EndPoints.passwordVerifyOtp,
      queryParameters: {
        'otp': otp,
        'identifer': identifier, // Note: API uses 'identifer' (typo in API)
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String identifier,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await api.post(
      EndPoints.passwordReset,
      queryParameters: {
        'resetToken': resetToken,
        'identifer': identifier, // Note: API uses 'identifer' (typo in API)
      },
      data: {'newPassword': newPassword, 'confirmPassword': confirmPassword},
    );
    return response as Map<String, dynamic>;
  }
}
