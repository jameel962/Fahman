import 'package:flutter/foundation.dart';
import 'package:fahman_app/core/models/article_model.dart';

/// Provider for managing articles
class ArticlesProvider extends ChangeNotifier {
  List<ArticleModel> _articles = [];
  bool _isLoading = false;
  String _selectedCategory = 'general';

  List<ArticleModel> get articles => _articles;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  /// Get articles by category
  List<ArticleModel> get articlesByCategory {
    if (_selectedCategory == 'all') {
      return _articles.where((article) => article.isPublished).toList();
    }
    return _articles
        .where(
          (article) =>
              article.category == _selectedCategory && article.isPublished,
        )
        .toList();
  }

  /// Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Add new article
  void addArticle(ArticleModel article) {
    _articles.insert(0, article);
    notifyListeners();
  }

  /// Update article
  void updateArticle(ArticleModel article) {
    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _articles[index] = article;
      notifyListeners();
    }
  }

  /// Delete article
  void deleteArticle(String articleId) {
    _articles.removeWhere((article) => article.id == articleId);
    notifyListeners();
  }

  /// Like article
  void likeArticle(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        likes: _articles[index].likes + 1,
      );
      notifyListeners();
    }
  }

  /// Unlike article
  void unlikeArticle(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        likes: (_articles[index].likes - 1).clamp(0, double.infinity).toInt(),
      );
      notifyListeners();
    }
  }

  /// Add comment to article
  void addComment(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        comments: _articles[index].comments + 1,
      );
      notifyListeners();
    }
  }

  /// Load sample articles (for demo purposes)
  void loadSampleArticles() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      _articles = [
        ArticleModel(
          id: '1',
          title: 'حقوق العمال في القانون الأردني',
          content:
              'يضمن القانون الأردني للعمال العديد من الحقوق الأساسية التي يجب على كل عامل معرفتها...',
          category: 'political',
          authorName: 'أحمد المحامي',
          authorAvatar: '', // إزالة الأفاتار لتجنب مشاكل التحميل
          publishDate: DateTime.now().subtract(const Duration(hours: 2)),
          likes: 15,
          comments: 3,
          tags: ['حقوق العمال', 'قانون العمل', 'الأردن'],
        ),
        ArticleModel(
          id: '2',
          title: 'الضرائب والرسوم في الأردن',
          content:
              'نظام الضرائب في الأردن يخضع لقوانين محددة يجب على كل مواطن فهمها...',
          category: 'economic',
          authorName: 'فاطمة القانونية',
          authorAvatar: '', // إزالة الأفاتار لتجنب مشاكل التحميل
          publishDate: DateTime.now().subtract(const Duration(days: 1)),
          likes: 8,
          comments: 1,
          tags: ['ضرائب', 'اقتصاد', 'الأردن'],
        ),
        ArticleModel(
          id: '3',
          title: 'قانون المالكين والمستأجرين',
          content:
              'القانون الأردني ينظم العلاقة بين المالك والمستأجر بشكل واضح...',
          category: 'general',
          authorName: 'محمد المحامي',
          authorAvatar: '', // إزالة الأفاتار لتجنب مشاكل التحميل
          publishDate: DateTime.now().subtract(const Duration(days: 3)),
          likes: 22,
          comments: 5,
          tags: ['إيجار', 'ملكية', 'عقود'],
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Publish article
  void publishArticle({
    required String title,
    required String content,
    required String category,
    required String authorName,
    required String authorAvatar,
    List<String> tags = const [],
  }) {
    final article = ArticleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      category: category,
      authorName: authorName,
      authorAvatar: authorAvatar,
      publishDate: DateTime.now(),
      tags: tags,
    );

    addArticle(article);
  }
}
