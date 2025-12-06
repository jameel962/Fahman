import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/features/home/ui/widgets/home_app_bar.dart';
import 'package:fahman_app/features/home/ui/widgets/home_greeting_header.dart';
import 'package:fahman_app/features/home/ui/widgets/inquiry_banner.dart';
import 'package:fahman_app/features/home/ui/widgets/feature_cards.dart';
import 'package:fahman_app/features/home/ui/widgets/voice_assistant_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            const HomeGreetingHeader(),
            SizedBox(height: 40.h),
            const InquiryBanner(),
            SizedBox(height: 16.h),
            const FeatureCards(),
            const Spacer(),
            // const VoiceAssistantButton(),
            // SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
