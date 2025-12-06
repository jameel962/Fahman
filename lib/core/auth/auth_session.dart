import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

  String? _token;
  String? _refreshToken;
  String? _username;
  String? _userId;

  // Getters
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  String? get userId => _userId;
  bool get hasToken => _token != null && _token!.isNotEmpty;
  bool get hasRefreshToken =>
      _refreshToken != null && _refreshToken!.isNotEmpty;
  bool get isAuthenticated => hasToken;

  /// Initialize the auth session (call this in main.dart)
  Future<void> init() async {
    print('🟢 AuthSession: init() called');
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🟡 AuthSession: SharedPreferences obtained');
      _token = prefs.getString(_tokenKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      _username = prefs.getString(_usernameKey);
      _userId = prefs.getString(_userIdKey);
      print(
        '✅ AuthSession: init() complete - token=${_token != null}, username=$_username',
      );
    } catch (e, stackTrace) {
      print('🔴 AuthSession: ERROR in init(): $e');
      print('🔴 AuthSession: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Set authentication token and save to storage
  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  /// Set refresh token and save to storage
  Future<void> setRefreshToken(String? refreshToken) async {
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    if (refreshToken == null) {
      await prefs.remove(_refreshTokenKey);
    } else {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Set username and save to storage
  Future<void> setUsername(String? username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    if (username == null) {
      await prefs.remove(_usernameKey);
    } else {
      await prefs.setString(_usernameKey, username);
    }
  }

  /// Set user ID and save to storage
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_userIdKey);
    } else {
      await prefs.setString(_userIdKey, userId);
    }
  }

  /// Set complete user authentication data
  Future<void> setAuthData({
    String? token,
    String? refreshToken,
    String? username,
    String? userId,
  }) async {
    await Future.wait([
      setToken(token),
      setRefreshToken(refreshToken),
      setUsername(username),
      setUserId(userId),
    ]);
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _refreshToken;
  }

  /// Check if user is authenticated
  bool isLoggedIn() {
    return hasToken;
  }

  /// Clear all authentication data
  Future<void> clear() async {
    _token = null;
    _refreshToken = null;
    _username = null;
    _userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  /// Logout user (alias for clear)
  Future<void> logout() async {
    await clear();
  }

  /// Refresh authentication data from storage
  Future<void> refreshFromStorage() async {
    await init();
  }
}
