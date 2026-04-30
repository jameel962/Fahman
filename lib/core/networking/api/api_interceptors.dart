import 'package:dio/dio.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/language/language_service.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';
import 'package:fahman_app/core/services/navigator_service.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/app_logger.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add Authorization header if token exists
    final token = AuthSession().token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    // Add Accept-Language header based on current locale (default: ar)
    final languageCode = LanguageService().currentLanguage;
    options.headers['Accept-Language'] = languageCode;

    AppLogger.d('🌐 API Request Headers - Accept-Language: $languageCode');

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    // Only attempt refresh on 401 Unauthorized
    if (status == 401) {
      AppLogger.d('ApiInterceptor: 401 detected, attempting token refresh');
      final refreshToken = AuthSession().refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final dio = Dio();
          dio.options.baseUrl = EndPoints.baseUrl;
          final refreshPath = EndPoints.withParams(EndPoints.refreshToken, {
            'refreshToken': refreshToken,
          });
          final refreshResp = await dio.post(refreshPath);
          final data = refreshResp.data as Map<String, dynamic>?;
          final newAccess = data?['accessToken'] as String?;
          final newRefresh = data?['refreshToken'] as String?;
          if (newAccess != null && newAccess.isNotEmpty) {
            await AuthSession().setToken(newAccess);
            AppLogger.d('ApiInterceptor: refreshed access token');
            if (newRefresh != null && newRefresh.isNotEmpty) {
              await AuthSession().setRefreshToken(newRefresh);
            }

            // Retry the original request with the new token
            final requestOptions = err.requestOptions;
            final retryDio = Dio();
            retryDio.options.baseUrl = EndPoints.baseUrl;
            // set header correctly
            requestOptions.headers['Authorization'] = 'Bearer $newAccess';
            try {
              final retryResp = await retryDio.fetch(requestOptions);
              return handler.resolve(retryResp);
            } catch (retryErr) {
              AppLogger.e('ApiInterceptor: retry failed', retryErr);
              // If retry failed, fall-through to next so caller handles error.
              // Also force logout to force re-login flow.
              await AuthSession().clear();
              try {
                NavigatorService.navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil(Routes.loginEmail, (r) => false);
              } catch (_) {}
              return handler.next(err);
            }
          }
        } catch (refreshError) {
          AppLogger.e('ApiInterceptor: token refresh failed', refreshError);
          // Refresh failed -> clear session and navigate to login
          await AuthSession().clear();
          try {
            NavigatorService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Routes.loginEmail,
              (r) => false,
            );
          } catch (_) {}
          return handler.next(err);
        }
      } else {
        // No refresh token available: force logout and navigate to login
        AppLogger.d('ApiInterceptor: no refresh token -> forcing logout');
        await AuthSession().clear();
        try {
          NavigatorService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.loginEmail,
            (r) => false,
          );
        } catch (_) {}
        return handler.next(err);
      }
    }

    super.onError(err, handler);
  }
}
