import 'dart:convert';

class ChatMessageModel {
  final int? id;
  final String?
  conversationId; // Note: backend sometimes returns int id for conv in nested items
  final String role; // "user" | "assistant"
  final String content;
  final Map<String, dynamic>? metadata;
  final bool? needsClarification;
  final DateTime? createdAt;

  ChatMessageModel({
    this.id,
    this.conversationId,
    required this.role,
    required this.content,
    this.metadata,
    this.needsClarification,
    this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? parsedMetadata;
    final meta = map['metadata'];
    if (meta is String) {
      try {
        parsedMetadata = json.decode(meta) as Map<String, dynamic>;
      } catch (_) {
        parsedMetadata = {'raw': meta};
      }
    } else if (meta is Map<String, dynamic>) {
      parsedMetadata = meta;
    }

    return ChatMessageModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      conversationId: map['conversationId']?.toString(),
      role: (map['role'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      metadata: parsedMetadata,
      needsClarification: map['needsClarification'] as bool?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}

class ConversationModel {
  final int? id; // sometimes appears as int in nested messages
  final String conversationId; // main identifier as string
  final String? userId;
  final String? title;
  final String? language;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final bool? isActive;
  final int? messageCount;
  final List<ChatMessageModel> messages;

  ConversationModel({
    this.id,
    required this.conversationId,
    this.userId,
    this.title,
    this.language,
    this.createdAt,
    this.lastMessageAt,
    this.isActive,
    this.messageCount,
    this.messages = const [],
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    final msgs =
        (map['messages'] as List?)
            ?.map((e) => ChatMessageModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
        const <ChatMessageModel>[];

    return ConversationModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      conversationId: (map['conversationId'] ?? map['id'] ?? '').toString(),
      userId: map['userId']?.toString(),
      title: map['title']?.toString(),
      language: map['language']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt'].toString())
          : null,
      isActive: map['isActive'] as bool?,
      messageCount: map['messageCount'] is int
          ? map['messageCount'] as int
          : int.tryParse('${map['messageCount']}'),
      messages: msgs,
    );
  }
}

class PagedResult<T> {
  final List<T> items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrevious;

  PagedResult({
    required this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
    this.hasNext,
    this.hasPrevious,
  });

  static PagedResult<R> fromMap<R>(
    Map<String, dynamic> map,
    R Function(Map<String, dynamic>) itemFactory,
  ) {
    final rawItems = (map['items'] as List?) ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(itemFactory)
        .toList();
    return PagedResult<R>(
      items: items,
      pageNumber: _toInt(map['pageNumber']),
      pageSize: _toInt(map['pageSize']),
      totalCount: _toInt(map['totalCount']),
      totalPages: _toInt(map['totalPages']),
      hasNext: map['hasNext'] as bool?,
      hasPrevious: map['hasPrevious'] as bool?,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
