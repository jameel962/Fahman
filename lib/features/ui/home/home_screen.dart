import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/routing/routes.dart';
import 'package:fahman_app/features/ui/inquiry/inquiry_screen.dart';
import 'package:fahman_app/core/auth/auth_session.dart';

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
              Navigator.of(context).pushNamed(Routes.notifications);
            },
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.profile);
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
            Builder(
              builder: (context) {
                final name = AuthSession().username ?? 'auth_user_default'.tr();
                return RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${'greeting_user'.tr(namedArgs: {'name': name})}\n',
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'assistant_name'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'assistant_tagline'.tr(),
                        style: const TextStyle(color: AppColors.accentMauve),
                      ),
                      const TextSpan(
                        text: '✨',
                        style: TextStyle(color: AppColors.accentMauve),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 40.h),
            const _InquiryBanner(),
            SizedBox(height: 16.h),
            const _FeatureCards(),
            const Spacer(),
            const _VoiceCTA(),
            SizedBox(height: 24.h),
          ],
        ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 18,
            offset: Offset(0, 10.h),
          ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const InquiryScreen()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1,
                ),
                color: Colors.white.withOpacity(0.15),
              ),
              child: Text(
                'inquiry_cta'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        children: [
          Expanded(
            child: _DarkCard(
              title: 'feature_consultations_title',
              subtitle: 'feature_consultations_sub',
              icon: Icons.gavel,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(Routes.consultationTypeSelection);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DarkCard(
              title: 'feature_articles_title',
              subtitle: 'feature_articles_sub',
              icon: Icons.menu_book,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.legalArticles);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  const _DarkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('coming_soon'.tr())));
        }
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
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Icon(
                    Icons.north_west,
                    color: Colors.white.withOpacity(0.5),
                    size: 18.sp,
                  ),
                ),
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
            Text(
              title.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              subtitle.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
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
          gradient: LinearGradient(
            colors: AppColors.voicePillGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'voice_cta_text'.tr(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
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
