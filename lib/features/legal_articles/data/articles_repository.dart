import 'package:dio/dio.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/core/models/comment_model.dart';
import 'package:fahman_app/core/models/category_model.dart';
import 'package:fahman_app/core/networking/api_service.dart';
import 'package:fahman_app/app_logger.dart';

class ArticlesRepository {
  final ApiService _apiService;

  ArticlesRepository(this._apiService);

  /// Fetch categories from API
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      AppLogger.d('ArticlesRepository.fetchCategories - calling API');
      final response = await _apiService.getCategories();
      AppLogger.d('✅ Fetched ${response.length} categories from API');
      return response;
    } on DioException catch (e) {
      AppLogger.e('❌ Categories API failed with DioException: ${e.type}');
      rethrow;
    } catch (e) {
      AppLogger.e('ArticlesRepository.fetchCategories error: $e');
      rethrow;
    }
  }

  /// Fetch articles with optional filters
  Future<PaginatedArticlesResponse> fetchArticles({
    int? categoryId,
    String? authorId,
    String? searchTerm,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    bool? sortDescending,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      AppLogger.d('ArticlesRepository.fetchArticles - calling API');
      return await _apiService.getArticles(
        categoryId: categoryId,
        authorId: authorId,
        searchTerm: searchTerm,
        fromDate: fromDate,
        toDate: toDate,
        sortBy: sortBy,
        sortDescending: sortDescending,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      AppLogger.e('ArticlesRepository.fetchArticles error: $e');
      rethrow;
    }
  }

  /// Toggle like on an article
  Future<void> toggleLike(int articleId) async {
    try {
      AppLogger.d('ArticlesRepository.toggleLike - articleId: $articleId');
      await _apiService.toggleLike(articleId);
    } catch (e) {
      AppLogger.e('ArticlesRepository.toggleLike error: $e');
      rethrow;
    }
  }

  /// Get like count for an article
  Future<int> getLikeCount(int articleId) async {
    try {
      AppLogger.d('ArticlesRepository.getLikeCount - articleId: $articleId');
      return await _apiService.getLikeCount(articleId);
    } catch (e) {
      AppLogger.e('ArticlesRepository.getLikeCount error: $e');
      rethrow;
    }
  }

  /// Check if user has liked an article
  Future<bool> checkIfLiked(int articleId) async {
    try {
      AppLogger.d('ArticlesRepository.checkIfLiked - articleId: $articleId');
      return await _apiService.checkIfLiked(articleId);
    } catch (e) {
      AppLogger.e('ArticlesRepository.checkIfLiked error: $e');
      rethrow;
    }
  }

  /// Create a comment on an article
  Future<CommentModel> createComment({
    required int articleId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      AppLogger.d('ArticlesRepository.createComment - articleId: $articleId');
      return await _apiService.createComment(
        articleId: articleId,
        content: content,
        parentCommentId: parentCommentId,
      );
    } catch (e) {
      AppLogger.e('ArticlesRepository.createComment error: $e');
      rethrow;
    }
  }

  /// Get all comments for an article
  Future<List<CommentModel>> getArticleComments(int articleId) async {
    try {
      AppLogger.d(
        'ArticlesRepository.getArticleComments - articleId: $articleId',
      );
      return await _apiService.getArticleComments(articleId);
    } catch (e) {
      AppLogger.e('ArticlesRepository.getArticleComments error: $e');
      rethrow;
    }
  }

  /// Update a comment
  Future<CommentModel> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      AppLogger.d('ArticlesRepository.updateComment - commentId: $commentId');
      return await _apiService.updateComment(
        commentId: commentId,
        content: content,
      );
    } catch (e) {
      AppLogger.e('ArticlesRepository.updateComment error: $e');
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    try {
      AppLogger.d('ArticlesRepository.deleteComment - commentId: $commentId');
      await _apiService.deleteComment(commentId);
    } catch (e) {
      AppLogger.e('ArticlesRepository.deleteComment error: $e');
      rethrow;
    }
  }
}
