import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_selector/file_selector.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors_manager.dart';
import '../../../../shared/widgets/profile_avatar_widget.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  Uint8List? _selectedImageBytes;
  String _selectedCountryCode = '+962';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'images',
          extensions: <String>['jpg', 'jpeg', 'png', 'gif'],
        ),
      ],
    );
    if (image != null) {
      final Uint8List? bytes = await image.readAsBytes();
      if (bytes != null) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    }
  }

  void _saveProfile() {
    // الانتقال إلى صفحة الهوم
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: AppColors.brand800, size: 24.sp),
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

              Center(
                child: EditableProfileAvatarWidget(
                  radius: 60,
                  onImageSelected: (avatarPath) {
                    // تحويل مسار الأفاتار إلى bytes إذا لزم الأمر
                    // أو يمكن حفظ المسار مباشرة
                    setState(() {
                      // يمكن إضافة منطق تحويل المسار هنا
                    });
                  },
                ),
              ),

              SizedBox(height: 40.h),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFieldLabel('auth_name_label'.tr()),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        icon: Icons.person_outline,
                      ),

                      SizedBox(height: 24.h),

                      _buildFieldLabel('auth_phone_label'.tr()),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          // Country code selector
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
                                Text('🇯🇴', style: TextStyle(fontSize: 16.sp)),
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
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      _buildFieldLabel('auth_email_label_alt2'.tr()),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 60.h),

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
                          onPressed: _saveProfile,
                          child: Text(
                            'auth_save_button'.tr(),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    IconData? icon,
    TextInputType? keyboardType,
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
      ),
    );
  }
}
