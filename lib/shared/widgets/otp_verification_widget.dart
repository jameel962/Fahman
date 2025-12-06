import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';

/// Generic OTP Verification Widget
/// Can be used for Email verification, Password reset, etc.
class OtpVerificationWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? maskedIdentifier;
  final Function(String otp) onVerify;
  final Future<bool> Function()? onResend;
  final bool isLoading;
  final int otpLength;
  final String buttonText;
  final Color? backgroundColor;
  final VoidCallback? onBack;

  const OtpVerificationWidget({
    super.key,
    required this.title,
    required this.description,
    this.maskedIdentifier,
    required this.onVerify,
    this.onResend,
    this.isLoading = false,
    this.otpLength = 4,
    this.buttonText = 'Verify',
    this.backgroundColor,
    this.onBack,
  });

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final ValueNotifier<int> _secondsLeft = ValueNotifier<int>(60);
  Timer? _timer;
  final FocusNode _codeFocus = FocusNode();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsLeft.dispose();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft.value <= 1) {
        t.cancel();
        _secondsLeft.value = 0;
      } else {
        _secondsLeft.value -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
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
                    onPressed:
                        widget.onBack ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Title
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),

              SizedBox(height: 16.h),

              // Description
              Text(
                widget.description,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),

              if (widget.maskedIdentifier != null) ...[
                SizedBox(height: 8.h),
                Text(
                  widget.maskedIdentifier!,
                  style: GoogleFonts.inter(
                    color: AppColors.brand800,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],

              SizedBox(height: 40.h),

              // Code input label
              Text(
                'auth_verification_code_label'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),

              SizedBox(height: 8.h),

              // Visual OTP Boxes
              GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(_codeFocus),
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.otpLength, (i) {
                      final hasChar = _codeController.text.length > i;
                      final isActive = _codeController.text.length == i;
                      return Container(
                        width: 60,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.neutral800,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isActive
                                ? AppColors.brand800
                                : AppColors.neutral700,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          hasChar ? _codeController.text[i] : '',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Hidden TextField for input
              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  height: 1,
                  child: TextField(
                    controller: _codeController,
                    focusNode: _codeFocus,
                    maxLength: widget.otpLength,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Resend code with ValueListenableBuilder
              if (widget.onResend != null)
                ValueListenableBuilder<int>(
                  valueListenable: _secondsLeft,
                  builder: (context, seconds, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (seconds > 0)
                          Text(
                            '${'auth_resend_code_in'.tr()} $seconds ${'auth_seconds'.tr()}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                        if (seconds == 0)
                          TextButton(
                            onPressed: widget.isLoading
                                ? null
                                : () async {
                                    final success = await widget.onResend!();
                                    if (success) {
                                      _startTimer();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'auth_otp_resent'.tr(),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: Text(
                              'auth_resend_code'.tr(),
                              style: GoogleFonts.inter(
                                color: AppColors.brand800,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      (_codeController.text.length == widget.otpLength &&
                          !widget.isLoading)
                      ? () {
                          widget.onVerify(_codeController.text);
                        }
                      : null,
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.buttonText,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
