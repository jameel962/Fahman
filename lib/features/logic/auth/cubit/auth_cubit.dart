import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/logic/auth/validators/auth_validator.dart';
import 'package:fahman_app/features/data/auth/repositories/auth_repository.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';

class AuthState {
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final String? submitError;

  const AuthState({
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    this.submitError,
  });

  AuthState copyWith({
    String? emailError,
    String? passwordError,
    bool? isSubmitting,
    String? submitError,
  }) {
    return AuthState(
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  AuthCubit({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      super(const AuthState());

  void onEmailChanged(String value) {
    final err = AuthValidator.validateEmail(value);
    emit(state.copyWith(emailError: err));
  }

  void onPasswordChanged(String value) {
    final err = AuthValidator.validatePassword(value);
    emit(state.copyWith(passwordError: err));
  }

  Future<void> submitLogin(
    String identifier,
    String password, {
    required bool rememberMe,
  }) async {
    final emailErr = AuthValidator.validateEmail(identifier);
    final passErr = AuthValidator.validatePassword(password);
    emit(state.copyWith(emailError: emailErr, passwordError: passErr));
    if (emailErr != null || passErr != null) {
      return;
    }
    emit(state.copyWith(isSubmitting: true, submitError: null));
    final request = LoginRequest(
      identifer: identifier,
      password: password,
      rememberMe: rememberMe,
    );
    final result = await _repository.login(request);
    if (!result.success) {
      emit(state.copyWith(isSubmitting: false, submitError: result.message));
    } else {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
