class LoginState {
  final bool loading;
  final String? error; // general error (api)
  final Map<String, dynamic>? data;

  // form fields
  final String identifier;
  final String password;
  final bool rememberMe;

  // per-field validation messages
  final String? identifierError;
  final String? passwordError;

  const LoginState({
    this.loading = false,
    this.error,
    this.data,
    this.identifier = '',
    this.password = '',
    this.rememberMe = false,
    this.identifierError,
    this.passwordError,
  });

  bool get isValid =>
      identifierError == null &&
      passwordError == null &&
      identifier.isNotEmpty &&
      password.isNotEmpty;

  LoginState copyWith({
    bool? loading,
    String? error,
    Map<String, dynamic>? data,
    String? identifier,
    String? password,
    bool? rememberMe,
    String? identifierError,
    String? passwordError,
  }) {
    return LoginState(
      loading: loading ?? this.loading,
      error: error,
      data: data ?? this.data,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      identifierError: identifierError,
      passwordError: passwordError,
    );
  }
}
