import 'package:fahman_app/core/networking/api_service.dart';

class VerifyEmailRepo {
  final ApiService _apiService;

  VerifyEmailRepo(this._apiService);

  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String userId,
  }) async {
    try {
      return await _apiService.verifyOtp(otp: otp, userId: userId);
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reSendOtp({required String identifier}) async {
    try {
      return await _apiService.reSendAuthOtp(identifier: identifier);
    } catch (error) {
      rethrow;
    }
  }
}
