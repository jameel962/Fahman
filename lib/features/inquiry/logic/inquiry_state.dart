part of 'inquiry_cubit.dart';

class InquiryState extends Equatable {
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isSending;
  final bool isMutating;
  final String? errorMessage;

  final List<ConversationModel> conversations;
  final String? activeConversationId;
  final List<ChatMessageModel> messages;

  final int pageNumber;
  final int pageSize;
  final int? totalPages;

  const InquiryState({
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.isMutating = false,
    this.errorMessage,
    this.conversations = const [],
    this.activeConversationId,
    this.messages = const [],
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalPages,
  });

  InquiryState copyWith({
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isSending,
    bool? isMutating,
    String? errorMessage,
    List<ConversationModel>? conversations,
    String? activeConversationId,
    List<ChatMessageModel>? messages,
    int? pageNumber,
    int? pageSize,
    int? totalPages,
  }) {
    return InquiryState(
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage,
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      messages: messages ?? this.messages,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingConversations,
    isLoadingMessages,
    isSending,
    isMutating,
    errorMessage,
    conversations,
    activeConversationId,
    messages,
    pageNumber,
    pageSize,
    totalPages,
  ];
}
