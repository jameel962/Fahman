import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/profile_avatar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import '../../../../core/theming/colors_manager.dart';
import '../../../../shared/widgets/settings_app_bar.dart';

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

  /// حفظ التغييرات في الملف الشخصي
  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('auth_profile_changes_saved'.tr()),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            _buildInputField(
              label: 'auth_email_label_alt3'.tr(),
              controller: _emailController,
              focusNode: _emailFocus,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 40.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _saveProfile,
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
          ],
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
