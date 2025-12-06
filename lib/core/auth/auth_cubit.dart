import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'package:fahman_app/core/auth/user_profile_service.dart';
import 'package:fahman_app/core/networking/api/api_consumer.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userId;
  final String? username;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userId,
    this.username,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? userId,
    String? username,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final AuthSession _authSession;
  final ApiConsumer? _apiConsumer;

  AuthCubit({required AuthSession authSession, ApiConsumer? apiConsumer})
    : _authSession = authSession,
      _apiConsumer = apiConsumer,
      super(const AuthState()) {
    _loadAuthState();
  }

  /// Load authentication state from AuthSession
  void _loadAuthState() {
    final isAuthenticated = _authSession.isAuthenticated;
    emit(
      state.copyWith(
        isAuthenticated: isAuthenticated,
        userId: _authSession.userId,
        username: _authSession.username,
      ),
    );
  }

  /// Login user with token and user data
  Future<void> login({
    required String token,
    required String refreshToken,
    String? username,
    String? userId,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _authSession.setAuthData(
        token: token,
        refreshToken: refreshToken,
        username: username,
        userId: userId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userId: userId,
          username: username,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Register user (same as login for now)
  Future<void> register({
    required String token,
    required String refreshToken,
    String? username,
    String? userId,
  }) async {
    await login(
      token: token,
      refreshToken: refreshToken,
      username: username,
      userId: userId,
    );
  }

  /// Logout user
  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _authSession.logout();

      emit(const AuthState(isAuthenticated: false, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Refresh authentication state
  Future<void> refreshAuthState() async {
    await _authSession.refreshFromStorage();
    _loadAuthState();
  }

  /// Fetch user profile from server and update local storage
  Future<bool> fetchUserProfile() async {
    if (_apiConsumer == null) {
      return false;
    }

    try {
      final profileService = UserProfileService(apiConsumer: _apiConsumer);
      final success = await profileService.fetchAndUpdateUserInfo();

      if (success) {
        // Reload auth state from updated storage
        await refreshAuthState();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;
  String? get currentUserId => state.userId;
  String? get currentUsername => state.username;
}
