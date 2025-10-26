import 'package:fahman_app/core/network/dio_client.dart';

class AuthSession {
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  String? _token;
  String? _refreshToken;
  String? _username;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  bool get hasToken => _token != null && _token!.isNotEmpty;
  bool get hasRefreshToken =>
      _refreshToken != null && _refreshToken!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
    DioClient().setAuthToken(token);
  }

  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
  }

  void setUsername(String? name) {
    _username = name;
  }

  String? getRefreshToken() {
    return _refreshToken;
  }

  void clear() {
    _token = null;
    _refreshToken = null;
    _username = null;
    DioClient().setAuthToken(null);
  }
}
