import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/routing/routes.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FocusNode _codeFocus = FocusNode();
  final TextEditingController _codeController = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return '******@******';
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    final visible = local.length >= 2 ? local.substring(0, 2) : local;
    return '$visible***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? email;
    if (args is Map) {
      email = args['email'] as String?;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.registerEmail);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'auth_verify_title'.tr(),
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'auth_verify_sent_code_to_email'.tr(args: [_maskEmail(email)]),
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF5D5D5D),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(_codeFocus),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final hasChar = _codeController.text.length > i;
                    final isActive =
                        _codeController.text.length == i ||
                        (_codeController.text.length == 4 && i == 3);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 48,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? AppColors.brand800
                                : AppColors.neutral800,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          hasChar ? _codeController.text[i] : '',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: TextField(
                    focusNode: _codeFocus,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsLeft == 0
                        ? '00:00'
                        : '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 22 / 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _secondsLeft == 0
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('auth_code_resent'.tr())),
                            );
                            _startTimer();
                          }
                        : null,
                    child: Text(
                      'auth_resend'.tr(),
                      style: GoogleFonts.inter(
                        color: AppColors.brand800,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: _secondsLeft == 0
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 272,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _codeController.text.length == 4
                          ? const Color(0xFFA099FF)
                          : const Color(0x4DA099FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _codeController.text.length == 4
                        ? () async {
                            await _verifyCode();
                          }
                        : null,
                    child: Text(
                      'auth_confirm_button'.tr(),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String?;
    final password = args?['password'] as String?;
    final confirmPassword = args?['confirmPassword'] as String?;
    final isRegistration = args?['isRegistration'] as bool? ?? false;

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth_email_required'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isRegistration) {
      // التحقق من كود التسجيل
      if (_codeController.text.length == 4) {
        // الانتقال إلى صفحة إكمال الملف الشخصي
        Navigator.of(context).pushNamed(
          Routes.completeProfile,
          arguments: {
            'email': email,
            'password': password,
            'confirmPassword': confirmPassword,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('كود التحقق يجب أن يكون 4 أرقام'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // التحقق من كود إعادة تعيين كلمة المرور
      if (_codeController.text.length == 4) {
        // الانتقال إلى صفحة إعادة تعيين كلمة المرور
        Navigator.of(
          context,
        ).pushNamed(Routes.resetPassword, arguments: {'email': email});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('كود التحقق يجب أن يكون 4 أرقام'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
