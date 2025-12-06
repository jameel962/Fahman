/// Like model for API responses
class LikeModel {
  final int id;
  final int articleId;
  final String userId;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] ?? 0,
      articleId: json['articleId'] ?? 0,
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
