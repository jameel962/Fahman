import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fahman_app/features/auth/veify_email/data/verify_email_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/networking/api_service.dart';
import '../logic/verify_email_cubit.dart';
import '../logic/verify_email_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
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

  // Controllers and FocusNodes are managed inside the build method with Bloc
  final FocusNode _codeFocus = FocusNode();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? email;
    String? userId;
    if (args is Map) {
      email = args['email'] as String?;
      userId = args['userID'] as String?;
    }

    return BlocProvider(
      create: (context) => VerifyEmailCubit(VerifyEmailRepo(ApiService(Dio()))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error ?? 'An error occurred'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
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
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.registerEmail);
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
                      'auth_verify_sent_code_to_email'.tr(
                        namedArgs: {'email_masked': _maskEmail(email)},
                      ),
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
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                FocusScope.of(context).requestFocus(_codeFocus),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (i) {
                                final hasChar = _codeController.text.length > i;
                                final isActive =
                                    _codeController.text.length == i ||
                                    (_codeController.text.length == 4 &&
                                        i == 3);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
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
                                textDirection: ui.TextDirection.ltr,
                                textAlign: TextAlign.left,
                                maxLength: 4,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  counterText: '',
                                ),
                                onChanged: (value) {
                                  context.read<VerifyEmailCubit>().updateOtp(
                                    value,
                                  );
                                  setState(() {}); // To rebuild the OTP boxes
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Timer and Resend button (logic remains the same)
                    buildTimerAndResend(context, email),

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 272,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.otp.length == 4
                                ? const Color(0xFFA099FF)
                                : const Color(0x4DA099FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: (state.otp.length == 4 && !state.loading)
                              ? () async {
                                  await _verifyCode(context, userId);
                                }
                              : null,
                          child: state.loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Row buildTimerAndResend(BuildContext context, String? email) {
    return Row(
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
              ? () async {
                  if (email != null) {
                    final success = await context
                        .read<VerifyEmailCubit>()
                        .reSendOtp(identifier: email);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('auth_code_resent'.tr())),
                      );
                      _startTimer();
                    }
                  }
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
    );
  }

  Future<void> _verifyCode(BuildContext context, String? userId) async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String?;
    final password = args?['password'] as String?;
    final confirmPassword = args?['confirmPassword'] as String?;
    final isRegistration = args?['isRegistration'] as bool? ?? false;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth_user_id_missing'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isRegistration) {
      // Access the cubit from the context passed into the method
      final cubit = context.read<VerifyEmailCubit>();
      final success = await cubit.verifyOtp(userId: userId);
      if (success && mounted) {
        Navigator.of(context).pushNamed(
          Routes.completeProfile,
          arguments: {
            'email': email,
            'password': password,
            'confirmPassword': confirmPassword,
            'userID': userId,
          },
        );
      }
    } else {
      // Handle password reset verification flow
      final cubit = context.read<VerifyEmailCubit>();
      final success = await cubit.verifyOtp(userId: userId);
      if (success && mounted) {
        Navigator.of(
          context,
        ).pushNamed(Routes.resetPassword, arguments: {'email': email});
      }
    }
  }
}
