import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLanguageSelected;

  const LanguageSelector({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language options
          _buildLanguageOption(
            context: context,
            title: 'English',
            isSelected: context.locale.languageCode == 'en',
            onTap: () => onLanguageSelected(const Locale('en')),
          ),
          _buildDivider(),
          _buildLanguageOption(
            context: context,
            title: 'Arabic',
            isSelected: context.locale.languageCode == 'ar',
            onTap: () => onLanguageSelected(const Locale('ar')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check, color: Colors.white, size: 20.sp)
            else
              SizedBox(width: 20.w),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: Colors.grey[600],
    );
  }
}
