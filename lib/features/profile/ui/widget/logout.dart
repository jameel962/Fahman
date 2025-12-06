import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/features/data/auth/auth_repository.dart'
    as auth_repo;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// تنفيذ عملية تسجيل الخروج
Future<void> _logout(BuildContext context) async {
  final session = AuthSession();

  try {
    final refresh = session.getRefreshToken();

    if (refresh != null && refresh.isNotEmpty) {
      // Call logout API with refresh token
      final dio = Dio();
      dio.interceptors.add(ApiInterceptor());
      final apiConsumer = DioConsumer(dio: dio);
      final repo = auth_repo.AuthRepository(apiConsumer: apiConsumer);

      await repo.logout(refresh);
    }
  } catch (e) {
    // Show error but continue with logout
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth_logout_error'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } finally {
    // Always clear local session regardless of API call result
    await session.logout();

    if (context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Routes.loginEmail, (r) => false);
    }
  }
}

/// عرض نافذة تأكيد تسجيل الخروج
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'auth_cancel'.tr(),
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _logout(context);
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
