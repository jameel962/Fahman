import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/features/auth/login/ui/login_email_screen.dart';

class SplashLoginScreen extends StatefulWidget {
  const SplashLoginScreen({super.key});

  @override
  State<SplashLoginScreen> createState() => _SplashLoginScreenState();
}

class _SplashLoginScreenState extends State<SplashLoginScreen> {
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    // Check existing auth session and navigate automatically when token exists.
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await AuthSession().init();
      if (!mounted) return;

      // If the user already has a token, navigate to home immediately.
      if (AuthSession().isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(Routes.home);
        return;
      }

      // Otherwise keep showing splash for a short delay then reveal login buttons.
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _showLogin = true);
    } catch (_) {
      // On any error, fall back to showing login after delay.
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _showLogin = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'FAH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            height: 41 / 32,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                          ),
                        ),
                        TextSpan(
                          text: 'MAN',
                          style: TextStyle(
                            color: AppColors.brand800,
                            fontSize: 32.sp,
                            height: 41 / 32,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20.h),
                AnimatedOpacity(
                  opacity: _showLogin ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    offset: _showLogin ? Offset.zero : const Offset(0, 0.2),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                settings: const RouteSettings(
                                  name: Routes.loginEmail,
                                ),
                                transitionDuration: const Duration(
                                  milliseconds: 600,
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LoginEmailScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      final curved = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      );
                                      return FadeTransition(
                                        opacity: curved,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                          child: Container(
                            width: 327.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(200.r),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'splash_continue_with_email'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.sp,
                                      height: 20 / 15,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    child: Icon(
                                      Icons.mail_outline,
                                      color: AppColors.neutral800,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(Routes.registerEmail);
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'auth_new_user_question'.tr() + ' ',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    height: 1.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text: 'auth_register_new_link'.tr(),
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    height: 1.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.brand800,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
