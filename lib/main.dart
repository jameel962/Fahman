import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/helpers/cache_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fahman_app/core/services/fcm_service.dart';
import 'firebase_options.dart';
import 'fahman_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize CacheHelper before running the app
  await CacheHelper.init();
  await AuthSession().init();

  // Initialize Firebase with platform-specific options (Android + iOS)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM Service
  print('🚀 Initializing FCM Service...');
  await FCMService().initialize();

  // Double-check: Get FCM token again
  final fcmToken = await FCMService().getToken();
  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║  FCM TOKEN CHECK (from main.dart)                     ║');
  print('╠════════════════════════════════════════════════════════╣');
  if (fcmToken != null && fcmToken.isNotEmpty) {
    print('║  ✅ FCM Token Retrieved Successfully!                 ║');
    print('║                                                        ║');
    print('║  Token: ${fcmToken.substring(0, 40)}...║');
    print(
      '║  Length: ${fcmToken.length} characters                          ║',
    );
  } else {
    print('║  ❌ FCM Token is NULL or EMPTY!                       ║');
    print('║  Check Firebase configuration and permissions        ║');
  }
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      // Default the app to Arabic unless user changes it
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => FahmanApp(),
      ),
    ),
  );
}
