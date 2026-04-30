import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/models/category_model.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';

class CategoryTabs extends StatelessWidget {
  final ArticlesCubit articlesCubit;
  final List<CategoryModel> categories;
  final bool isLoading;
  final int? selectedCategoryId;

  const CategoryTabs({
    super.key,
    required this.articlesCubit,
    required this.categories,
    required this.isLoading,
    required this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
            _buildTab(
              label: 'general_category'.tr(),
              isSelected: selectedCategoryId == null,
              onTap: () => articlesCubit.setSelectedCategory(null),
            ),
            SizedBox(width: 12.w),
            ...categories.map((category) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildTab(
                  label: category.name,
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => articlesCubit.setSelectedCategory(category.id),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                  color: const Color(0xFF262626).withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  label,
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
                label,
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
}
