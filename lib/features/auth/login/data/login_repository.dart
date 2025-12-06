import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

class LoginRepository {
  final ApiConsumer apiConsumer;
  LoginRepository({required this.apiConsumer});

  /// Calls /Auth/login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
    String? fcmToken,
    String? deviceName,
  }) async {
    final body = {
      'identifer': identifier, // Note: API uses 'identifer' (typo in backend)
      'password': password,
      'rememberMe': rememberMe,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (deviceName != null) 'deviceName': deviceName,
    };

    print('');
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║           📤 SENDING LOGIN REQUEST TO API                   ║');
    print('╠══════════════════════════════════════════════════════════════╣');
    print('║  Endpoint: POST /Auth/login                                 ║');
    print('╠══════════════════════════════════════════════════════════════╣');
    print('║  Request Body:                                              ║');
    print('║  {                                                          ║');
    print('║    "identifer": "$identifier"${' ' * (40 - identifier.length)}║');
    print('║    "password": "***hidden***"                               ║');
    print(
      '║    "rememberMe": $rememberMe${rememberMe ? '                                      ' : '                                     '}║',
    );
    print(
      '║    "fcmToken": "${fcmToken != null ? '✅ Present (${fcmToken.length} chars)' : '❌ NULL'}"     ║',
    );
    print(
      '║    "deviceName": "${deviceName ?? '❌ NULL'}"${' ' * (38 - (deviceName?.length ?? 8))}║',
    );
    print('║  }                                                          ║');
    print('╚══════════════════════════════════════════════════════════════╝');
    print('');

    final response = await apiConsumer.post(EndPoints.login, data: body);
    // assume apiConsumer returns decoded JSON (Map)
    return response as Map<String, dynamic>;
  }
}
