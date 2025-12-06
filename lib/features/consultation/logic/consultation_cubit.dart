import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'consultation_state.dart';
import '../data/consultation_repository.dart';
import '../data/models/consultation_models.dart';

class ConsultationCubit extends Cubit<ConsultationState> {
  final ConsultationRepository repository;
  ConsultationCubit({required this.repository})
    : super(const ConsultationState());

  Future<void> loadSections() async {
    emit(state.copyWith(isLoadingSections: true, clearError: true));
    try {
      final sections = await repository.fetchSections();
      // No server message usually for sections, but ensure previous message is cleared
      emit(
        state.copyWith(
          isLoadingSections: false,
          sections: sections,
          lastServerMessage: null,
        ),
      );
    } on DioException catch (e) {
      // Handle specific network errors
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'CONNECTION_TIMEOUT';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'NO_INTERNET';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'SECTIONS_NOT_FOUND';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'SERVER_ERROR';
      } else {
        errorMessage = 'NETWORK_ERROR';
      }

      emit(
        state.copyWith(isLoadingSections: false, errorMessage: errorMessage),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingSections: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadConsultations({bool refresh = false}) async {
    if (state.isLoadingList) return;
    final nextPage = refresh ? 1 : state.pageNumber;
    emit(state.copyWith(isLoadingList: true, clearError: true));
    try {
      final items = await repository.fetchConsultations(
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );
      final merged = refresh ? items : [...state.consultations, ...items];
      emit(
        state.copyWith(
          isLoadingList: false,
          consultations: merged,
          pageNumber: nextPage + 1,
          hasMore: items.length >= state.pageSize,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingList: false, errorMessage: e.toString()));
    }
  }

  Future<void> fetchConsultations({
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
    emit(state.copyWith(isLoadingList: true, clearError: true));
    try {
      final items = await repository.fetchConsultations(
        status: status,
        sectionId: sectionId,
        userEmail: userEmail,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortOrder: sortOrder,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      emit(
        state.copyWith(
          isLoadingList: false,
          consultations: items,
          pageNumber: pageNumber + 1,
          hasMore: items.length >= pageSize,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingList: false, errorMessage: e.toString()));
    }
  }

  Future<void> createConsultation({
    required String sectionId,
    required String content,
    List<File> files = const [],
    String? forwardHistoryUrl,
  }) async {
    emit(state.copyWith(isSubmitting: true, lastServerMessage: null));

    print('🔵 === CREATING CONSULTATION ===');
    print('   Section ID: $sectionId');
    print('   Content: $content');
    print('   Files count: ${files.length}');

    try {
      final res = await repository.createConsultation(
        sectionId: sectionId,
        content: content,
        files: files,
      );

      print('✅ === SERVER RESPONSE ===');
      print('📦 Full Response: $res');
      print('📦 Response Type: ${res.runtimeType}');
      print('📦 Response Keys: ${res.keys.toList()}');
      res.forEach((key, value) {
        print('   $key: $value');
      });
      print('=========================');

      final message = _extractMessage(res);
      final id = res['id']?.toString() ?? res['data']?['id']?.toString();

      emit(
        state.copyWith(
          isSubmitting: false,
          lastServerMessage: message ?? 'Consultation created successfully!',
          lastCreatedConsultationId: id,
        ),
      );

      print('✅ Consultation created successfully!');
      print('   Message: $message');
      print('   ID: $id');

      // Optional: forward to history service
      if (forwardHistoryUrl != null && forwardHistoryUrl.isNotEmpty) {
        print('📤 Forwarding to history service: $forwardHistoryUrl');
        try {
          await repository.forwardToHistory(
            payload: res,
            historyUrl: forwardHistoryUrl,
          );
          print('✅ Forwarded to history successfully');
        } catch (e) {
          print('⚠️ Failed to forward to history: $e');
        }
      }
    } catch (e) {
      print('❌ === CREATE CONSULTATION ERROR ===');
      print('   Error: $e');
      print('   Error Type: ${e.runtimeType}');

      String errorMessage;
      if (e.toString().contains('404') ||
          e.toString().contains('Server returned')) {
        errorMessage =
            'Consultation endpoint not found (404). Please check the API endpoint configuration.';
        print(
          '   💡 Hint: The endpoint /api/customer/Consultations might not exist on the server.',
        );
        print(
          '   💡 Try checking: /api/Consultations or /api/admin/Consultations',
        );
      } else {
        errorMessage = e.toString();
      }

      print('====================================');

      emit(state.copyWith(isSubmitting: false, errorMessage: errorMessage));
    }
  }

  Future<void> addFiles(String id, List<File> files) async {
    // added optional forwarding but not exposed via parameters for now
    emit(state.copyWith(isMutating: true, clearError: true));
    try {
      final uploaded = await repository.addFiles(id: id, files: files);
      final updatedList = state.consultations.map((c) {
        if (c.id == id) {
          return ConsultationModel(
            id: c.id,
            sectionId: c.sectionId,
            sectionName: c.sectionName,
            content: c.content,
            contentPreview: c.contentPreview,
            status: c.status,
            createdAt: c.createdAt,
            files: [...c.files, ...uploaded],
            fileCount: c.files.length + uploaded.length,
            userName: c.userName,
          );
        }
        return c;
      }).toList();
      emit(
        state.copyWith(
          isMutating: false,
          consultations: updatedList,
          lastServerMessage: 'Files uploaded',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isMutating: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteConsultation(String id) async {
    emit(state.copyWith(isMutating: true, clearError: true));
    try {
      final ok = await repository.deleteConsultation(id);
      if (ok) {
        final filtered = state.consultations.where((c) => c.id != id).toList();
        emit(
          state.copyWith(
            isMutating: false,
            consultations: filtered,
            lastServerMessage: 'Deleted',
          ),
        );
      } else {
        emit(state.copyWith(isMutating: false, errorMessage: 'Delete failed'));
      }
    } catch (e) {
      emit(state.copyWith(isMutating: false, errorMessage: e.toString()));
    }
  }

  String? _extractMessage(dynamic res) {
    if (res is Map<String, dynamic>) {
      for (final k in ['message', 'Message', 'msg', 'statusMessage']) {
        final v = res[k];
        if (v is String && v.trim().isNotEmpty) return v;
      }
    }
    return null;
  }

  Future<void> updateConsultation({
    required String id,
    required String sectionId,
    required String content,
  }) async {
    emit(state.copyWith(isMutating: true, clearError: true));
    try {
      final ok = await repository.updateConsultation(
        id: id,
        sectionId: sectionId,
        content: content,
      );
      if (ok) {
        await loadConsultations(refresh: true);
        emit(state.copyWith(isMutating: false, lastServerMessage: 'Updated'));
      } else {
        emit(state.copyWith(isMutating: false, errorMessage: 'Update failed'));
      }
    } catch (e) {
      emit(state.copyWith(isMutating: false, errorMessage: e.toString()));
    }
  }
}
