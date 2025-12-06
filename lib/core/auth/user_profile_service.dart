import 'package:fahman_app/app_logger.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

/// Service to fetch and manage user profile data
class UserProfileService {
  final ApiConsumer apiConsumer;

  UserProfileService({required this.apiConsumer});

  /// Fetch user info from server and update local storage
  /// Returns true if successful
  Future<bool> fetchAndUpdateUserInfo() async {
    try {
      AppLogger.d('UserProfileService: Fetching user info from server...');

      final response = await apiConsumer.get(EndPoints.getUserInfo);

      if (response == null) {
        AppLogger.e('UserProfileService: Null response from server');
        return false;
      }

      AppLogger.d('UserProfileService: Response received');

      // Extract user data
      final data = response is Map<String, dynamic>
          ? response
          : response['data'] as Map<String, dynamic>?;

      if (data == null) {
        AppLogger.e('UserProfileService: No data in response');
        return false;
      }

      // Extract user fields
      final username = data['userName'] as String?;
      final userId = data['id'] as String?;

      AppLogger.d(
        'UserProfileService: Got user data - username: $username, userId: $userId',
      );

      // Update AuthSession with latest user data
      if (username != null && username.isNotEmpty) {
        await AuthSession().setUsername(username);
      }

      if (userId != null && userId.isNotEmpty) {
        await AuthSession().setUserId(userId);
      }

      AppLogger.d('UserProfileService: User info updated in local storage');
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('UserProfileService: Error fetching user info', e);
      AppLogger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get user info from local storage (cached)
  Map<String, String?> getCachedUserInfo() {
    return {'username': AuthSession().username, 'userId': AuthSession().userId};
  }
}
