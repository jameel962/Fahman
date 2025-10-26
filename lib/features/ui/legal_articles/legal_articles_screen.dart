import 'package:fahman_app/shared/widgets/shared_ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/routing/routes.dart';
import 'package:fahman_app/features/logic/articles/articles_provider.dart';
import 'package:fahman_app/core/models/article_model.dart';

class LegalArticlesScreen extends StatefulWidget {
  const LegalArticlesScreen({super.key});

  @override
  State<LegalArticlesScreen> createState() => _LegalArticlesScreenState();
}

class _LegalArticlesScreenState extends State<LegalArticlesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticlesProvider>().loadSampleArticles();
    });
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
      body: Consumer<ArticlesProvider>(
        builder: (context, articlesProvider, child) {
          return Column(
            children: [
              _buildCategoryTabs(articlesProvider),
              _buildPostInput(),
              Expanded(
                child: articlesProvider.isLoading
                    ? SharedUIWidgets.customLoadingIndicator(
                        text: 'جاري تحميل المقالات...',
                      )
                    : _buildArticlesFeed(articlesProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs(ArticlesProvider articlesProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryTab(
            articlesProvider,
            'political',
            'political_category'.tr(),
          ),
          _buildCategoryTab(
            articlesProvider,
            'economic',
            'economic_category'.tr(),
          ),
          _buildCategoryTab(
            articlesProvider,
            'general',
            'general_category'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
    ArticlesProvider articlesProvider,
    String category,
    String title,
  ) {
    final isSelected = articlesProvider.selectedCategory == category;
    return GestureDetector(
      onTap: () {
        articlesProvider.setSelectedCategory(category);
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
                  title,
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
                title,
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

  Widget _buildPostInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: const Color(0xFFB4B2FF),
            child: Icon(Icons.person, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.createArticle);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  enabled: false, 
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: 'whats_on_your_mind'.tr(),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.createArticle);
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate,
                color: Colors.grey[400],
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesFeed(ArticlesProvider articlesProvider) {
    final articles = articlesProvider.articlesByCategory;

    if (articles.isEmpty) {
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
            SizedBox(height: 8.h),
            Text(
              'be_first_to_publish'.tr(),
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildArticleCard(article);
      },
    );
  }

  Widget _buildArticleCard(ArticleModel article) {
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
                backgroundImage: article.authorAvatar.isNotEmpty
                    ? AssetImage(article.authorAvatar)
                    : null,
                child: article.authorAvatar.isEmpty
                    ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.authorName,
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
            article.content,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, height: 1.5),
          ),
          SizedBox(height: 8.h),
          SizedBox(height: 12.h),
          _buildEngagementStats(article),
        ],
      ),
    );
  }


  Widget _buildEngagementStats(ArticleModel article) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            context.read<ArticlesProvider>().likeArticle(article.id);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, color: Colors.grey[400], size: 20.sp),
              SizedBox(width: 4.w),
              Text(
                '${article.likes}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<ArticlesProvider>().addComment(article.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('تم إضافة تعليق')));
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
                '${article.comments}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
            ],
          ),
        ),
        // مشاركة
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('تم المشاركة')));
          },
          child: Icon(Icons.send, color: Colors.grey[400], size: 20.sp),
        ),
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
}
