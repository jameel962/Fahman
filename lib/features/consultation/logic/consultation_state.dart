import 'package:equatable/equatable.dart';
import '../data/models/consultation_models.dart';

class ConsultationState extends Equatable {
  final bool isLoadingSections;
  final bool isLoadingList;
  final bool isSubmitting;
  final bool isMutating;
  final String? errorMessage;
  final String? lastServerMessage;
  final List<ConsultationSectionModel> sections;
  final List<ConsultationModel> consultations;
  final ConsultationModel? activeConsultation;
  final int pageNumber;
  final int pageSize;
  final bool hasMore;
  final String? lastCreatedConsultationId;

  const ConsultationState({
    this.isLoadingSections = false,
    this.isLoadingList = false,
    this.isSubmitting = false,
    this.isMutating = false,
    this.errorMessage,
    this.lastServerMessage,
    this.sections = const [],
    this.consultations = const [],
    this.activeConsultation,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.hasMore = true,
    this.lastCreatedConsultationId,
  });

  ConsultationState copyWith({
    bool? isLoadingSections,
    bool? isLoadingList,
    bool? isSubmitting,
    bool? isMutating,
    String? errorMessage,
    String? lastServerMessage,
    String? lastCreatedConsultationId,
    List<ConsultationSectionModel>? sections,
    List<ConsultationModel>? consultations,
    ConsultationModel? activeConsultation,
    int? pageNumber,
    int? pageSize,
    bool? hasMore,
    bool clearError = false,
  }) {
    return ConsultationState(
      isLoadingSections: isLoadingSections ?? this.isLoadingSections,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastServerMessage: lastServerMessage ?? this.lastServerMessage,
      lastCreatedConsultationId:
          lastCreatedConsultationId ?? this.lastCreatedConsultationId,
      sections: sections ?? this.sections,
      consultations: consultations ?? this.consultations,
      activeConsultation: activeConsultation ?? this.activeConsultation,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingSections,
    isLoadingList,
    isSubmitting,
    isMutating,
    errorMessage,
    lastServerMessage,
    sections,
    consultations,
    activeConsultation,
    pageNumber,
    pageSize,
    hasMore,
    lastCreatedConsultationId,
  ];
}
