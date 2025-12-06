import 'package:fahman_app/features/inquiry/data/inquiry_remote_data_source.dart';
import 'package:fahman_app/features/inquiry/data/models/chat_models.dart';

class InquiryRepository {
  final InquiryRemoteDataSource remote;

  InquiryRepository({required this.remote});

  Future<PagedResult<ConversationModel>> getConversations({
    required int pageNumber,
    required int pageSize,
  }) async {
    final map = await remote.getConversations(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return PagedResult.fromMap(map, (m) => ConversationModel.fromMap(m));
  }

  Future<ConversationModel> getConversation(String conversationId) async {
    final map = await remote.getConversation(conversationId);
    return ConversationModel.fromMap(map);
  }

  Future<void> deleteConversation(String conversationId) async {
    await remote.deleteConversation(conversationId);
  }

  Future<List<ChatMessageModel>> getConversationMessages({
    required String conversationId,
    int? count,
  }) async {
    final map = await remote.getConversationMessages(
      conversationId: conversationId,
      count: count,
    );
    final items = (map['items'] as List?) ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map((m) => ChatMessageModel.fromMap(m))
        .toList();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? conversationId,
    int topK = 0,
  }) async {
    final map = await remote.sendMessage(
      message: message,
      conversationId: conversationId,
      topK: topK,
    );
    // Return the raw response map - it contains conversationId and message
    return map;
  }
}
