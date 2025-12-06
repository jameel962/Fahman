import 'package:equatable/equatable.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/core/models/category_model.dart';

class ArticlesState extends Equatable {
  final bool isLoading;
  final bool isLoadingCategories;
  final String? error;
  final String? categoryError;
  final List<ArticleResponseModel> articles;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final Set<int> likedArticleIds; // Track which articles are liked

  const ArticlesState({
    this.isLoading = false,
    this.isLoadingCategories = false,
    this.error,
    this.categoryError,
    this.articles = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.likedArticleIds = const {},
  });

  ArticlesState copyWith({
    bool? isLoading,
    bool? isLoadingCategories,
    String? error,
    String? categoryError,
    List<ArticleResponseModel>? articles,
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    bool clearSelectedCategory = false, // NEW: explicit flag to clear
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    Set<int>? likedArticleIds,
  }) {
    return ArticlesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      error: error,
      categoryError: categoryError,
      articles: articles ?? this.articles,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      likedArticleIds: likedArticleIds ?? this.likedArticleIds,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingCategories,
    error,
    categoryError,
    articles,
    categories,
    selectedCategoryId,
    currentPage,
    totalPages,
    hasMore,
    likedArticleIds,
  ];
}
