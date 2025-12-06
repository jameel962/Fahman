import 'package:fahman_app/core/shared/buld_label.dart';
import 'package:fahman_app/features/complete_profile/data/complete_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import '../../../../core/networking/api/api_interceptors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/services/routes.dart';

import '../../../../core/theming/colors_manager.dart';
import '../../../../core/shared/widgets/profile_avatar_widget.dart';
import '../../../../core/networking/api/dio_consumer.dart';
import '../logic/complete_profile_cubit.dart';
import '../logic/complete_profile_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  String _selectedCountryCode = '+962';
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    // attach auth interceptor so requests include Authorization header
    dio.interceptors.add(ApiInterceptor());
    final apiConsumer = DioConsumer(dio: dio);
    final repository = CompleteProfileRepository(apiConsumer: apiConsumer);

    return BlocProvider(
      create: (_) => CompleteProfileCubit(repository),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: BlocConsumer<CompleteProfileCubit, CompleteProfileState>(
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
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    // Back Button
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

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.brand800,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'auth_complete_profile'.tr(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),

                    // Avatar Selection
                    Center(
                      child: EditableProfileAvatarWidget(
                        radius: 60,
                        useRemoteAvatars: true,
                        initialImagePath: _selectedAvatarPath,
                        onImageSelected: (avatarPath) {
                          setState(() {
                            _selectedAvatarPath = avatarPath;
                          });
                          context.read<CompleteProfileCubit>().updateImagePath(
                            avatarPath,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name Field
                            buildFieldLabel('auth_name_label'.tr()),
                            SizedBox(height: 8.h),
                            _buildTextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              icon: Icons.person_outline,
                              onChanged: (value) {
                                context.read<CompleteProfileCubit>().updateName(
                                  value,
                                );
                              },
                            ),

                            SizedBox(height: 24.h),

                            // Phone Field
                            buildFieldLabel('auth_phone_label'.tr()),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                // Country Code Selector
                                Container(
                                  width: 100.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral800,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColors.neutral700,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '🇯🇴',
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        _selectedCountryCode,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocus,
                                    keyboardType: TextInputType.phone,
                                    onChanged: (value) {
                                      // Combine country code with phone number
                                      final fullPhone =
                                          _selectedCountryCode + value;
                                      context
                                          .read<CompleteProfileCubit>()
                                          .updatePhone(fullPhone);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 40.h),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: state.loading
                                      ? AppColors.brand800.withOpacity(0.5)
                                      : AppColors.brand800,
                                  disabledBackgroundColor: AppColors.brand800
                                      .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                onPressed:
                                    (state.loading ||
                                        _nameController.text.trim().isEmpty ||
                                        _phoneController.text.trim().isEmpty)
                                    ? null
                                    : () async {
                                        final success = await context
                                            .read<CompleteProfileCubit>()
                                            .submit();

                                        if (success && mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'تم حفظ البيانات بنجاح',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          // Navigate to Home and clear stack
                                          Navigator.of(
                                            context,
                                          ).pushNamedAndRemoveUntil(
                                            Routes.home,
                                            (route) => false,
                                          );
                                        }
                                      },
                                child: state.loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'auth_save_button'.tr(),
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: 20.h),
                          ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    IconData? icon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.brand800 : AppColors.neutral700,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textDirection: ui.TextDirection.rtl,
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
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white, size: 20.sp)
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
