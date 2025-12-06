import 'package:fahman_app/features/forget_password/data/forgot_password_remote_data_source.dart';

class ForgotPasswordRepository {
  final ForgotPasswordRemoteDataSource remoteDataSource;

  ForgotPasswordRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> sendOtp({required String identifier}) async {
    return await remoteDataSource.sendOtp(identifier: identifier);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String identifier,
  }) async {
    return await remoteDataSource.verifyOtp(otp: otp, identifier: identifier);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String identifier,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await remoteDataSource.resetPassword(
      resetToken: resetToken,
      identifier: identifier,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
