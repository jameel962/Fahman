import 'package:fahman_app/app_logger.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

/// Service to handle token refresh operations
class TokenRefreshService {
  final ApiConsumer apiConsumer;

  TokenRefreshService({required this.apiConsumer});

  /// Refresh the access token using the refresh token
  /// Returns the new access token or null if refresh failed
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = AuthSession().refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.e('TokenRefreshService: No refresh token available');
        return null;
      }

      AppLogger.d('TokenRefreshService: Attempting token refresh...');

      final path = EndPoints.withParams(EndPoints.refreshToken, {
        'refreshToken': refreshToken,
      });

      final response = await apiConsumer.post(path, isFormData: false);

      AppLogger.d('TokenRefreshService: Response received');

      if (response == null) {
        AppLogger.e('TokenRefreshService: Null response from server');
        return null;
      }

      // Extract tokens from response
      final data = response is Map<String, dynamic>
          ? response
          : response['data'] as Map<String, dynamic>?;

      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        AppLogger.d('TokenRefreshService: Got new access token');

        // Update tokens in session
        await AuthSession().setToken(newAccessToken);

        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          AppLogger.d('TokenRefreshService: Got new refresh token');
          await AuthSession().setRefreshToken(newRefreshToken);
        }

        return newAccessToken;
      } else {
        AppLogger.e('TokenRefreshService: No access token in response');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e('TokenRefreshService: Error refreshing token', e);
      AppLogger.e('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Check if token refresh is needed (e.g., token expired)
  /// This is a simple implementation - you might want to add JWT expiry checking
  bool shouldRefreshToken() {
    final token = AuthSession().token;
    final refreshToken = AuthSession().refreshToken;

    // If no access token but have refresh token, should refresh
    if ((token == null || token.isEmpty) &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      return true;
    }

    return false;
  }
}
