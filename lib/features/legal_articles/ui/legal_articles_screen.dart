import 'package:fahman_app/core/shared/widgets/shared_ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_state.dart';
import 'package:fahman_app/features/legal_articles/ui/widgets/category_tabs.dart';
import 'package:fahman_app/features/legal_articles/ui/widgets/article_card.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalArticlesScreen extends StatefulWidget {
  const LegalArticlesScreen({super.key});

  @override
  State<LegalArticlesScreen> createState() => _LegalArticlesScreenState();
}

class _LegalArticlesScreenState extends State<LegalArticlesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticlesCubit>().loadCategories();
      context.read<ArticlesCubit>().loadArticles();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ArticlesCubit>().loadMoreArticles();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'legal_articles_title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ArticlesCubit, ArticlesState>(
        listener: (context, state) {
          if (state.categoryError != null &&
              (state.categoryError == 'NO_INTERNET' ||
                  state.categoryError == 'CONNECTION_TIMEOUT' ||
                  state.categoryError == 'NETWORK_ERROR')) {
            _showCategoryErrorDialog(context, state.categoryError!);
          }
        },
        child: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, articlesState) {
            final articlesCubit = context.read<ArticlesCubit>();
            return Column(
              children: [
                CategoryTabs(
                  articlesCubit: articlesCubit,
                  categories: articlesState.categories,
                  isLoading: articlesState.isLoadingCategories,
                  selectedCategoryId: articlesState.selectedCategoryId,
                ),
                Expanded(
                  child:
                      articlesState.isLoading && articlesState.articles.isEmpty
                      ? SharedUIWidgets.customLoadingIndicator(
                          text: 'loading_articles'.tr(),
                        )
                      : _buildArticlesFeed(articlesCubit, articlesState),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticlesFeed(
    ArticlesCubit articlesCubit,
    ArticlesState articlesState,
  ) {
    final articles = articlesCubit.articlesByCategory;

    if (articles.isEmpty && !articlesState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.white54, size: 64.sp),
            SizedBox(height: 16.h),
            Text(
              'no_articles_found'.tr(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: articles.length + (articlesState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= articles.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: CircularProgressIndicator(color: AppColors.brand800),
            ),
          );
        }

        final article = articles[index];
        final isLiked = articlesState.likedArticleIds.contains(article.id);
        return ArticleCard(
          article: article,
          articlesCubit: articlesCubit,
          isLiked: isLiked,
        );
      },
    );
  }

  void _showCategoryErrorDialog(BuildContext context, String errorType) {
    String title;
    String message;

    switch (errorType) {
      case 'NO_INTERNET':
        title = 'connection_error'.tr();
        message = 'no_internet_connection'.tr();
        break;
      case 'CONNECTION_TIMEOUT':
        title = 'connection_error'.tr();
        message = 'connection_timeout'.tr();
        break;
      case 'NETWORK_ERROR':
        title = 'connection_error'.tr();
        message = 'failed_to_load_document'.tr();
        break;
      case 'SERVER_ERROR':
        title = 'error_occurred'.tr();
        message = 'server_error'.tr();
        break;
      case 'CATEGORIES_NOT_FOUND':
        title = 'error_occurred'.tr();
        message = 'no_categories_available'.tr();
        break;
      default:
        title = 'error_occurred'.tr();
        message = errorType;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red[400], size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ArticlesCubit>().loadCategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'retry'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
