import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theming/colors_manager.dart';
import 'core/theming/typography.dart';
import 'package:easy_localization/easy_localization.dart';

class FahmanApp extends StatelessWidget {
  FahmanApp({super.key});

  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      initialRoute: Routes.home,
      onGenerateRoute: _router.genrateRoute,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: AppColors.brand,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand600, brightness: Brightness.dark),
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
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.appGradient,
            ),
          ),
          child: child,
        );
      },
    );
  }
}