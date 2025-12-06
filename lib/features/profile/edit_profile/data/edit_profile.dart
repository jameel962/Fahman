import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http_parser/http_parser.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/app_logger.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';

/// Repository for updating user profile (UserName, PhoneNumber, ProfileImage)
class UpdateProfileRepository {
  final ApiConsumer apiConsumer;

  UpdateProfileRepository({required this.apiConsumer});

  /// Update user profile with multipart/form-data.
  /// Accepts either a device file path or an asset path (starting with 'assets/').
  /// Returns a map with success/message/data.
  Future<Map<String, dynamic>> updateProfile({
    required String userName,
    required String phoneNumber,
    String? imageFilePath,
  }) async {
    try {
      AppLogger.d('UpdateProfile Request:');
      AppLogger.d('  userName: $userName');
      AppLogger.d('  imageFilePath: $imageFilePath');

      final formData = FormData();
      formData.fields.add(MapEntry('UserName', userName));

      if (imageFilePath != null && imageFilePath.isNotEmpty) {
        // If an asset path was provided, load bytes from rootBundle
        if (imageFilePath.startsWith('assets/')) {
          try {
            final bytes = await rootBundle.load(imageFilePath);
            final list = bytes.buffer.asUint8List();
            final filename = imageFilePath.split('/').last;
            formData.files.add(
              MapEntry(
                'ProfileImage',
                MultipartFile.fromBytes(
                  list,
                  filename: filename,
                  contentType: MediaType(
                    'image',
                    _guessImageExtension(filename),
                  ),
                ),
              ),
            );
            AppLogger.d('  Image added from asset: $filename');
          } catch (e) {
            AppLogger.w('  Failed to load asset image: $imageFilePath - $e');
          }
        } else {
          // Treat as filesystem path
          final file = File(imageFilePath);
          if (await file.exists()) {
            final fileName = file.path.split('/').last;
            formData.files.add(
              MapEntry(
                'ProfileImage',
                await MultipartFile.fromFile(file.path, filename: fileName),
              ),
            );
            AppLogger.d('  Image file added: $fileName');
          } else {
            AppLogger.w('  Image file does not exist: $imageFilePath');
          }
        }
      }

      AppLogger.d('FormData fields: ${formData.fields}');
      AppLogger.d('FormData files: ${formData.files.length} file(s)');

      // Ensure Authorization header is present
      await _ensureAuthToken();

      final resp = await apiConsumer.put(
        EndPoints.updateUserInfo,
        data: formData,
      );

      AppLogger.d('UpdateProfile Response: $resp');

      if (resp is Map<String, dynamic>) return resp;
      return {'success': true, 'data': resp};
    } on DioException catch (e, st) {
      AppLogger.e('UpdateProfile error (DioException)', e, st);
      return _handleDioError(e);
    } catch (e, st) {
      AppLogger.e('UpdateProfile error', e, st);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update user basic info using JSON body (userName, avatarId)
  Future<Map<String, dynamic>> updateUserInfoJson({
    required String userName,
    required int avatarId,
  }) async {
    try {
      final body = {'userName': userName, 'avatarId': avatarId};
      AppLogger.d('UpdateUserInfo JSON body: $body');

      await _ensureAuthToken();

      final resp = await apiConsumer.put(EndPoints.updateUserInfo, data: body);
      AppLogger.d('UpdateUserInfo Response: $resp');

      if (resp is Map<String, dynamic>) return resp;
      return {'success': true, 'data': resp};
    } on DioException catch (e, st) {
      AppLogger.e('UpdateUserInfo error (DioException)', e, st);
      return _handleDioError(e);
    } catch (e, st) {
      AppLogger.e('UpdateUserInfo error', e, st);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Fetch avatars from server endpoint /api/Static/AllAvatars. Returns raw response.
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

  /// Guess mime subtype from filename extension
  String _guessImageExtension(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpeg';
    if (lower.endsWith('.gif')) return 'gif';
    return 'png';
  }
}
