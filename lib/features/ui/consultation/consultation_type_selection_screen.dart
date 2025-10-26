import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/routing/routes.dart';

class ConsultationTypeSelectionScreen extends StatelessWidget {
  const ConsultationTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            context.locale.languageCode == 'ar'
                ? Icons.arrow_back_ios
                : Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'feature_consultations_title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            Text(
              'consultation_type_selection_title'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: context.locale.languageCode == 'ar'
                  ? TextAlign.right
                  : TextAlign.left,
            ),
            SizedBox(height: 8.h),

            Text(
              'consultation_type_selection_subtitle'.tr(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: context.locale.languageCode == 'ar'
                  ? TextAlign.right
                  : TextAlign.left,
            ),
            SizedBox(height: 30.h),

            Expanded(
              child: ListView(
                children: [
                  _buildConsultationTypeCard(
                    context: context,
                    icon: Icons.gavel,
                    title: 'consultation_type_legal_title'.tr(),
                    description: 'consultation_type_legal_description'.tr(),
                    typeKey: 'consultation_type_legal',
                  ),
                  SizedBox(height: 25.h),

                  _buildConsultationTypeCard(
                    context: context,
                    icon: Icons.calculate,
                    title: 'consultation_type_tax_title'.tr(),
                    description: 'consultation_type_tax_description'.tr(),
                    typeKey: 'consultation_type_tax',
                  ),
                  SizedBox(height: 25.h),

                  _buildConsultationTypeCard(
                    context: context,
                    icon: Icons.shield,
                    title: 'consultation_type_insurance_title'.tr(),
                    description: 'consultation_type_insurance_description'.tr(),
                    typeKey: 'consultation_type_insurance',
                  ),
                  SizedBox(height: 25.h),

                  _buildConsultationTypeCard(
                    context: context,
                    icon: Icons.business,
                    title: 'consultation_type_social_title'.tr(),
                    description: 'consultation_type_social_description'.tr(),
                    typeKey: 'consultation_type_social',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String typeKey,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(Routes.consultationForm, arguments: typeKey);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(minHeight: 100.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.brand600.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.brand600, size: 24.sp),
                ),
                SizedBox(width: 16.w),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Icon(
                  context.locale.languageCode == 'ar'
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios,
                  color: Colors.white54,
                  size: 16.sp,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              description,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                height: 20 / 12, 
                letterSpacing: -0.4,
                color: const Color(0xFFD4D4FF), 
              ),
              textAlign: context.locale.languageCode == 'ar'
                  ? TextAlign.right
                  : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
