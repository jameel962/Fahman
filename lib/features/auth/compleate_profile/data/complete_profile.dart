import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/app_logger.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';

/// Repository for completing user profile during registration/onboarding
class CompleteProfileRepository {
  final ApiConsumer apiConsumer;

  CompleteProfileRepository({required this.apiConsumer});

  /// Complete profile using JSON POST.
  /// Expects body: { userName, phoneNumber, avatarId }
  Future<Map<String, dynamic>> completeProfile({
    required String userName,
    required String phoneNumber,
    required int avatarId,
  }) async {
    try {
      final body = {
        'userName': userName,
        'phoneNumber': phoneNumber,
        'avatarId': avatarId,
      };

      AppLogger.d('CompleteProfile POST body: $body');

      // Ensure Authorization header is present
      await _ensureAuthToken();

      // Use DioConsumer directly to ensure headers are sent properly
      dynamic resp;
      try {
        final token = AuthSession().token;
        if (apiConsumer is DioConsumer) {
          final dio = (apiConsumer as DioConsumer).dio;
          final headers = <String, dynamic>{'Content-Type': 'application/json'};

          if (token != null && token.isNotEmpty) {
            headers['Authorization'] = 'Bearer $token';
          }

          // Debug logs
          AppLogger.d(
            'CompleteProfile: token present: ${token != null && token.isNotEmpty}',
          );
          AppLogger.d('CompleteProfile: POST headers: $headers');

          final response = await dio.post(
            EndPoints.completeProfile,
            data: body,
            options: Options(headers: headers),
          );
          resp = response.data;
        } else {
          AppLogger.d('CompleteProfile: using generic apiConsumer.post');
          resp = await apiConsumer.post(EndPoints.completeProfile, data: body);
        }
      } catch (e) {
        rethrow;
      }

      AppLogger.d('CompleteProfile Response: $resp');

      if (resp is Map<String, dynamic>) return resp;
      return {'success': true, 'data': resp};
    } on DioException catch (e, st) {
      AppLogger.e('CompleteProfile error (DioException)', e, st);
      return _handleDioError(e);
    } catch (e, st) {
      AppLogger.e('CompleteProfile error', e, st);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Fetch all available avatars from server
  /// GET /api/Static/AllAvatars
  Future<dynamic> getAllAvatarsRemote() async {
    try {
      final resp = await apiConsumer.get(EndPoints.allAvatars);
      return resp;
    } catch (e) {
      AppLogger.w('Failed to fetch remote avatars: $e');
      return null;
    }
  }

  /// Ensure Authorization token is set in headers
  Future<void> _ensureAuthToken() async {
    try {
      await AuthSession().refreshFromStorage();
      final token = AuthSession().token;
      if (token != null && token.isNotEmpty && apiConsumer is DioConsumer) {
        (apiConsumer as DioConsumer).dio.options.headers['Authorization'] =
            'Bearer $token';
      }
    } catch (_) {}
  }

  /// Handle DioException and extract error message
  Map<String, dynamic> _handleDioError(DioException e) {
    String? message;
    final resp = e.response;
    if (resp != null) {
      final data = resp.data;
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is String) {
        message = data;
      } else if (data != null) {
        message = data.toString();
      } else {
        message = 'HTTP ${resp.statusCode} error';
      }
    } else {
      message = e.message;
    }

    return {'success': false, 'message': message ?? 'Unknown network error'};
  }
}
