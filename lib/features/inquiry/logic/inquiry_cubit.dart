import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fahman_app/features/inquiry/data/inquiry_repository.dart';
import 'package:fahman_app/features/inquiry/data/models/chat_models.dart';

part 'inquiry_state.dart';

class InquiryCubit extends Cubit<InquiryState> {
  final InquiryRepository repository;

  InquiryCubit({required this.repository}) : super(const InquiryState());

  Future<void> loadConversations({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    emit(state.copyWith(isLoadingConversations: true, errorMessage: null));
    try {
      final paged = await repository.getConversations(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      emit(
        state.copyWith(
          isLoadingConversations: false,
          conversations: paged.items,
          pageNumber: paged.pageNumber ?? pageNumber,
          pageSize: paged.pageSize ?? pageSize,
          totalPages: paged.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingConversations: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadConversation(String conversationId) async {
    emit(state.copyWith(isLoadingMessages: true, errorMessage: null));
    try {
      final convo = await repository.getConversation(conversationId);
      emit(
        state.copyWith(
          isLoadingMessages: false,
          activeConversationId: convo.conversationId,
          messages: convo.messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingMessages: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadMessages(String conversationId, {int? count}) async {
    emit(state.copyWith(isLoadingMessages: true, errorMessage: null));
    try {
      final msgs = await repository.getConversationMessages(
        conversationId: conversationId,
        count: count,
      );
      emit(
        state.copyWith(
          isLoadingMessages: false,
          activeConversationId: conversationId,
          messages: msgs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingMessages: false, errorMessage: e.toString()),
      );
    }
  }

  /// Open a conversation from history - loads full conversation details including messages
  Future<void> openConversation(String conversationId) async {
    emit(state.copyWith(isLoadingMessages: true, errorMessage: null));
    try {
      // Get messages for this conversation
      final msgs = await repository.getConversationMessages(
        conversationId: conversationId,
      );

      // Update conversations list to mark this one as active
      final updatedConversations = state.conversations.map((c) {
        if (c.conversationId == conversationId) {
          return ConversationModel(
            id: c.id,
            conversationId: c.conversationId,
            userId: c.userId,
            title: c.title,
            language: c.language,
            createdAt: c.createdAt,
            lastMessageAt: c.lastMessageAt,
            isActive: true,
            messageCount: c.messageCount,
            messages: msgs,
          );
        } else {
          return ConversationModel(
            id: c.id,
            conversationId: c.conversationId,
            userId: c.userId,
            title: c.title,
            language: c.language,
            createdAt: c.createdAt,
            lastMessageAt: c.lastMessageAt,
            isActive: false,
            messageCount: c.messageCount,
            messages: c.messages,
          );
        }
      }).toList();

      emit(
        state.copyWith(
          isLoadingMessages: false,
          activeConversationId: conversationId,
          messages: msgs,
          conversations: updatedConversations,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingMessages: false, errorMessage: e.toString()),
      );
    }
  }

  /// Start a new conversation (clear active conversation and messages)
  void startNewConversation() {
    emit(state.copyWith(activeConversationId: null, messages: const []));
  }

  Future<void> deleteConversation(String conversationId) async {
    emit(state.copyWith(isMutating: true, errorMessage: null));
    try {
      await repository.deleteConversation(conversationId);
      final updated = List<ConversationModel>.from(state.conversations)
        ..removeWhere((c) => c.conversationId == conversationId);
      emit(
        state.copyWith(
          isMutating: false,
          conversations: updated,
          // Clear active if it was the one removed
          activeConversationId: state.activeConversationId == conversationId
              ? null
              : state.activeConversationId,
          messages: state.activeConversationId == conversationId
              ? const []
              : state.messages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isMutating: false, errorMessage: e.toString()));
    }
  }

  Future<void> sendMessage({
    required String message,
    String? conversationId,
    int topK = 0,
  }) async {
    emit(state.copyWith(isSending: true, errorMessage: null));
    try {
      final response = await repository.sendMessage(
        message: message,
        conversationId: conversationId,
        topK: topK,
      );

      // Extract data from POST response
      final String newConversationId = response['conversationId'] as String;
      final String assistantMessage = response['message'] as String? ?? '';
      final bool isNewConversation =
          response['isNewConversation'] as bool? ?? false;

      // Build messages list from the conversation
      // For new conversations, we have user message + assistant response
      // For existing, just add the new exchange
      final List<ChatMessageModel> updatedMessages = [
        ...state.messages,
        // User message
        ChatMessageModel(
          role: 'user',
          content: message,
          conversationId: newConversationId,
          createdAt: DateTime.now(),
        ),
        // Assistant response
        ChatMessageModel(
          role: 'assistant',
          content: assistantMessage,
          conversationId: newConversationId,
          needsClarification: response['needsClarification'] as bool?,
          metadata: {
            'sourcesUsed': response['sourcesUsed'],
            'language': response['language'],
            if (response['originalQuestion'] != null)
              'originalQuestion': response['originalQuestion'],
            if (response['correctedQuestion'] != null)
              'correctedQuestion': response['correctedQuestion'],
          },
          createdAt: DateTime.now(),
        ),
      ];

      // Update conversations list
      final list = List<ConversationModel>.from(state.conversations);

      if (isNewConversation) {
        // Add new conversation to the beginning of the list
        list.insert(
          0,
          ConversationModel(
            conversationId: newConversationId,
            title: message.length > 50
                ? '${message.substring(0, 50)}...'
                : message,
            language: response['language'] as String?,
            createdAt: DateTime.now(),
            lastMessageAt: DateTime.now(),
            isActive: true,
            messageCount: 2, // user + assistant
            messages: updatedMessages,
          ),
        );
      } else {
        // Update existing conversation
        final idx = list.indexWhere(
          (c) => c.conversationId == newConversationId,
        );
        if (idx >= 0) {
          final existing = list[idx];
          list[idx] = ConversationModel(
            id: existing.id,
            conversationId: existing.conversationId,
            userId: existing.userId,
            title: existing.title,
            language: existing.language,
            createdAt: existing.createdAt,
            lastMessageAt: DateTime.now(),
            isActive: existing.isActive,
            messageCount: (existing.messageCount ?? 0) + 2,
            messages: updatedMessages,
          );
        }
      }

      emit(
        state.copyWith(
          isSending: false,
          conversations: list,
          activeConversationId: newConversationId,
          messages: updatedMessages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSending: false, errorMessage: e.toString()));
    }
  }
}
