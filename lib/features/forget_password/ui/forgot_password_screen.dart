import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:fahman_app/features/forget_password/logic/forgot_password_cubit.dart';
import 'package:fahman_app/features/forget_password/data/forgot_password_repository.dart';
import 'package:fahman_app/features/forget_password/data/forgot_password_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(
        repository: ForgotPasswordRepository(
          remoteDataSource: ForgotPasswordRemoteDataSource(
            api: DioConsumer(dio: Dio()),
          ),
        ),
      ),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
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

        // Navigate to OTP verification on success
        if (state.otpSent) {
          Navigator.of(context).pushNamed(
            Routes.verifyOtpPassword,
            arguments: context.read<ForgotPasswordCubit>(),
          );
        }
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
                    'auth_forgot_password_title'.tr(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'auth_enter_email_reset'.tr(),
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
                    'auth_email_label_alt'.tr(),
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
                        color: _emailFocus.hasFocus
                            ? AppColors.brand800
                            : AppColors.neutral700,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: ui.TextDirection.rtl,
                      onChanged: (value) {
                        context.read<ForgotPasswordCubit>().updateIdentifier(
                          value,
                        );
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
                          Icons.mail_outline,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Send OTP button
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
                              context.read<ForgotPasswordCubit>().sendOtp();
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
                              'auth_reset_password_button_alt'.tr(),
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
    );
  }
}
