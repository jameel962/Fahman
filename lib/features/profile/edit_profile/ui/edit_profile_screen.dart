import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/shared/widgets/profile_avatar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../edit_profile/logic/edit_profile_cubit.dart';
import '../../edit_profile/logic/edit_profile_state.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/features/data/auth/auth_repository.dart'
    as auth_repo;
import 'package:fahman_app/features/profile/edit_profile/data/edit_profile.dart';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';

import '../../../../core/theming/colors_manager.dart';
import '../../../../core/shared/widgets/settings_app_bar.dart';

/// شاشة تعديل الملف الشخصي
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedAvatar; // الصورة المختارة
  final TextEditingController _nameController = TextEditingController(
    text: 'داوود حجازي',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'Davfahman@gmail.com',
  );
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // We'll let the cubit load user info; listen for updates below.
  }

  // Networking and update logic is handled by EditProfileCubit.

  @override
  Widget build(BuildContext context) {
    // Provide the cubit so the screen can load and submit data.
    return BlocProvider(
      create: (_) {
        final dio = Dio();
        dio.interceptors.add(ApiInterceptor());
        final apiConsumer = DioConsumer(dio: dio);
        final authRepo = auth_repo.AuthRepository(apiConsumer: apiConsumer);
        final profileRepo = UpdateProfileRepository(apiConsumer: apiConsumer);
        final cubit = EditProfileCubit(
          authRepo: authRepo,
          profileRepo: profileRepo,
        );
        // load data
        cubit.loadUserInfo();
        return cubit;
      },
      child: BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'An error occurred')),
            );
          }
          // populate controllers when data loaded
          if (!state.loading) {
            _nameController.text = state.userName;
            if (state.avatarPath != null) _selectedAvatar = state.avatarPath;
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: SettingsAppBar(
            title: 'auth_profile_title_alt'.tr(),
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Profile Picture Section
                Center(
                  child: EditableProfileAvatarWidget(
                    initialImagePath: _selectedAvatar,
                    radius: 60,
                    useRemoteAvatars: true,
                    onImageSelected: (avatarPath) {
                      setState(() {
                        _selectedAvatar = avatarPath;
                      });
                    },
                  ),
                ),
                SizedBox(height: 32.h),

                // Name Field
                _buildInputField(
                  label: 'auth_name_label_alt'.tr(),
                  controller: _nameController,
                  focusNode: _nameFocus,
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 24.h),

                // Email Field
                SizedBox(height: 40.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Builder(
                    builder: (buttonContext) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () async {
                        // update cubit name/avatar and submit using a context
                        // that is a descendant of the BlocProvider
                        final cubit = BlocProvider.of<EditProfileCubit>(
                          buttonContext,
                        );
                        cubit.updateName(_nameController.text.trim());
                        cubit.updateAvatar(_selectedAvatar);
                        final ok = await cubit.submit();
                        if (ok) Navigator.of(buttonContext).pop();
                      },
                      child: Text(
                        'auth_save_button_alt2'.tr(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
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
    );
  }

  /// بناء حقل الإدخال
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textDirection: ui.TextDirection.rtl,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0x1A6955FD), // #6955FD1A
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.neutral800, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.neutral800, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.brand800, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
