import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/app_logger.dart';

class EngagementStats extends StatelessWidget {
  final int articleId;
  final String articleTitle;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const EngagementStats({
    super.key,
    required this.articleId,
    required this.articleTitle,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like button
        GestureDetector(
          onTap: () {
            AppLogger.d('UI: Like button tapped for article $articleId');
            onLikeTap();
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
                '$likeCount',
                style: TextStyle(
                  color: isLiked ? Colors.red : Colors.grey[400],
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        // Comment button
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.articleComments,
              arguments: {'articleId': articleId, 'articleTitle': articleTitle},
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
                '$commentCount',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
