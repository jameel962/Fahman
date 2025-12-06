import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/models/comment_model.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';
import 'package:fahman_app/app_logger.dart';

class ArticleCommentsScreen extends StatefulWidget {
  final int articleId;
  final String articleTitle;

  const ArticleCommentsScreen({
    super.key,
    required this.articleId,
    required this.articleTitle,
  });

  @override
  State<ArticleCommentsScreen> createState() => _ArticleCommentsScreenState();
}

class _ArticleCommentsScreenState extends State<ArticleCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isLoadingComments = true;
  bool _isSendingComment = false;
  List<CommentModel> _comments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
      _errorMessage = null;
    });

    try {
      final comments = await context
          .read<ArticlesCubit>()
          .repository
          .getArticleComments(widget.articleId);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('comment_empty'.tr())));
      return;
    }

    // Prevent multiple submissions
    if (_isSendingComment) {
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      await context.read<ArticlesCubit>().addComment(
        widget.articleId,
        content: content,
      );

      _commentController.clear();
      _commentFocusNode.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('comment_added_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      // Reload comments
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('comment_add_failed'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
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
          'comments_title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Article title
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              widget.articleTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Comments list
          Expanded(
            child: _isLoadingComments
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.brand800),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'error_loading_comments'.tr(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: _loadComments,
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  )
                : _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white54,
                          size: 64.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'no_comments_yet'.tr(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'be_first_to_comment'.tr(),
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadComments,
                    color: AppColors.brand800,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return _buildCommentItem(_comments[index]);
                      },
                    ),
                  ),
          ),

          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  final hasImageUrl =
                      comment.user.imageUrl != null &&
                      comment.user.imageUrl!.isNotEmpty;

                  // Log avatar loading attempt
                  if (hasImageUrl) {
                    AppLogger.d(
                      'Loading avatar for ${comment.user.username ?? comment.user.email}: ${comment.user.imageUrl}',
                    );
                  } else {
                    AppLogger.d(
                      'No avatar URL for ${comment.user.username ?? comment.user.email}',
                    );
                  }

                  return CircleAvatar(
                    radius: 16.r,
                    backgroundColor: const Color(0xFFB4B2FF),
                    backgroundImage: hasImageUrl
                        ? NetworkImage(comment.user.imageUrl!)
                        : null,
                    onBackgroundImageError: hasImageUrl
                        ? (exception, stackTrace) {
                            AppLogger.e(
                              '❌ Failed to load avatar: ${comment.user.imageUrl}',
                            );
                            AppLogger.e('   Error: $exception');
                          }
                        : null,
                    child: !hasImageUrl
                        ? Icon(Icons.person, color: Colors.white, size: 16.sp)
                        : null,
                  );
                },
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user.username ?? comment.user.email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            comment.content,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
                decoration: InputDecoration(
                  hintText: 'write_comment'.tr(),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _isSendingComment ? null : _submitComment,
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  gradient: _isSendingComment
                      ? null
                      : LinearGradient(
                          colors: AppColors.voicePillGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: _isSendingComment ? Colors.grey : null,
                  shape: BoxShape.circle,
                ),
                child: _isSendingComment
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.send, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
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
}
