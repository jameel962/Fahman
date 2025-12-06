import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http_parser/http_parser.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/app_logger.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';

class CompleteProfileRepository {
  final ApiConsumer apiConsumer;

  CompleteProfileRepository({required this.apiConsumer});

  /// Update user profile. Accepts either a device file path or an asset path
  /// (starting with 'assets/'). Returns a map with success/message/data so
  /// the caller can display server messages in the UI.
  Future<Map<String, dynamic>> updateProfile({
    required String userName,
    required String phoneNumber,
    String? imageFilePath,
  }) async {
    try {
      AppLogger.d('UpdateProfile Request:');
      AppLogger.d('  userName: $userName');
      AppLogger.d('  phoneNumber: $phoneNumber');
      AppLogger.d('  imageFilePath: $imageFilePath');

      final formData = FormData();
      formData.fields.add(MapEntry('UserName', userName));
      formData.fields.add(MapEntry('PhoneNumber', phoneNumber));

      if (imageFilePath != null && imageFilePath.isNotEmpty) {
        // If an asset path was provided, load bytes from rootBundle and
        // create a MultipartFile from bytes. Otherwise, treat the path as a
        // filesystem path and attach the file.
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

      final resp = await apiConsumer.put(
        EndPoints.updateUserInfo,
        data: formData,
      );

      AppLogger.d('UpdateProfile Response: $resp');

      if (resp is Map<String, dynamic>) return resp;
      return {'success': true, 'data': resp};
    } on DioException catch (e, st) {
      AppLogger.e('UpdateProfile error in repository (DioException)', e, st);

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
    } catch (e, st) {
      AppLogger.e('UpdateProfile error in repository', e, st);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Complete profile using simple JSON POST. Expects body: { userName, phoneNumber, avatarId }
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

      // Ensure we have the latest token and, if missing, try to refresh
      // using the stored refresh token before sending the CompleteProfile POST.
      try {
        await AuthSession().refreshFromStorage();
      } catch (_) {}

      String? token = AuthSession().token;
      AppLogger.d(
        'CompleteProfile: token present: ${token != null && token.isNotEmpty}',
      );

      // If access token missing but refresh token exists, attempt refresh now.
      final storedRefresh = AuthSession().refreshToken;
      AppLogger.d(
        'CompleteProfile: refresh token present: ${storedRefresh != null && storedRefresh.isNotEmpty}',
      );
      if (storedRefresh != null && storedRefresh.isNotEmpty) {
        try {
          final refreshToken = storedRefresh;
          final dioRefresh = Dio();
          dioRefresh.options.baseUrl = EndPoints.baseUrl;
          final refreshPath = EndPoints.withParams(EndPoints.refreshToken, {
            'refreshToken': refreshToken,
          });
          AppLogger.d('CompleteProfile: attempting token refresh');
          final refreshResp = await dioRefresh.post(refreshPath);
          AppLogger.d('CompleteProfile: refresh response: ${refreshResp.data}');
          final data = refreshResp.data as Map<String, dynamic>?;
          final newAccess = data?['accessToken'] as String?;
          final newRefresh = data?['refreshToken'] as String?;
          if (newAccess != null && newAccess.isNotEmpty) {
            await AuthSession().setToken(newAccess);
            AppLogger.d('CompleteProfile: token refresh succeeded');
            if (newRefresh != null && newRefresh.isNotEmpty) {
              await AuthSession().setRefreshToken(newRefresh);
            }
            token = newAccess;
          } else {
            AppLogger.d(
              'CompleteProfile: token refresh did not return access token',
            );
          }
        } catch (refreshErr) {
          AppLogger.e('CompleteProfile: token refresh failed', refreshErr);
        }
      }

      // If still no token available, return an explicit error to avoid 401.
      if (token == null || token.isEmpty) {
        AppLogger.d(
          'CompleteProfile: no access token available after refresh attempt',
        );
        return {
          'success': false,
          'message': 'No access token available. Please login.',
        };
      }

      dynamic resp;
      if (apiConsumer is DioConsumer) {
        final dio = (apiConsumer as DioConsumer).dio;
        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
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

      AppLogger.d('CompleteProfile Response: $resp');

      if (resp is Map<String, dynamic>) return resp;
      return {'success': true, 'data': resp};
    } on DioException catch (e, st) {
      AppLogger.e('CompleteProfile error (DioException)', e, st);
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
    } catch (e, st) {
      AppLogger.e('CompleteProfile error', e, st);
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

  /// Update user basic info using JSON body. Example: { userName, avatarId }
  Future<Map<String, dynamic>> updateUserInfoJson({
    required String userName,
    required int avatarId,
  }) async {
    try {
      final body = {'userName': userName, 'avatarId': avatarId};
      AppLogger.d('UpdateUserInfo JSON body: $body');
      final resp = await apiConsumer.put(EndPoints.updateUserInfo, data: body);
      AppLogger.d('UpdateUserInfo Response: $resp');
      if (resp is Map<String, dynamic>) return resp;
      return {'success': true, 'data': resp};
    } on DioException catch (e, st) {
      AppLogger.e('UpdateUserInfo error (DioException)', e, st);
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
    } catch (e, st) {
      AppLogger.e('UpdateUserInfo error', e, st);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Guess a simple mime subtype from filename extension. Returns 'png' by
  /// default when unknown.
  String _guessImageExtension(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpeg';
    if (lower.endsWith('.gif')) return 'gif';
    return 'png';
  }
}
