/// Comment model for API responses
class CommentModel {
  final int id;
  final int articleId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommentUser user;
  final int? parentCommentId;
  final List<String> replies;

  CommentModel({
    required this.id,
    required this.articleId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.parentCommentId,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      articleId: json['articleId'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: CommentUser.fromJson(json['user'] ?? {}),
      parentCommentId: json['parentCommentId'],
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'parentCommentId': parentCommentId,
      'replies': replies,
    };
  }
}

class CommentUser {
  final String id;
  final String email;
  final String? username;
  final String? imageUrl;

  CommentUser({
    required this.id,
    required this.email,
    this.username,
    this.imageUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? json['userName'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'imageUrl': imageUrl,
    };
  }
}

class CreateCommentRequest {
  final int articleId;
  final String content;
  final int? parentCommentId;

  CreateCommentRequest({
    required this.articleId,
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'content': content,
      'parentCommentId': parentCommentId,
    };
  }
}
