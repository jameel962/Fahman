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
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/verify_email_cubit.dart';
import '../logic/verify_email_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  int _secondsLeft = 60;
  Timer? _timer;
  static const String _otpExpiryKey = 'verify_email_otp_timer';

  final FocusNode _codeFocus = FocusNode();
  final TextEditingController _codeController = TextEditingController();
  String _localOtp = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAndStartTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _codeFocus.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) FocusScope.of(context).requestFocus(_codeFocus);
      });
    }
  }

  Future<void> _loadAndStartTimer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTimestamp = prefs.getInt(_otpExpiryKey);
      if (expiryTimestamp != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        final now = DateTime.now();
        if (expiryTime.isAfter(now)) {
          final remainingSeconds = expiryTime.difference(now).inSeconds;
          if (mounted) setState(() => _secondsLeft = remainingSeconds);
          _resumeTimer();
        } else {
          if (mounted) setState(() => _secondsLeft = 0);
          await _clearTimerStorage();
        }
      } else {
        _startTimer();
      }
    } catch (e) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (mounted) setState(() => _secondsLeft = 60);
    _saveTimerExpiry(60);
    _resumeTimer();
  }

  void _resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
        _clearTimerStorage();
      } else {
        if (mounted) setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _saveTimerExpiry(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTime = DateTime.now().add(Duration(seconds: seconds));
      await prefs.setInt(_otpExpiryKey, expiryTime.millisecondsSinceEpoch);
    } catch (e) {}
  }

  Future<void> _clearTimerStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_otpExpiryKey);
    } catch (e) {}
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
    String? userId;
    String? password;
    String? confirmPassword;
    bool isRegistration = false;

    if (args is Map) {
      email = args['email'] as String?;
      userId = args['userID'] as String?;
      password = args['password'] as String?;
      confirmPassword = args['confirmPassword'] as String?;
      isRegistration = args['isRegistration'] as bool? ?? false;
    }

    return BlocProvider(
      create: (context) => VerifyEmailCubit(VerifyEmailRepo(ApiService(Dio()))),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: BlocListener<VerifyEmailCubit, VerifyEmailState>(
                listener: (context, state) {
                  if (state.loading != _isLoading) {
                    setState(() => _isLoading = state.loading);
                  }
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error ?? 'An error occurred'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(_codeFocus),
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
                              onPressed: () async {
                                await _clearTimerStorage();
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
                          'auth_verify_sent_code_to_email'.tr(),
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
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => FocusScope.of(
                                  context,
                                ).requestFocus(_codeFocus),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (i) {
                                    final hasChar = _localOtp.length > i;
                                    final isActive =
                                        _localOtp.length == i ||
                                        (_localOtp.length == 4 && i == 3);
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isActive
                                                ? AppColors.brand800
                                                : AppColors.neutral800,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          hasChar ? _localOtp[i] : '',
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
                              Positioned.fill(
                                child: Center(
                                  child: Opacity(
                                    opacity: 0.01,
                                    child: SizedBox(
                                      width: 200,
                                      height: 56,
                                      child: TextField(
                                        focusNode: _codeFocus,
                                        controller: _codeController,
                                        keyboardType: TextInputType.number,
                                        textDirection: ui.TextDirection.ltr,
                                        textAlign: TextAlign.center,
                                        maxLength: 4,
                                        autofocus: true,
                                        showCursor: false,
                                        enableInteractiveSelection: false,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        style: const TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 24,
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          setState(() => _localOtp = value);
                                          context
                                              .read<VerifyEmailCubit>()
                                              .updateOtp(value);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                  ? () async {
                                      if (email != null) {
                                        final success = await context
                                            .read<VerifyEmailCubit>()
                                            .reSendOtp(identifier: email);
                                        if (success && mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'auth_code_resent'.tr(),
                                              ),
                                            ),
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
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 272,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _localOtp.length == 4
                                    ? const Color(0xFFA099FF)
                                    : const Color(0x4DA099FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: (_localOtp.length == 4 && !_isLoading)
                                  ? () => _verifyCode(
                                      context,
                                      userId,
                                      email,
                                      password,
                                      confirmPassword,
                                      isRegistration,
                                    )
                                  : null,
                              child: _isLoading
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
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _verifyCode(
    BuildContext context,
    String? userId,
    String? email,
    String? password,
    String? confirmPassword,
    bool isRegistration,
  ) async {
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
      final cubit = context.read<VerifyEmailCubit>();
      final success = await cubit.verifyOtp(userId: userId);
      if (success && mounted) {
        await _clearTimerStorage();
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
      final cubit = context.read<VerifyEmailCubit>();
      final success = await cubit.verifyOtp(userId: userId);
      if (success && mounted) {
        await _clearTimerStorage();
        Navigator.of(
          context,
        ).pushNamed(Routes.resetPassword, arguments: {'email': email});
      }
    }
  }
}
