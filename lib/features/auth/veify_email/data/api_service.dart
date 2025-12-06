import 'package:dio/dio.dart';
import '../../../../core/networking/api/end_points.dart';
import '../../../../app_logger.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options
      ..baseUrl = EndPoints.baseUrl
      ..responseType = ResponseType.json;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        EndPoints.verifyOtp,
        queryParameters: {'otp': otp, 'userId': userId},
      );
      // log response for debugging
      AppLogger.d('verifyOtp response status: ${response.statusCode}');
      AppLogger.d('verifyOtp response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      // detailed error logging
      AppLogger.e('verifyOtp DioException: ${e.message}', e);
      if (e.response != null) {
        AppLogger.e(
          'verifyOtp error response status: ${e.response?.statusCode}',
        );
        AppLogger.e('verifyOtp error response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      AppLogger.e('verifyOtp unexpected error: $e', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reSendAuthOtp({
    required String identifier,
  }) async {
    try {
      final response = await _dio.post(
        EndPoints.resendAuthOtp,
        queryParameters: {'Identifier': identifier},
      );
      AppLogger.d('reSendAuthOtp response status: ${response.statusCode}');
      AppLogger.d('reSendAuthOtp response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      AppLogger.e('reSendAuthOtp DioException: ${e.message}', e);
      if (e.response != null) {
        AppLogger.e(
          'reSendAuthOtp error response status: ${e.response?.statusCode}',
        );
        AppLogger.e('reSendAuthOtp error response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      AppLogger.e('reSendAuthOtp unexpected error: $e', e);
      rethrow;
    }
  }
}
