/// API response models for Article endpoints
class ArticleResponseModel {
  final int id;
  final String title;
  final String contentPreview;
  final String? featuredImageUrl;
  final List<String> mediaUrls;
  final DateTime publishDate;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final ArticleAuthor author;
  final List<ArticleCategory> categories;

  ArticleResponseModel({
    required this.id,
    required this.title,
    required this.contentPreview,
    this.featuredImageUrl,
    required this.mediaUrls,
    required this.publishDate,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.author,
    required this.categories,
  });

  factory ArticleResponseModel.fromJson(Map<String, dynamic> json) {
    final List<String> media = (json['mediaUrls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final String? featured = (json['featuredImageUrl'] as String?) ??
        (media.isNotEmpty ? media.first : null);

    return ArticleResponseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      contentPreview: json['contentPreview'] ?? '',
      featuredImageUrl: featured,
      mediaUrls: media,
      publishDate: json['publishDate'] != null
          ? DateTime.parse(json['publishDate'])
          : DateTime.now(),
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      author: ArticleAuthor.fromJson(json['author'] ?? {}),
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((c) => ArticleCategory.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contentPreview': contentPreview,
      'featuredImageUrl': featuredImageUrl,
      'mediaUrls': mediaUrls,
      'publishDate': publishDate.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'author': author.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }
}

class ArticleAuthor {
  final String id;
  final String email;
  final String? imageUrl;

  ArticleAuthor({required this.id, required this.email, this.imageUrl});

  factory ArticleAuthor.fromJson(Map<String, dynamic> json) {
    return ArticleAuthor(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'imageUrl': imageUrl};
  }
}

class ArticleCategory {
  final int id;
  final String name;
  final int articleCount;
  final DateTime createdAt;

  ArticleCategory({
    required this.id,
    required this.name,
    required this.articleCount,
    required this.createdAt,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      articleCount: json['articleCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'articleCount': articleCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PaginatedArticlesResponse {
  final List<ArticleResponseModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;

  PaginatedArticlesResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory PaginatedArticlesResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedArticlesResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ArticleResponseModel.fromJson(item))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasPrevious: json['hasPrevious'] ?? false,
      hasNext: json['hasNext'] ?? false,
    );
  }
}
