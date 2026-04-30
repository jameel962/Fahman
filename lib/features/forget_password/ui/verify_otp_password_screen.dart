import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/forgot_password_cubit.dart';

class VerifyOtpPasswordScreen extends StatefulWidget {
  const VerifyOtpPasswordScreen({super.key});

  @override
  State<VerifyOtpPasswordScreen> createState() =>
      _VerifyOtpPasswordScreenState();
}

class _VerifyOtpPasswordScreenState extends State<VerifyOtpPasswordScreen>
    with WidgetsBindingObserver {
  int _secondsLeft = 60;
  Timer? _timer;
  static const String _otpExpiryKey = 'forgot_password_otp_timer';

  final FocusNode _codeFocus = FocusNode();
  final TextEditingController _codeController = TextEditingController();

  String _localOtp = '';
  bool _isLoading = false;

  /// 🔐 يمنع تكرار التحقق
  bool _hasSubmittedOtp = false;

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
    if (state == AppLifecycleState.resumed && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(_codeFocus);
      });
    }
  }

  Future<void> _loadAndStartTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_otpExpiryKey);

    if (expiryTimestamp != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();

      if (expiryTime.isAfter(now)) {
        setState(() {
          _secondsLeft = expiryTime.difference(now).inSeconds;
        });
        _resumeTimer();
        return;
      }
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _saveTimerExpiry(60);
    _resumeTimer();
  }

  void _resumeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
        _clearTimerStorage();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _saveTimerExpiry(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(Duration(seconds: seconds));
    await prefs.setInt(_otpExpiryKey, expiryTime.millisecondsSinceEpoch);
  }

  Future<void> _clearTimerStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpExpiryKey);
  }

  /// ✅ تحقق آمن – مرة واحدة فقط
  void _submitOtp(ForgotPasswordCubit cubit) {
    if (_localOtp.length != 4) return;
    if (_isLoading || _hasSubmittedOtp) return;

    setState(() => _hasSubmittedOtp = true);
    cubit.verifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
          listenWhen: (previous, current) {
            return previous.isLoading != current.isLoading ||
                (current.errorMessage != null &&
                    previous.errorMessage != current.errorMessage) ||
                (current.otpVerified && !previous.otpVerified);
          },
          listener: (context, state) {
            if (state.isLoading != _isLoading) {
              setState(() => _isLoading = state.isLoading);
            }

            if (state.errorMessage != null) {
              setState(() => _hasSubmittedOtp = false);

              final msg = state.errorMessage!.startsWith('auth_')
                  ? state.errorMessage!.tr()
                  : state.errorMessage!;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            }

            if (state.otpVerified) {
              Navigator.of(context).pushReplacementNamed(
                Routes.resetPassword,
                arguments: context.read<ForgotPasswordCubit>(),
              );
            }
          },
          child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            builder: (context, state) {
              final cubit = context.read<ForgotPasswordCubit>();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    /// OTP INPUT
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (i) {
                              final hasChar = _localOtp.length > i;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                width: 48,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF121212),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.brand800),
                                ),
                                child: Text(
                                  hasChar ? _localOtp[i] : '',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ),
                          Opacity(
                            opacity: 0.01,
                            child: TextField(
                              focusNode: _codeFocus,
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _localOtp = value;
                                  // Only reset submission lock if NOT currently loading
                                  if (!_isLoading) {
                                    _hasSubmittedOtp = false;
                                  }
                                });
                                cubit.updateOtp(value);
                              },
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// VERIFY BUTTON
                    SizedBox(
                      width: 272,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_localOtp.length == 4 && !_isLoading)
                            ? () => _submitOtp(cubit)
                            : null,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'auth_verify_button'.tr(),
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
