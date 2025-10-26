import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/shared/widgets/shared_ui_widgets.dart';
import 'package:fahman_app/shared/widgets/dashed_border_painter.dart';
import 'package:fahman_app/features/logic/articles/articles_provider.dart';
import 'package:fahman_app/features/logic/auth/auth_provider.dart';

/// شاشة إنشاء مقال جديد
class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final TextEditingController _contentController = TextEditingController();
  int _maxChars = 100; // الحد الأقصى لعدد الأحرف
  String _selectedCategory = 'political'; // الفئة المختارة للمقال

  @override
  void dispose() {
    _contentController.dispose();
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
          'create_article'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserInfoSection(),

                    SizedBox(height: 20.h),

                    _buildCategorySection(),

                    SizedBox(height: 25.h),

                    _buildContentSection(),

                    SizedBox(height: 20.h),

                    _buildImageAttachmentSection(),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.w),
              child: _buildPublishButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// قسم معلومات المستخدم
  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFFB4B2FF),
            child: Icon(Icons.person, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Text(
            'داوود حجازي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// قسم اختيار فئة المقال
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'category'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryTab('political', 'political_category'.tr()),
              _buildCategoryTab('economic', 'economic_category'.tr()),
              _buildCategoryTab('general', 'general_category'.tr()),
            ],
          ),
        ),
      ],
    );
  }

  /// قسم كتابة محتوى المقال
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'article_content'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.brand600,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 335.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 218.h,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626).withOpacity(0.86),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          maxLength: _maxChars,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'whats_on_your_mind'.tr(),
                            hintStyle: TextStyle(
                              color: Colors.white60,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_contentController.text.length}/$_maxChars',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// قسم إرفاق الصور
  Widget _buildImageAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attach_image'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 335.w,
            height: 120.h,
            child: CustomPaint(
              foregroundPainter: DashedRRectPainter(
                color: AppColors.brand600,
                strokeWidth: 1.5,
                radius: 16.r,
                dashWidth: 6,
                dashGap: 4,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: const Color(0xFF262626).withOpacity(0.86),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('تم اختيار صورة')),
                                );
                              },
                              child: Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF262626,
                                  ).withOpacity(0.86),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.attach_file,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'attach_image_hint'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// زر نشر المقال
  Widget _buildPublishButton() {
    return SharedUIWidgets.publishButton(
      onTap: () {
        final authProvider = context.read<AuthProvider>();
        final userInfo = authProvider.userInfo;

        context.read<ArticlesProvider>().publishArticle(
          title: 'مقال جديد',
          content: _contentController.text,
          category: _selectedCategory,
          authorName: userInfo?.username ?? 'مستخدم',
          authorAvatar: '',
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('article_published'.tr())));
        Navigator.pop(context);
      },
    );
  }

  /// تبويب فئة المقال
  Widget _buildCategoryTab(String category, String title) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: SizedBox(
          width: 100.w,
          height: 38.h,
          child: isSelected
              ? Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [Color(0xFFB4B2FF), Color(0xFF9B7FFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(1.5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.5.r),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626).withOpacity(0.86),
                              borderRadius: BorderRadius.circular(18.5.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
