part of 'forgot_password_cubit.dart';

class ForgotPasswordState {
  final String identifier;
  final String otp;
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  final bool isLoading;
  final String? errorMessage;
  final bool otpSent;
  final bool otpVerified;
  final bool passwordReset;

  const ForgotPasswordState({
    this.identifier = '',
    this.otp = '',
    this.resetToken = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.otpSent = false,
    this.otpVerified = false,
    this.passwordReset = false,
  });

  ForgotPasswordState copyWith({
    String? identifier,
    String? otp,
    String? resetToken,
    String? newPassword,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    bool? otpSent,
    bool? otpVerified,
    bool? passwordReset,
  }) {
    return ForgotPasswordState(
      identifier: identifier ?? this.identifier,
      otp: otp ?? this.otp,
      resetToken: resetToken ?? this.resetToken,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      otpSent: otpSent ?? this.otpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      passwordReset: passwordReset ?? this.passwordReset,
    );
  }
}
