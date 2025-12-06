import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'models/consultation_models.dart';

class ConsultationRepository {
  final ApiConsumer api;
  ConsultationRepository({required this.api});

  Future<List<ConsultationSectionModel>> fetchSections() async {
    try {
      final response = await api.get(EndPoints.consultationSections);

      // Handle wrapped response: {succeeded, message, data: [...]}
      List? data;
      if (response is Map<String, dynamic>) {
        if (response['data'] != null) {
          data = response['data'] as List?;
        } else {
          data = null;
        }
      } else if (response is List) {
        data = response;
      }

      if (data == null || data.isEmpty) {
        print('⚠️ No sections returned from API');
        return []; // Return empty list - no mock data
      }

      print('✅ Parsed ${data.length} sections from API');
      return data.map((e) => ConsultationSectionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      print('❌ Sections API failed with DioException: ${e.type}');
      // Re-throw DioException so the UI can handle it properly
      rethrow;
    } catch (e) {
      print('❌ Sections API failed: $e');
      // Re-throw other exceptions
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createConsultation({
    required String sectionId,
    required String content,
    List<File> files = const [],
  }) async {
    final formMap = {
      'SectionId': sectionId,
      'Content': content,
      if (files.isNotEmpty)
        'Files': files
            .map(
              (f) => MultipartFile.fromFileSync(
                f.path,
                filename: f.path.split('/').last,
              ),
            )
            .toList(),
    };
    final res = await api.post(
      EndPoints.consultations,
      data: formMap,
      isFormData: true,
    );

    // Handle cases where API returns non-map data (errors, empty responses, etc.)
    if (res == null) {
      throw Exception('Server returned null response');
    }
    if (res is! Map<String, dynamic>) {
      throw Exception(
        'Server returned invalid response format: ${res.runtimeType}',
      );
    }

    // Check for API error response: {succeeded: false, message: "..."}
    if (res['succeeded'] == false) {
      final errorMsg = res['message'] ?? 'Unknown error';
      throw Exception(errorMsg);
    }

    return res;
  }

  Future<List<ConsultationModel>> fetchConsultations({
    String? status,
    String? sectionId,
    String? userEmail,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final query = <String, dynamic>{
      'PageNumber': pageNumber,
      'PageSize': pageSize,
      if (status != null) 'Status': status,
      if (sectionId != null) 'SectionId': sectionId,
      if (userEmail != null) 'UserEmail': userEmail,
      if (startDate != null) 'StartDate': startDate.toIso8601String(),
      if (endDate != null) 'EndDate': endDate.toIso8601String(),
      if (sortBy != null) 'SortBy': sortBy,
      if (sortOrder != null) 'SortOrder': sortOrder,
    };
    final response =
        await api.get(EndPoints.consultations, queryParameters: query)
            as Map<String, dynamic>?;

    // Handle wrapped response: {succeeded, message, data: [...]}
    List? items;
    if (response != null) {
      if (response['data'] != null) {
        items = response['data'] as List?;
      } else if (response['items'] != null) {
        items = response['items'] as List?;
      }
    }

    if (items == null) return [];
    return items.map((e) => ConsultationModel.fromJson(e)).toList();
  }

  Future<ConsultationModel?> getConsultation(String id) async {
    final path = EndPoints.withParams(EndPoints.consultationById, {'id': id});
    final data = await api.get(path) as Map<String, dynamic>?;
    if (data == null) return null;
    return ConsultationModel.fromJson(data);
  }

  Future<bool> updateConsultation({
    required String id,
    required String sectionId,
    required String content,
  }) async {
    final path = EndPoints.withParams(EndPoints.consultationById, {'id': id});
    final body = {'sectionId': sectionId, 'content': content};
    final res = await api.put(path, data: body) as Map<String, dynamic>?;
    return res != null;
  }

  Future<bool> deleteConsultation(String id) async {
    final path = EndPoints.withParams(EndPoints.consultationById, {'id': id});
    final res = await api.delete(path) as Map<String, dynamic>?;
    return res != null;
  }

  Future<List<ConsultationFileModel>> addFiles({
    required String id,
    required List<File> files,
  }) async {
    final path = EndPoints.withParams(EndPoints.consultationFiles, {'id': id});
    final formMap = {
      'files': files
          .map(
            (f) => MultipartFile.fromFileSync(
              f.path,
              filename: f.path.split('/').last,
            ),
          )
          .toList(),
    };
    final data = await api.post(path, data: formMap, isFormData: true) as List?;
    if (data == null) return [];
    return data.map((e) => ConsultationFileModel.fromJson(e)).toList();
  }

  Future<bool> deleteFile({
    required String consultationId,
    required String fileId,
  }) async {
    final path = EndPoints.withParams(EndPoints.deleteConsultationFile, {
      'consultationId': consultationId,
      'fileId': fileId,
    });
    final res = await api.delete(path) as Map<String, dynamic>?;
    return res != null;
  }

  /// Optional: forward consultation payload to a history service.
  /// If [historyUrl] is null the call is skipped and returns null.
  Future<dynamic> forwardToHistory({
    required Map<String, dynamic> payload,
    String? historyUrl,
  }) async {
    if (historyUrl == null || historyUrl.isEmpty) return null;
    // If historyUrl is a relative path, use EndPoints.full
    final target = historyUrl.startsWith('http')
        ? historyUrl
        : EndPoints.full(historyUrl);
    return await api.post(target, data: payload);
  }
}
