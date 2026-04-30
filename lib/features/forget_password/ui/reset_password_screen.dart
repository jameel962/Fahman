import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import '../../../core/services/routes.dart';
import '../../../../../core/theming/colors_manager.dart';
import 'package:fahman_app/features/forget_password/logic/forgot_password_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _showPasswordUpdatedOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 40.sp),
                ),

                SizedBox(height: 24.h),

                Text(
                  'auth_password_updated'.tr(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                Text(
                  'auth_password_updated_success'.tr(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32.h),

                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.loginEmail,
                        (route) => false,
                      );
                    },
                    child: Text(
                      'auth_go_to_login'.tr(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) {
        return (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage) ||
            (current.passwordReset && !previous.passwordReset);
      },
      listener: (context, state) {
        // Show error messages
        if (state.errorMessage != null) {
          final errorText = state.errorMessage!.startsWith('auth_')
              ? state.errorMessage!.tr()
              : state.errorMessage!;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorText), backgroundColor: Colors.red),
          );
        }

        // Navigate to login on success
        if (state.passwordReset) {
          _showPasswordUpdatedOverlay();
        }
      },
      child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
        buildWhen: (previous, current) {
          // Only rebuild when loading state or password reset state changes
          // Don't rebuild when just password text changes
          return previous.isLoading != current.isLoading ||
              previous.passwordReset != current.passwordReset;
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    Text(
                      'auth_new_password'.tr(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'auth_set_new_password'.tr(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    SizedBox(height: 40.h),

                    Text(
                      'auth_new_password'.tr(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    SizedBox(height: 8.h),

                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: AppColors.neutral800,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _newPasswordFocus.hasFocus
                              ? AppColors.brand800
                              : AppColors.neutral700,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _newPasswordController,
                        focusNode: _newPasswordFocus,
                        obscureText: !_isNewPasswordVisible,
                        textDirection: ui.TextDirection.rtl,
                        onChanged: (value) {
                          // Don't trigger state updates on every keystroke
                          // The cubit will read the controller value when submitting
                        },
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'auth_confirm_new_password'.tr(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    SizedBox(height: 8.h),

                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: AppColors.neutral800,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _confirmPasswordFocus.hasFocus
                              ? AppColors.brand800
                              : AppColors.neutral700,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        obscureText: !_isConfirmPasswordVisible,
                        textDirection: ui.TextDirection.rtl,
                        onChanged: (value) {
                          // Don't trigger state updates on every keystroke
                          // The cubit will read the controller value when submitting
                        },
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

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
                        onPressed: state.isLoading
                            ? null
                            : () {
                                // Update state with current text field values
                                final cubit = context
                                    .read<ForgotPasswordCubit>();
                                cubit.updateNewPassword(
                                  _newPasswordController.text,
                                );
                                cubit.updateConfirmPassword(
                                  _confirmPasswordController.text,
                                );
                                // Now call reset
                                cubit.resetPassword();
                              },
                        child: state.isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'auth_reset_password_button'.tr(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
