import 'package:fahman_app/core/shared/widgets/shared_ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_state.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/core/models/category_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahman_app/app_logger.dart';

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
      context
          .read<ArticlesCubit>()
          .loadCategories(); // Load categories from API
      context.read<ArticlesCubit>().loadArticles();
    });

    // Add scroll listener for pagination
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
          // Show error dialog for category loading errors
          if (state.categoryError != null &&
              (state.categoryError == 'NO_INTERNET' ||
                  state.categoryError == 'CONNECTION_TIMEOUT' ||
                  state.categoryError == 'NETWORK_ERROR')) {
            _showCategoryErrorDialog(context, state.categoryError!);
          }
        },
        child: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, articlesState) {
            return Column(
              children: [
                _buildCategoryTabs(context.read<ArticlesCubit>()),
                Expanded(
                  child:
                      articlesState.isLoading && articlesState.articles.isEmpty
                      ? SharedUIWidgets.customLoadingIndicator(
                          text: 'loading_articles'.tr(),
                        )
                      : _buildArticlesFeed(
                          context.read<ArticlesCubit>(),
                          articlesState,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ArticlesCubit articlesCubit) {
    final categories = articlesCubit.state.categories;
    final isLoadingCategories = articlesCubit.state.isLoadingCategories;

    if (isLoadingCategories) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.brand800,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Center(
          child: Text(
            'no_categories_available'.tr(),
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // "All" category button
            _buildCategoryTab(
              articlesCubit,
              null, // null = show all
              'general_category',
            ),
            SizedBox(width: 12.w),
            // API categories
            ...categories.map((category) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildCategoryTabFromModel(articlesCubit, category),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(
    ArticlesCubit articlesCubit,
    int? categoryId,
    String translationKey,
  ) {
    final isSelected = articlesCubit.state.selectedCategoryId == categoryId;

    return GestureDetector(
      onTap: () {
        articlesCubit.setSelectedCategory(categoryId);
      },
      child: isSelected
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.voicePillGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626).withOpacity(0.86),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  translationKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                translationKey.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryTabFromModel(
    ArticlesCubit articlesCubit,
    CategoryModel category,
  ) {
    final isSelected = articlesCubit.state.selectedCategoryId == category.id;
    // API returns Arabic names in the 'name' field (name_Ar is null)
    final categoryName = category.name;

    return GestureDetector(
      onTap: () {
        articlesCubit.setSelectedCategory(category.id);
      },
      child: isSelected
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.voicePillGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626).withOpacity(0.86),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  categoryName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
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
        return _buildArticleCard(article, articlesCubit);
      },
    );
  }

  Widget _buildArticleCard(
    ArticleResponseModel article,
    ArticlesCubit articlesCubit,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFB4B2FF),
                backgroundImage:
                    article.author.imageUrl != null &&
                        article.author.imageUrl!.isNotEmpty
                    ? NetworkImage(article.author.imageUrl!)
                    : null,
                child:
                    article.author.imageUrl == null ||
                        article.author.imageUrl!.isEmpty
                    ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.author.email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(article.publishDate),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            article.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            article.contentPreview,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, height: 1.5),
          ),
          if (article.mediaUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 160.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: article.mediaUrls.length > 5
                    ? 5
                    : article.mediaUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, idx) {
                  final url = article.mediaUrls[idx];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      url,
                      width: 240.w,
                      height: 160.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 240.w,
                          height: 160.h,
                          color: Colors.grey[800],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[600],
                            size: 32.sp,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ] else if (article.featuredImageUrl != null &&
              article.featuredImageUrl!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                article.featuredImageUrl!,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200.h,
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[600],
                      size: 48.sp,
                    ),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 12.h),
          _buildEngagementStats(article, articlesCubit),
        ],
      ),
    );
  }

  Widget _buildEngagementStats(
    ArticleResponseModel article,
    ArticlesCubit articlesCubit,
  ) {
    final isLiked = articlesCubit.state.likedArticleIds.contains(article.id);

    // Log the current state for debugging
    AppLogger.d(
      'UI: Building engagement stats for article ${article.id}, isLiked=$isLiked, likeCount=${article.likeCount}',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like button
        GestureDetector(
          onTap: () {
            AppLogger.d('UI: Like button tapped for article ${article.id}');
            articlesCubit.toggleLike(article.id);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey[400],
                size: 20.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '${article.likeCount}',
                style: TextStyle(
                  color: isLiked ? Colors.red : Colors.grey[400],
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        // Comment button - Navigate to comments screen
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.articleComments,
              arguments: {
                'articleId': article.id,
                'articleTitle': article.title,
              },
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey[400],
                size: 20.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '${article.commentCount}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
            ],
          ),
        ),
        // Share button
        // GestureDetector(
        //   onTap: () {
        //     ScaffoldMessenger.of(
        //       context,
        //     ).showSnackBar(SnackBar(content: Text('تم المشاركة')));
        //   },
        //   child: Icon(Icons.send, color: Colors.grey[400], size: 20.sp),
        // ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${'days_ago'.tr()}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${'hours_ago'.tr()}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${'minutes_ago'.tr()}';
    } else {
      return 'just_now'.tr();
    }
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
