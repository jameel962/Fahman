import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_state.dart';
import 'package:fahman_app/features/legal_articles/data/articles_repository.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/app_logger.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final ArticlesRepository repository;

  ArticlesCubit({required this.repository}) : super(const ArticlesState());

  /// Load categories from API
  Future<void> loadCategories() async {
    emit(state.copyWith(isLoadingCategories: true, categoryError: null));
    try {
      AppLogger.d('ArticlesCubit.loadCategories - fetching from API');
      final categories = await repository.fetchCategories();

      AppLogger.d(
        'ArticlesCubit.loadCategories - loaded ${categories.length} categories',
      );

      // Log each category for debugging
      for (var cat in categories) {
        AppLogger.d(
          '  Category: id=${cat.id}, name=${cat.name}, count=${cat.articleCount}',
        );
      }

      emit(state.copyWith(isLoadingCategories: false, categories: categories));

      AppLogger.d(
        'ArticlesCubit.loadCategories - state updated, categories count in state: ${state.categories.length}',
      );
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'CONNECTION_TIMEOUT';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'NO_INTERNET';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'CATEGORIES_NOT_FOUND';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'SERVER_ERROR';
      } else {
        errorMessage = 'NETWORK_ERROR';
      }

      AppLogger.e('ArticlesCubit.loadCategories error: ${e.type}');
      emit(
        state.copyWith(isLoadingCategories: false, categoryError: errorMessage),
      );
    } catch (e) {
      AppLogger.e('ArticlesCubit.loadCategories error: $e');
      emit(
        state.copyWith(isLoadingCategories: false, categoryError: e.toString()),
      );
    }
  }

  /// Load articles with optional filters
  Future<void> loadArticles({
    int? categoryId,
    String? authorId,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      AppLogger.d('ArticlesCubit.loadArticles - categoryId: $categoryId');

      final response = await repository.fetchArticles(
        categoryId: categoryId ?? state.selectedCategoryId,
        authorId: authorId,
        searchTerm: searchTerm,
        pageNumber: pageNumber,
        pageSize: pageSize,
        sortBy: 'PublishDate',
        sortDescending: true,
      );

      // Check liked status for each article
      final likedArticles = <int>{};
      for (final article in response.items) {
        try {
          final isLiked = await repository.checkIfLiked(article.id);
          if (isLiked) {
            likedArticles.add(article.id);
          }
        } catch (e) {
          AppLogger.e(
            'Error checking like status for article ${article.id}: $e',
          );
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          articles: response.items,
          currentPage: response.pageNumber,
          totalPages: response.totalPages,
          hasMore: response.hasNext,
          likedArticleIds: likedArticles,
        ),
      );

      AppLogger.d(
        'ArticlesCubit.loadArticles - loaded ${response.items.length} articles',
      );
    } catch (e) {
      AppLogger.e('ArticlesCubit.loadArticles error: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load more articles (pagination)
  Future<void> loadMoreArticles() async {
    if (!state.hasMore || state.isLoading) return;

    try {
      AppLogger.d(
        'ArticlesCubit.loadMoreArticles - page: ${state.currentPage + 1}',
      );

      final response = await repository.fetchArticles(
        categoryId: state.selectedCategoryId,
        pageNumber: state.currentPage + 1,
        pageSize: 20,
        sortBy: 'PublishDate',
        sortDescending: true,
      );

      emit(
        state.copyWith(
          articles: [...state.articles, ...response.items],
          currentPage: response.pageNumber,
          totalPages: response.totalPages,
          hasMore: response.hasNext,
        ),
      );

      AppLogger.d(
        'ArticlesCubit.loadMoreArticles - total: ${state.articles.length}',
      );
    } catch (e) {
      AppLogger.e('ArticlesCubit.loadMoreArticles error: $e');
    }
  }

  /// Toggle like on an article
  Future<void> toggleLike(int articleId) async {
    try {
      AppLogger.d('ArticlesCubit.toggleLike - articleId: $articleId');

      // Optimistically update UI - just toggle the liked state
      final newLikedIds = Set<int>.from(state.likedArticleIds);
      final wasLiked = newLikedIds.contains(articleId);

      if (wasLiked) {
        newLikedIds.remove(articleId);
        AppLogger.d(
          'ArticlesCubit.toggleLike - UNLIKING article $articleId (optimistic)',
        );
      } else {
        newLikedIds.add(articleId);
        AppLogger.d(
          'ArticlesCubit.toggleLike - LIKING article $articleId (optimistic)',
        );
      }

      // Emit immediately for instant UI update
      emit(state.copyWith(likedArticleIds: newLikedIds));
      AppLogger.d(
        'ArticlesCubit.toggleLike - State emitted immediately, liked count: ${newLikedIds.length}',
      );

      // Call API in background - don't await to avoid delay
      repository
          .toggleLike(articleId)
          .then((_) {
            AppLogger.d(
              '✅ ArticlesCubit.toggleLike - API call success for article $articleId',
            );
          })
          .catchError((e) {
            AppLogger.e('❌ ArticlesCubit.toggleLike API error: $e');
            // Revert on error
            final revertedIds = Set<int>.from(state.likedArticleIds);
            if (wasLiked) {
              revertedIds.add(articleId);
            } else {
              revertedIds.remove(articleId);
            }
            emit(state.copyWith(likedArticleIds: revertedIds));
            AppLogger.d(
              'ArticlesCubit.toggleLike - State reverted due to error',
            );
          });
    } catch (e) {
      AppLogger.e('ArticlesCubit.toggleLike error: $e');
    }
  }

  /// Add a comment (create comment with empty content for now)
  Future<void> addComment(
    int articleId, {
    String content = 'تعليق جديد',
  }) async {
    try {
      AppLogger.d('ArticlesCubit.addComment - articleId: $articleId');
      await repository.createComment(articleId: articleId, content: content);

      // Refresh articles to get updated comment count
      await loadArticles(categoryId: state.selectedCategoryId);
    } catch (e) {
      AppLogger.e('ArticlesCubit.addComment error: $e');
    }
  }

  /// Set selected category and reload articles
  void setSelectedCategory(int? categoryId) {
    AppLogger.d('ArticlesCubit.setSelectedCategory - categoryId: $categoryId');
    if (categoryId == null) {
      // Use clearSelectedCategory flag to explicitly set to null
      emit(state.copyWith(clearSelectedCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryId: categoryId));
    }
    loadArticles(categoryId: categoryId);
  }

  /// Get articles filtered by current category
  List<ArticleResponseModel> get articlesByCategory {
    return state.articles;
  }
}
