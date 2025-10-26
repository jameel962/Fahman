import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fahman_app/core/routing/app_router.dart';
import 'package:fahman_app/core/routing/routes.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/theming/typography.dart';
import 'package:fahman_app/features/logic/auth/auth_provider.dart';
import 'package:fahman_app/features/logic/articles/articles_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

class FahmanApp extends StatelessWidget {
  FahmanApp({super.key});

  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        initialRoute: Routes.splash,
        onGenerateRoute: _router.generateRoute,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: AppColors.brand,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.brand600,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          // San Francisco typography mapped per Apple specs; apply white for dark UI
          textTheme: FahmanTypography.sfTextTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        builder: (context, materialChild) {
          return Directionality(
            textDirection: context.locale.languageCode == 'ar'
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.appGradient,
                ),
              ),
              child: materialChild,
            ),
          );
        },
      ),
    );
  }
}
