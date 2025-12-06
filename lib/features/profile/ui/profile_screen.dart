// removed core auth cubit import to avoid type conflicts
import 'package:fahman_app/features/profile/ui/widget/logout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
// unused import removed
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/core/language/language_service.dart';
import 'package:fahman_app/features/data/auth/auth_repository.dart'
    as auth_repo;
// ...existing imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/data/auth/logic/auth_cubit.dart';

import '../../../core/services/routes.dart';
import '../../../core/theming/colors_manager.dart';
import '../../../core/shared/widgets/settings_app_bar.dart';
import '../../../core/shared/widgets/language_selector.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String? _selectedAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // we'll initialize AuthCubit provider in build so it can use context
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
                      LanguageService().setLanguage(locale.languageCode);
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
    // create AuthRepository and cubit here so we can fetch user using ApiInterceptor
    final dio = Dio();
    dio.interceptors.add(ApiInterceptor());
    final apiConsumer = DioConsumer(dio: dio);
    final repo = auth_repo.AuthRepository(apiConsumer: apiConsumer);

    final _authCubit = AuthCubit(repository: repo);
    WidgetsBinding.instance.addPostFrameCallback((_) => _authCubit.loadUser());

    return BlocProvider<AuthCubit>(
      create: (_) => _authCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: SettingsAppBar(
          title: 'auth_profile_title'.tr(),
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Profile Picture Section (reads from AuthCubit)
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        ImageProvider? bg;
                        if (_selectedAvatar != null &&
                            _selectedAvatar!.startsWith('http')) {
                          bg = NetworkImage(_selectedAvatar!);
                        } else if (state is AuthLoaded &&
                            (state.user.profileImage?.isNotEmpty ?? false) &&
                            state.user.profileImage!.startsWith('http')) {
                          bg = NetworkImage(state.user.profileImage!);
                        }
                        return Center(
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundColor: const Color(0xFF1E1E1E),
                            backgroundImage: bg,
                            child: bg == null
                                ? Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 60.sp,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Name
                    // username from cubit state
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const CircularProgressIndicator();
                        }
                        if (state is AuthLoaded) {
                          final user = state.user;
                          return Text(
                            (user.username?.isNotEmpty == true)
                                ? user.username!
                                : 'auth_user_default'.tr(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }
                        return Text(
                          'auth_user_default'.tr(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.h),

                    // Email
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoaded &&
                            (state.user.email ?? '').isNotEmpty) {
                          return Text(
                            state.user.email ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed(Routes.editProfile);
                          if (result is String && result.isNotEmpty) {
                            setState(() {
                              _selectedAvatar = result;
                            });
                          }
                          // refresh the cubit we created above
                          _authCubit.loadUser();
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
                        // _buildSwitchItem(
                        //   icon: Icons.notifications_outlined,
                        //   title: 'auth_notifications_section'.tr(),
                        //   value: _notificationsEnabled,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _notificationsEnabled = value;
                        //     });
                        //   },
                        // ),
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
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.changePassword);
                          },
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),

                        _buildSettingsItem(
                          icon: Icons.description_outlined,
                          title: 'my_consultations'.tr(),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.myConsultations);
                          },
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),

                        // add seaction here for "استشاراتي"
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
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.termsConditions,
                            );
                          },
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                        _buildSettingsItem(
                          icon: Icons.description_outlined,
                          title: 'privacy_policy'.tr(),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.privacyPolicy);
                          },
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                        // _buildSettingsItem(
                        //   icon: Icons.info_outline,
                        //   title: 'auth_app_version'.tr(),
                        //   onTap: () {},
                        //   trailing: const Icon(
                        //     Icons.arrow_forward_ios,
                        //     color: Colors.grey,
                        //     size: 16,
                        //   ),
                        // ),
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
                            showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
