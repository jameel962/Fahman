import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/core/networking/errors/exceptions.dart';
import 'package:fahman_app/app_logger.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options.baseUrl = EndPoints.baseUrl;
    dio.interceptors.add(ApiInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  @override
  Future delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      AppLogger.e('API Error: DELETE $path - ${e.message}', e);
      if (e.response != null) {
        AppLogger.d('API Error Response Data: ${e.response?.data}');
        return e.response?.data;
      }
      handleDioExceptions(e);
    }
  }

  @override
  Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      AppLogger.e('API Error: GET $path - ${e.message}', e);
      if (e.response != null) {
        AppLogger.d('API Error Response Data: ${e.response?.data}');
        return e.response?.data;
      }
      handleDioExceptions(e);
    }
  }

  @override
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      AppLogger.e('API Error: PATCH $path - ${e.message}', e);
      if (e.response != null) {
        AppLogger.d('API Error Response Data: ${e.response?.data}');
        return e.response?.data;
      }
      handleDioExceptions(e);
    }
  }

  @override
  Future put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      AppLogger.e('API Error: PUT $path - ${e.message}', e);
      if (e.response != null) {
        AppLogger.d('API Error Response Data: ${e.response?.data}');
        return e.response?.data;
      }
      handleDioExceptions(e);
    }
  }

  @override
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      // Log the request
      AppLogger.d('API Request: POST $path');
      AppLogger.d('API Request Body: $data');
      AppLogger.d('API Request isFormData: $isFormData');

      final requestData = isFormData
          ? FormData.fromMap(data as Map<String, dynamic>)
          : data;
      final response = await dio.post(
        path,
        data: requestData,
        queryParameters: queryParameters,
      );

      // Log the response
      AppLogger.d('API Response: POST $path - Status: ${response.statusCode}');
      AppLogger.d('API Response Data: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      AppLogger.e('API Error: POST $path - ${e.message}', e);
      if (e.response != null) {
        AppLogger.d('API Error Response Data: ${e.response?.data}');
        return e.response?.data;
      }
      handleDioExceptions(e);
    }
  }
}
