/// Model for legal articles
class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final String authorAvatar;
  final DateTime publishDate;
  final int likes;
  final int comments;
  final List<String> tags;
  final bool isPublished;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorName,
    required this.authorAvatar,
    required this.publishDate,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
    this.isPublished = true,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'general',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      publishDate: DateTime.parse(
        json['publishDate'] ?? DateTime.now().toIso8601String(),
      ),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isPublished: json['isPublished'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'publishDate': publishDate.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'tags': tags,
      'isPublished': isPublished,
    };
  }

  ArticleModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? authorName,
    String? authorAvatar,
    DateTime? publishDate,
    int? likes,
    int? comments,
    List<String>? tags,
    bool? isPublished,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      publishDate: publishDate ?? this.publishDate,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
