import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theming/colors_manager.dart';
import '../../core/routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64.h,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: 16.w),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Text(
                'app_title'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('notifications'.tr())),
              );
            },
          ),
          SizedBox(width: 8.w),
          // Language toggle button
          Tooltip(
            message: 'language_switch'.tr(),
            child: IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              tooltip: 'language_switch'.tr(),
              onPressed: () async {
              final isAr = context.locale.languageCode == 'ar';
              final next = isAr ? const Locale('en') : const Locale('ar');
              await context.setLocale(next);
              },
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('settings'.tr())),
              );
            },
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            // Hero greeting
            Builder(builder: (context){
              final name = 'داوود';
              return RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(text: '${'greeting_user'.tr(namedArgs: {'name': name})}\n', style: const TextStyle(color: Colors.white)),
                    TextSpan(text: 'assistant_name'.tr(), style: const TextStyle(color: Colors.white)),
                    TextSpan(text: 'assistant_tagline'.tr(), style: const TextStyle(color: AppColors.accentMauve)),
                    const TextSpan(text: '✨', style: TextStyle(color: AppColors.accentMauve)),
                  ],
                ),
              );
            }),
            SizedBox(height: 40.h),
            // Inquiry banner with gradient and CTA
            const _InquiryBanner(),
            SizedBox(height: 16.h),
            // Feature cards row
            const _FeatureCards(),
            const Spacer(),
            // Bottom voice CTA pill
            const _VoiceCTA(),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.consultation);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                  color: Colors.white.withOpacity(0.10),
                ),
                child: Text('feature_consultations_title'.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _PrimaryCTA extends StatelessWidget {
  const _PrimaryCTA();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.brand600,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'inquiry_cta'.tr(),
        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InquiryBanner extends StatelessWidget {
  const _InquiryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.inquiryBannerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 18, offset: Offset(0, 10.h)),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'inquiry_banner_title'.tr(),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.smart_toy_outlined, color: Colors.white, size: 24.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'inquiry_banner_sub'.tr(),
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
              color: Colors.white.withOpacity(0.15),
            ),
            child: Text(
              'inquiry_cta'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(child: _DarkCard(title: 'feature_consultations_title', subtitle: 'feature_consultations_sub', icon: Icons.gavel)),
          SizedBox(width: 10),
          Expanded(child: _DarkCard(title: 'feature_articles_title', subtitle: 'feature_articles_sub', icon: Icons.menu_book)),
        ],
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _DarkCard({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('coming_soon'.tr())),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Arrow on the opposite side
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Icon(Icons.north_west, color: Colors.white.withOpacity(0.5), size: 18.sp),
                ),
                // Feature icon
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Icon(icon, color: AppColors.accentMauve, size: 18.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Title under the top row
            Text(
              title.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10.h),
            // Subtitle text under title
            Text(
              subtitle.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceCTA extends StatelessWidget {
  const _VoiceCTA();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(Routes.voiceRecord),
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.voicePillGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'voice_cta_text'.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 12.w),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.mic, color: AppColors.brand700),
          ),
        ],
      ),
      ),
    );
  }
}