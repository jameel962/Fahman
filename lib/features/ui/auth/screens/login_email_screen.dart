import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:fahman_app/features/ui/home/home_screen.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/routing/routes.dart';
import 'package:fahman_app/shared/widgets/auth_split_scaffold.dart';
import 'package:fahman_app/shared/widgets/auth_header.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitScaffold(
      topFraction: 0.25,
      header: const AuthHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'auth_email_label'.tr(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 22 / 13,
                letterSpacing: 0.2,
              ),
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 350,
              height: 56,
              child: TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                textDirection: ui.TextDirection.rtl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9._%+\-@]'),
                  ),
                ],
                onChanged: (v) {},
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 22 / 13,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.neutral800,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.neutral800,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand800, width: 1),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'auth_password_label'.tr(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 22 / 13,
                letterSpacing: 0.2,
              ),
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 350,
              height: 56,
              child: TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                textDirection: ui.TextDirection.rtl,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (v) {},
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 22 / 13,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.neutral800,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.neutral800,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand800, width: 1),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        side: BorderSide(color: AppColors.neutral600),
                        checkColor: Colors.white,
                        activeColor: AppColors.brand800,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Text(
                          'auth_remember_me_text'.tr(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 22 / 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.forgotPassword);
                  },
                  child: Text(
                    'auth_forgot_password_text'.tr(),
                    style: GoogleFonts.inter(
                      color: AppColors.brand800,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 22 / 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 350,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: const Size(327, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_emailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يرجى إدخال البريد الإلكتروني'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يرجى إدخال كلمة المرور'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const HomeScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
                child: Text(
                  'auth_login_button_text'.tr(),
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 22 / 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.registerEmail);
              },
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'auth_new_user_question_space'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: 'auth_login_link_text_alt'.tr(),
                      style: TextStyle(
                        color: AppColors.brand800,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
