import 'package:fahman_app/features/forget_password/ui/forgot_password_screen.dart';
import 'package:fahman_app/features/forget_password/ui/verify_otp_password_screen.dart';
import 'package:fahman_app/features/forget_password/ui/reset_password_screen.dart';
import 'package:fahman_app/features/forget_password/logic/forgot_password_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/features/inquiry/ui/inquiry_screen.dart';
import 'package:flutter/material.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/features/home/ui/home_screen.dart';
import 'package:fahman_app/features/voice/ui/voice_record_screen.dart';
import 'package:fahman_app/features/voice/ui/voice_result_screen.dart';
import 'package:fahman_app/features/consultation/consultation_screen.dart';
import 'package:fahman_app/features/consultation/ui/consultation_type_selection_screen.dart';
import 'package:fahman_app/features/consultation/ui/my_consultations.dart';
import 'package:fahman_app/features/auth/login/ui/splash_login_screen.dart';
import 'package:fahman_app/features/auth/login/ui/login_email_screen.dart';
import 'package:fahman_app/features/auth/register/register_email_screen.dart';
import 'package:fahman_app/features/auth/veify_email/ui/verify_email_screen.dart';
import 'package:fahman_app/features/screens/select_role_screen.dart';
import 'package:fahman_app/features/auth/compleate_profile/ui/complete_profile_screen.dart';

import 'package:fahman_app/features/profile/ui/profile_screen.dart';
import 'package:fahman_app/features/profile/edit_profile/ui/edit_profile_screen.dart';
import 'package:fahman_app/features/auth/change_password/ui/change_password_screen.dart';
import 'package:fahman_app/features/settings/screens/settings_screen.dart';
import 'package:fahman_app/features/notifications/notifications_screen.dart';
import 'package:fahman_app/features/legal_articles/ui/legal_articles_screen.dart';
import 'package:fahman_app/features/legal_articles/ui/article_comments_screen.dart';
import 'package:fahman_app/features/legal_articles/ui/article_detail_screen.dart';
import 'package:fahman_app/core/models/article_response_model.dart';
import 'package:fahman_app/shared/widgets/privcy.dart';
import 'package:fahman_app/shared/widgets/terms_condition.dart';
import 'package:fahman_app/features/consultation/ui/consent_form.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashLoginScreen(),
          settings: settings,
        );
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case Routes.voiceRecord:
        return MaterialPageRoute(
          builder: (_) => const VoiceRecordScreen(),
          settings: settings,
        );
      case Routes.loginEmail:
        return MaterialPageRoute(
          builder: (_) => const LoginEmailScreen(),
          settings: settings,
        );
      case Routes.registerEmail:
        return MaterialPageRoute(
          builder: (_) => const RegisterEmailScreen(),
          settings: settings,
        );
      case Routes.verifyEmail:
        return MaterialPageRoute(
          builder: (_) => const VerifyEmailScreen(),
          settings: settings,
        );
      case Routes.selectRole:
        return MaterialPageRoute(
          builder: (_) => const SelectRoleScreen(),
          settings: settings,
        );
      case Routes.completeProfile:
        return MaterialPageRoute(
          builder: (_) => const CompleteProfileScreen(),
          settings: settings,
        );
      case Routes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case Routes.verifyOtpPassword:
        final cubit = settings.arguments as ForgotPasswordCubit?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit!,
            child: const VerifyOtpPasswordScreen(),
          ),
          settings: settings,
        );
      case Routes.resetPassword:
        final cubit = settings.arguments as ForgotPasswordCubit?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit!,
            child: const ResetPasswordScreen(),
          ),
          settings: settings,
        );
      case Routes.voiceResult:
        final args = settings.arguments;
        final text = (args is String) ? args : '';
        return MaterialPageRoute(
          builder: (_) => VoiceResultScreen(text: text),
          settings: settings,
        );
      case Routes.consultation:
        final args = settings.arguments;
        final initialTypeKey = (args is String)
            ? args
            : 'consultation_type_legal';
        return MaterialPageRoute(
          builder: (_) => ConsultationScreen(initialTypeKey: initialTypeKey),
          settings: settings,
        );
      case Routes.consultationTypeSelection:
        return MaterialPageRoute(
          builder: (_) => const ConsultationTypeSelectionScreen(),
          settings: settings,
        );
      case Routes.consultationForm:
        final args = settings.arguments;
        final initialTypeKey = (args is String)
            ? args
            : 'consultation_type_legal';
        return MaterialPageRoute(
          builder: (_) => ConsultationScreen(initialTypeKey: initialTypeKey),
          settings: settings,
        );
      case Routes.inquiry:
        // Check if there's an initial message from voice recording
        final args = settings.arguments;
        String? initialMessage;
        if (args is Map<String, dynamic>) {
          initialMessage = args['initialMessage'] as String?;
        }
        return MaterialPageRoute(
          builder: (_) => InquiryScreen(initialMessage: initialMessage),
          settings: settings,
        );
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case Routes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );
      case Routes.changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: settings,
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case Routes.myConsultations:
        return MaterialPageRoute(
          builder: (_) => const MyConsultationsScreen(),
          settings: settings,
        );
      case Routes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );
      case Routes.legalArticles:
        return MaterialPageRoute(
          builder: (_) => const LegalArticlesScreen(),
          settings: settings,
        );
      case Routes.articleComments:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ArticleCommentsScreen(
            articleId: args['articleId'] as int,
            articleTitle: args['articleTitle'] as String,
          ),
          settings: settings,
        );
      case Routes.articleDetail:
        final article = settings.arguments as ArticleResponseModel;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
          settings: settings,
        );
      case Routes.privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
          settings: settings,
        );
      case Routes.termsConditions:
        return MaterialPageRoute(
          builder: (_) => const TermsConditionsScreen(),
          settings: settings,
        );
      case Routes.consentForm:
        return MaterialPageRoute(
          builder: (_) => const ConsentFormScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('route_not_found'.tr()))),
          settings: settings,
        );
    }
  }
}
