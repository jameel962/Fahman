import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

class InquiryRemoteDataSource {
  final ApiConsumer api;

  InquiryRemoteDataSource({required this.api});

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? conversationId,
    int topK = 0,
  }) async {
    final body = <String, dynamic>{
      'topK': topK,
      'message': message,
      // The API allows first message without conversationId; include if provided
      if (conversationId != null) 'conversationId': conversationId,
    };
    final resp = await api.post(EndPoints.chatMessage, data: body);
    return (resp as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getConversations({
    required int pageNumber,
    required int pageSize,
  }) async {
    final resp = await api.get(
      EndPoints.chatConversations,
      queryParameters: {'Pagenumber': pageNumber, 'Pagesize': pageSize},
    );
    return (resp as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    final path = EndPoints.withParams(EndPoints.chatConversation, {
      'conversationId': conversationId,
    });
    final resp = await api.get(path);
    return (resp as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteConversation(String conversationId) async {
    final path = EndPoints.withParams(EndPoints.chatConversation, {
      'conversationId': conversationId,
    });
    final resp = await api.delete(path);
    return (resp as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getConversationMessages({
    required String conversationId,
    int? count,
  }) async {
    // Workaround: The conversation/{id} endpoint has a circular reference bug on the backend
    // So we fetch from conversations list and filter by conversationId
    final resp = await api.get(
      EndPoints.chatConversations,
      queryParameters: {
        'Pagenumber': 1,
        'Pagesize': 100, // Get enough to find the conversation
      },
    );

    final map = (resp as Map).cast<String, dynamic>();
    final items = (map['items'] as List?) ?? [];

    // Find the conversation with matching conversationId
    final conversation = items.firstWhere(
      (item) => item['conversationId'] == conversationId,
      orElse: () => <String, dynamic>{},
    );

    // Return the messages from that conversation
    return {'items': conversation['messages'] ?? []};
  }
}
