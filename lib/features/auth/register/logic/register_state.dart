import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final RegisterStatus status;
  final bool acceptedTerms;

  // per-field validation messages & general error
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? termsError;
  final String? error;
  final String? userID;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = RegisterStatus.initial,
    this.acceptedTerms = false,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.termsError,
    this.error,
    this.userID,
  });

  bool get isValid =>
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null &&
      termsError == null &&
      acceptedTerms;

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    RegisterStatus? status,
    bool? acceptedTerms,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? termsError,
    String? error,
    String? userID,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      termsError: termsError,
      error: error,
      userID: userID ?? this.userID,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    confirmPassword,
    status,
    acceptedTerms,
    emailError,
    passwordError,
    confirmPasswordError,
    termsError,
    error,
    userID,
  ];
}
