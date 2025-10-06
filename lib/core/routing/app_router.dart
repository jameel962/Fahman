import 'package:flutter/material.dart';
import 'routes.dart';
import '../../features/home/home_screen.dart';
import '../../features/voice/voice_record_screen.dart';
import '../../features/voice/voice_result_screen.dart';
import '../../features/consultation/consultation_screen.dart';

class AppRouter {
  Route<dynamic> genrateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case Routes.voiceResult:
        final args = settings.arguments;
        final text = (args is String) ? args : '';
        return MaterialPageRoute(
          builder: (_) => VoiceResultScreen(text: text),
          settings: settings,
        );
      case Routes.consultation:
        final args = settings.arguments;
        final initialTypeKey = (args is String) ? args : 'consultation_type_legal';
        return MaterialPageRoute(
          builder: (_) => ConsultationScreen(initialTypeKey: initialTypeKey),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          settings: settings,
        );
    }
  }
}