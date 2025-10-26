import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors_manager.dart';
import '../../../logic/auth/auth_provider.dart';
import '../../../../shared/widgets/settings_app_bar.dart';
import '../../../../shared/widgets/language_selector.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    // تحميل معلومات المستخدم عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
      final userInfo = context.read<AuthProvider>().userInfo;
      if (userInfo?.profileImage != null) {
        _selectedAvatar = userInfo!.profileImage;
      }
    });
  }

  /// عرض نافذة تأكيد تسجيل الخروج
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'auth_logout'.tr(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'auth_logout_confirm'.tr(),
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'auth_cancel'.tr(),
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text(
                'auth_logout'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// تنفيذ عملية تسجيل الخروج
  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.logout();

    if (success) {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.loginEmail, (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'auth_logout_failed'.tr(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// عرض نافذة اختيار اللغة
  void _showLanguageSelector() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Semi-transparent background to close dialog
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
            // Language selector positioned in center
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LanguageSelector(
                    onLanguageSelected: (locale) {
                      context.setLocale(locale);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: SettingsAppBar(
        title: 'auth_profile_title'.tr(),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final userInfo = authProvider.userInfo;
          final username = userInfo?.username ?? 'auth_user_default'.tr();
          final email = userInfo?.email ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Profile Picture Section (Static - No editing allowed)
                Center(
                  child: CircleAvatar(
                    radius: 60.r,
                    backgroundColor: const Color(0xFF1E1E1E),
                    backgroundImage: _selectedAvatar != null
                        ? AssetImage(_selectedAvatar!)
                        : userInfo?.profileImage != null
                        ? NetworkImage(userInfo!.profileImage!)
                        : null,
                    child:
                        _selectedAvatar == null &&
                            userInfo?.profileImage == null
                        ? Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 60.sp,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 24.h),

                // Name
                Text(
                  username,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),

                // Email
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                SizedBox(height: 32.h),

                // Edit Button
                SizedBox(
                  width: 200.w,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.editProfile);
                    },
                    child: Text(
                      'auth_edit_button'.tr(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // Account Settings Section
                _buildSettingsSection(
                  title: 'auth_account_section'.tr(),
                  items: [
                    _buildSwitchItem(
                      icon: Icons.notifications_outlined,
                      title: 'auth_notifications_section'.tr(),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildLanguageItem(
                      icon: Icons.language_outlined,
                      title: 'auth_language_section'.tr(),
                      onTap: () {
                        _showLanguageSelector();
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.lock_outline,
                      title: 'auth_password_section'.tr(),
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.changePassword);
                      },
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // About Section
                _buildSettingsSection(
                  title: 'auth_about_section'.tr(),
                  items: [
                    _buildSettingsItem(
                      icon: Icons.description_outlined,
                      title: 'auth_terms_of_use'.tr(),
                      onTap: () {},
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'auth_app_version'.tr(),
                      onTap: () {},
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Logout Section
                _buildSettingsSection(
                  title: 'auth_account_section_alt'.tr(),
                  items: [
                    _buildLogoutItem(
                      icon: Icons.logout,
                      title: 'auth_logout_section'.tr(),
                      onTap: () {
                        _showLogoutDialog();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// بناء قسم الإعدادات
  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x1A6955FD), // #6955FD1A
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  /// بناء عنصر الإعدادات
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  /// بناء عنصر التبديل
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brand800,
            activeTrackColor: AppColors.brand800.withOpacity(0.3),
            inactiveThumbColor: Colors.grey[300],
            inactiveTrackColor: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  /// بناء عنصر اللغة
  Widget _buildLanguageItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Text(
              context.locale.languageCode == 'ar'
                  ? 'auth_arabic_language'.tr()
                  : 'auth_english_language'.tr(),
              style: GoogleFonts.inter(
                color: AppColors.brand800,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر تسجيل الخروج
  Widget _buildLogoutItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
