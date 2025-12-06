import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/routing/app_router.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/theming/typography.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/auth/auth_cubit.dart';
import 'package:fahman_app/features/legal_articles/logic/articles_cubit.dart';
import 'package:fahman_app/features/legal_articles/data/articles_repository.dart';
import 'package:fahman_app/core/networking/api_service.dart';
import 'package:fahman_app/core/language/language_service.dart';
import 'package:fahman_app/features/notifications/logic/notification_cubit.dart';
import 'package:fahman_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'dart:ui' as ui;

class FahmanApp extends StatelessWidget {
  FahmanApp({Key? key}) : super(key: key);

  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    // Initialize LanguageService with the current locale
    LanguageService().setLanguage(context.locale.languageCode);

    return FutureBuilder(
      future: AuthSession().init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (_) {
                // Create Dio with auth interceptor for API calls
                final dio = Dio();
                dio.interceptors.add(ApiInterceptor());
                final apiConsumer = DioConsumer(dio: dio);

                return AuthCubit(
                  authSession: AuthSession(),
                  apiConsumer: apiConsumer,
                );
              },
            ),
            BlocProvider<ArticlesCubit>(
              create: (_) {
                // Create shared Dio and ApiService for articles
                final dio = Dio();
                dio.interceptors.add(ApiInterceptor());
                final apiService = ApiService(dio);
                final articlesRepository = ArticlesRepository(apiService);

                return ArticlesCubit(repository: articlesRepository);
              },
            ),
            BlocProvider<NotificationCubit>(
              create: (_) {
                // Create Dio and ApiConsumer for notifications
                final dio = Dio();
                dio.interceptors.add(ApiInterceptor());
                final apiConsumer = DioConsumer(dio: dio);
                final notificationRepository = NotificationRepository(
                  apiConsumer: apiConsumer,
                );
                final cubit = NotificationCubit(
                  repository: notificationRepository,
                );

                // Load unread count on app start
                cubit.loadUnreadCount();

                return cubit;
              },
            ),
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
      },
    );
  }
}
