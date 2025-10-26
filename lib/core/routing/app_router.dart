import 'package:flutter/material.dart';
import 'package:fahman_app/core/routing/routes.dart';
import 'package:fahman_app/features/ui/home/home_screen.dart';
import 'package:fahman_app/features/ui/voice/voice_record_screen.dart';
import 'package:fahman_app/features/ui/voice/voice_result_screen.dart';
import 'package:fahman_app/features/ui/consultation/consultation_screen.dart';
import 'package:fahman_app/features/ui/consultation/consultation_type_selection_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/splash_login_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/login_email_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/register_email_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/verify_email_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/select_role_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/complete_profile_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/forgot_password_screen.dart';
import 'package:fahman_app/features/ui/auth/screens/reset_password_screen.dart';
import 'package:fahman_app/features/ui/inquiry/inquiry_screen.dart';
import 'package:fahman_app/features/ui/settings/screens/profile_screen.dart';
import 'package:fahman_app/features/ui/settings/screens/edit_profile_screen.dart';
import 'package:fahman_app/features/ui/settings/screens/change_password_screen.dart';
import 'package:fahman_app/features/ui/settings/screens/settings_screen.dart';
import 'package:fahman_app/features/ui/notifications/notifications_screen.dart';
import 'package:fahman_app/features/ui/legal_articles/legal_articles_screen.dart';
import 'package:fahman_app/features/ui/legal_articles/create_article_screen.dart';

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
      case Routes.resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
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
        return MaterialPageRoute(
          builder: (_) => const InquiryScreen(),
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
      case Routes.createArticle:
        return MaterialPageRoute(
          builder: (_) => const CreateArticleScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
          settings: settings,
        );
    }
  }
}
