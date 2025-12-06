import 'package:dio/dio.dart';
import 'api/end_points.dart';
import '../../app_logger.dart';
import '../models/article_response_model.dart';
import '../models/comment_model.dart';
import '../models/like_model.dart';
import '../models/category_model.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options
      ..baseUrl = EndPoints.baseUrl
      ..responseType = ResponseType.json;
    // Add logging so POST/GET calls are printed consistently
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  // ==================== CATEGORIES ====================

  /// GET /api/Category
  Future<List<CategoryModel>> getCategories() async {
    AppLogger.d('ApiService.getCategories -> GET /api/Category');

    try {
      final response = await _dio.get('/api/Category');

      if (response.data is List) {
        final categories = (response.data as List)
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return categories;
      }

      return [];
    } catch (e) {
      AppLogger.e('ApiService.getCategories error: $e');
      rethrow;
    }
  }

  // ==================== ARTICLES ====================

  /// GET /api/Article
  Future<PaginatedArticlesResponse> getArticles({
    int? categoryId,
    String? authorId,
    String? searchTerm,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    bool? sortDescending,
    int? pageNumber,
    int? pageSize,
  }) async {
    AppLogger.d('ApiService.getArticles -> GET ${EndPoints.articles}');

    final queryParams = <String, dynamic>{};
    if (categoryId != null) queryParams['CategoryId'] = categoryId;
    if (authorId != null) queryParams['AuthorId'] = authorId;
    if (searchTerm != null) queryParams['SearchTerm'] = searchTerm;
    if (fromDate != null) queryParams['FromDate'] = fromDate.toIso8601String();
    if (toDate != null) queryParams['ToDate'] = toDate.toIso8601String();
    if (sortBy != null) queryParams['SortBy'] = sortBy;
    if (sortDescending != null) queryParams['SortDescending'] = sortDescending;
    if (pageNumber != null) queryParams['PageNumber'] = pageNumber;
    if (pageSize != null) queryParams['PageSize'] = pageSize;

    AppLogger.d('ApiService.getArticles query: ' + queryParams.toString());

    final response = await _dio.get(
      EndPoints.articles,
      queryParameters: queryParams,
    );

    AppLogger.d('ApiService.getArticles response: ${response.statusCode}');
    AppLogger.d('ApiService.getArticles body: ${response.data}');
    return PaginatedArticlesResponse.fromJson(response.data);
  }

  // ==================== COMMENTS ====================

  /// POST /api/Comment
  Future<CommentModel> createComment({
    required int articleId,
    required String content,
    int? parentCommentId,
  }) async {
    AppLogger.d('ApiService.createComment -> POST ${EndPoints.comments}');

    final body = {
      'articleId': articleId,
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    };

    final response = await _dio.post(EndPoints.comments, data: body);

    AppLogger.d('ApiService.createComment response: ${response.statusCode}');
    return CommentModel.fromJson(response.data);
  }

  /// PUT /api/Comment/{id}
  Future<CommentModel> updateComment({
    required int commentId,
    required String content,
  }) async {
    final endpoint = EndPoints.withParams(EndPoints.commentById, {
      'id': commentId,
    });
    AppLogger.d('ApiService.updateComment -> PUT $endpoint');

    final body = {'content': content};

    final response = await _dio.put(endpoint, data: body);

    AppLogger.d('ApiService.updateComment response: ${response.statusCode}');
    return CommentModel.fromJson(response.data);
  }

  /// DELETE /api/Comment/{id}
  Future<void> deleteComment(int commentId) async {
    final endpoint = EndPoints.withParams(EndPoints.commentById, {
      'id': commentId,
    });
    AppLogger.d('ApiService.deleteComment -> DELETE $endpoint');

    await _dio.delete(endpoint);

    AppLogger.d('ApiService.deleteComment response: success');
  }

  /// GET /api/Comment/{id}
  Future<CommentModel> getComment(int commentId) async {
    final endpoint = EndPoints.withParams(EndPoints.commentById, {
      'id': commentId,
    });
    AppLogger.d('ApiService.getComment -> GET $endpoint');

    final response = await _dio.get(endpoint);

    AppLogger.d('ApiService.getComment response: ${response.statusCode}');
    return CommentModel.fromJson(response.data);
  }

  /// GET /api/Comment/article/{articleId}
  Future<List<CommentModel>> getArticleComments(int articleId) async {
    final endpoint = EndPoints.withParams(EndPoints.commentsByArticle, {
      'articleId': articleId,
    });
    AppLogger.d('ApiService.getArticleComments -> GET $endpoint');

    final response = await _dio.get(endpoint);

    AppLogger.d(
      'ApiService.getArticleComments response: ${response.statusCode}',
    );

    // Log raw response data to check imageUrl
    AppLogger.d('ApiService.getArticleComments raw data: ${response.data}');

    final comments = (response.data as List<dynamic>).map((json) {
      final comment = CommentModel.fromJson(json);
      // Log each comment user's imageUrl
      AppLogger.d(
        'Comment user: username=${comment.user.username}, email=${comment.user.email}, imageUrl=${comment.user.imageUrl}',
      );
      return comment;
    }).toList();

    return comments;
  }

  // ==================== LIKES ====================

  /// POST /api/Like/toggle/{articleId}
  Future<LikeModel> toggleLike(int articleId) async {
    final endpoint = EndPoints.withParams(EndPoints.toggleLike, {
      'articleId': articleId,
    });
    AppLogger.d('ApiService.toggleLike -> POST $endpoint');

    final response = await _dio.post(endpoint);

    AppLogger.d('ApiService.toggleLike response: ${response.statusCode}');
    return LikeModel.fromJson(response.data);
  }

  /// GET /api/Like/count/{articleId}
  Future<int> getLikeCount(int articleId) async {
    final endpoint = EndPoints.withParams(EndPoints.likeCount, {
      'articleId': articleId,
    });
    AppLogger.d('ApiService.getLikeCount -> GET $endpoint');

    final response = await _dio.get(endpoint);

    AppLogger.d('ApiService.getLikeCount response: ${response.statusCode}');
    return response.data as int;
  }

  /// GET /api/Like/check/{articleId}
  Future<bool> checkIfLiked(int articleId) async {
    final endpoint = EndPoints.withParams(EndPoints.checkLike, {
      'articleId': articleId,
    });
    AppLogger.d('ApiService.checkIfLiked -> GET $endpoint');

    final response = await _dio.get(endpoint);

    AppLogger.d('ApiService.checkIfLiked response: ${response.statusCode}');
    return response.data as bool;
  }

  // ==================== AUTH (existing) ====================

  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String userId,
  }) async {
    AppLogger.d(
      'ApiService.verifyOtp -> POST ${EndPoints.verifyOtp} ?otp=$otp&userId=$userId',
    );
    final response = await _dio.post(
      EndPoints.verifyOtp,
      queryParameters: {'otp': otp, 'userId': userId},
    );
    AppLogger.d(
      'ApiService.verifyOtp response: ${response.statusCode} ${response.data}',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> reSendAuthOtp({
    required String identifier,
  }) async {
    AppLogger.d(
      'ApiService.reSendAuthOtp -> POST ${EndPoints.resendAuthOtp} ?Identifier=$identifier',
    );
    final response = await _dio.post(
      EndPoints.resendAuthOtp,
      queryParameters: {'Identifier': identifier},
    );
    AppLogger.d(
      'ApiService.reSendAuthOtp response: ${response.statusCode} ${response.data}',
    );
    return response.data;
  }
}
