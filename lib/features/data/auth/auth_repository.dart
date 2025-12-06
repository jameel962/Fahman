import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/features/data/auth/models/user_info.dart';

class AuthRepository {
  final ApiConsumer apiConsumer;
  AuthRepository({required this.apiConsumer});

  Future<UserInfo?> getUserInfo() async {
    try {
      final res = await apiConsumer.get('/Auth/GetUserInfo');
      // API returns { success: true, user: { ... } }
      if (res is Map) {
        final map = Map<String, dynamic>.from(res);
        final user = map['user'];
        if (user is Map<String, dynamic>) return UserInfo.fromMap(user);
        if (user is Map)
          return UserInfo.fromMap(Map<String, dynamic>.from(user));
        // fallback: try to parse top-level as user
        return UserInfo.fromMap(map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> logout(String? refreshToken) async {
    try {
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Use path parameter as per API specification
      final path = EndPoints.withParams(EndPoints.logout, {
        'refreshToken': refreshToken,
      });

      await apiConsumer.post(path);
      return true;
    } catch (e) {
      // Log error for debugging
      print('Logout error: $e');
      return false;
    }
  }
}
