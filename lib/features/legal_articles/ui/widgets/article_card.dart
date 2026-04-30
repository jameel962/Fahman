import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';
import 'package:fahman_app/features/legal_articles/ui/widgets/engagement_stats.dart';
import 'package:fahman_app/core/services/routes.dart';

class ArticleCard extends StatelessWidget {
  final ArticleResponseModel article;
  final ArticlesCubit articlesCubit;
  final bool isLiked;

  const ArticleCard({
    super.key,
    required this.article,
    required this.articlesCubit,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(Routes.articleDetail, arguments: article);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorRow(),
            SizedBox(height: 12.h),
            _buildTitle(),
            SizedBox(height: 8.h),
            _buildContentPreview(),
            if (article.mediaUrls.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _buildMediaGallery(),
            ] else if (article.featuredImageUrl != null &&
                article.featuredImageUrl!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _buildFeaturedImage(),
            ],
            SizedBox(height: 12.h),
            EngagementStats(
              articleId: article.id,
              articleTitle: article.title,
              likeCount: article.likeCount,
              commentCount: article.commentCount,
              isLiked: isLiked,
              onLikeTap: () => articlesCubit.toggleLike(article.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
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
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
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
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildContentPreview() {
    return Text(
      article.contentPreview,
      style: TextStyle(color: Colors.white, fontSize: 16.sp, height: 1.5),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMediaGallery() {
    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: article.mediaUrls.length > 5 ? 5 : article.mediaUrls.length,
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
    );
  }

  Widget _buildFeaturedImage() {
    return ClipRRect(
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
