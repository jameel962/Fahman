import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_state.dart';
import 'package:fahman_app/features/legal_articles/ui/widgets/engagement_stats.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleResponseModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildAuthorSection(),
                  SizedBox(height: 20.h),
                  _buildTitle(),
                  if (article.categories.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildCategoryChips(),
                  ],
                  SizedBox(height: 20.h),
                  _buildDivider(),
                  SizedBox(height: 20.h),
                  _buildFullContent(),
                  if (article.mediaUrls.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildMediaGallery(),
                  ] else if (article.featuredImageUrl != null &&
                      article.featuredImageUrl!.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildFeaturedImage(),
                  ],
                  SizedBox(height: 24.h),
                  _buildDivider(),
                  SizedBox(height: 16.h),
                  _buildEngagementSection(context),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final bool hasImage =
        article.featuredImageUrl != null &&
        article.featuredImageUrl!.isNotEmpty;

    return SliverAppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      expandedHeight: hasImage ? 250.h : 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: hasImage
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.featuredImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF262626),
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                          size: 48.sp,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                          const Color(0xFF1A1A1A),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildAuthorSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: const Color(0xFFB4B2FF),
          backgroundImage:
              article.author.imageUrl != null &&
                  article.author.imageUrl!.isNotEmpty
              ? NetworkImage(article.author.imageUrl!)
              : null,
          child:
              article.author.imageUrl == null ||
                  article.author.imageUrl!.isEmpty
              ? Icon(Icons.person, color: Colors.white, size: 24.sp)
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
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey[500],
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatFullDate(article.publishDate),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.visibility_outlined,
                    color: Colors.grey[500],
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${article.viewCount} ${'views'.tr()}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      article.title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: article.categories.map((cat) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Text(
            cat.name,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1);
  }

  Widget _buildFullContent() {
    return Text(
      article.contentPreview,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 17.sp,
        height: 1.8,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildMediaGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'media'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        ...article.mediaUrls.map((url) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[600],
                      size: 48.sp,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        article.featuredImageUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[600],
              size: 48.sp,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEngagementSection(BuildContext context) {
    return BlocBuilder<ArticlesCubit, ArticlesState>(
      builder: (context, state) {
        final isLiked = state.likedArticleIds.contains(article.id);
        final cubit = context.read<ArticlesCubit>();

        // Find the latest article data from state (like count may have changed)
        final latestArticle = state.articles.firstWhere(
          (a) => a.id == article.id,
          orElse: () => article,
        );

        return EngagementStats(
          articleId: latestArticle.id,
          articleTitle: latestArticle.title,
          likeCount: latestArticle.likeCount,
          commentCount: latestArticle.commentCount,
          isLiked: isLiked,
          onLikeTap: () => cubit.toggleLike(article.id),
        );
      },
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
