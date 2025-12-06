import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/networking/errors/exceptions.dart';
import 'register_state.dart';
import '../data/register_repository.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository repository;

  RegisterCubit({required this.repository}) : super(const RegisterState());

  /// Update email field and optionally validate
  void updateEmail(String value, {bool validateNow = true}) {
    emit(state.copyWith(email: value, error: null, emailError: null));
    if (validateNow) validateEmail();
  }

  /// Update password field and optionally validate
  void updatePassword(String value, {bool validateNow = true}) {
    emit(state.copyWith(password: value, error: null, passwordError: null));
    if (validateNow) validatePassword();
  }

  /// Update confirm password field and optionally validate
  void updateConfirmPassword(String value, {bool validateNow = true}) {
    emit(
      state.copyWith(
        confirmPassword: value,
        error: null,
        confirmPasswordError: null,
      ),
    );
    if (validateNow) validateConfirmPassword();
  }

  /// Update terms acceptance
  void updateTermsAcceptance(bool value) {
    emit(state.copyWith(acceptedTerms: value, error: null, termsError: null));
  }

  /// Validate email field
  void validateEmail() {
    final email = state.email.trim();
    String? msg;
    if (email.isEmpty) {
      msg = 'auth_email_required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      msg = 'auth_email_invalid';
    }
    emit(state.copyWith(emailError: msg));
  }

  /// Validate password field
  void validatePassword() {
    final password = state.password;
    String? msg;
    if (password.isEmpty) {
      msg = 'auth_password_required';
    } else if (password.length < 8) {
      msg = 'auth_password_too_short';
    } else if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      // Must contain at least one letter
      msg = 'auth_password_no_letter';
    } else if (!RegExp(r'\d').hasMatch(password)) {
      // Must contain at least one number
      msg = 'auth_password_no_number';
    } else if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]',
    ).hasMatch(password)) {
      // Must contain at least one special character
      msg = 'auth_password_no_special_char';
    } else if (password.length > 50) {
      msg = 'auth_password_too_long';
    }
    emit(state.copyWith(passwordError: msg));
  }

  /// Validate confirm password field
  void validateConfirmPassword() {
    final confirmPassword = state.confirmPassword;
    final password = state.password;
    String? msg;
    if (confirmPassword.isEmpty) {
      msg = 'auth_confirm_password_required';
    } else if (confirmPassword != password) {
      msg = 'auth_passwords_do_not_match';
    }
    emit(state.copyWith(confirmPasswordError: msg));
  }

  /// Validate terms acceptance
  void validateTermsAcceptance() {
    String? msg;
    if (!state.acceptedTerms) {
      msg = 'must_accept_terms'; // Will be translated in UI
    }
    emit(state.copyWith(termsError: msg));
  }

  /// Validate all fields. Returns true when valid.
  bool validateAll() {
    final email = state.email.trim();
    final password = state.password;
    final confirmPassword = state.confirmPassword;
    final acceptedTerms = state.acceptedTerms;

    String? emailError;
    String? passwordError;
    String? confirmPasswordError;
    String? termsError;

    // Validate email
    if (email.isEmpty) {
      emailError = 'auth_email_required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError = 'auth_email_invalid';
    }

    // Validate password
    if (password.isEmpty) {
      passwordError = 'auth_password_required';
    } else if (password.length < 8) {
      passwordError = 'auth_password_too_short';
    } else if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      passwordError = 'auth_password_no_letter';
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      passwordError = 'auth_password_no_number';
    } else if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]',
    ).hasMatch(password)) {
      passwordError = 'auth_password_no_special_char';
    } else if (password.length > 50) {
      passwordError = 'auth_password_too_long';
    }

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'auth_confirm_password_required';
    } else if (confirmPassword != password) {
      confirmPasswordError = 'auth_passwords_do_not_match';
    }

    // Validate terms acceptance
    if (!acceptedTerms) {
      termsError = 'must_accept_terms';
    }

    // Emit all validation errors at once
    if (emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        termsError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
          termsError: termsError,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> registerCustomer() async {
    // run validation first
    if (!validateAll()) return;

    emit(state.copyWith(status: RegisterStatus.loading, error: null));
    try {
      final res = await repository.registerCustomer(
        email: state.email,
        password: state.password,
        confirmPassword: state.confirmPassword,
        agreeTermsAndPolicy: state.acceptedTerms,
      );
      if (res['success'] == true && res['userID'] != null) {
        emit(
          state.copyWith(status: RegisterStatus.success, userID: res['userID']),
        );
      } else {
        final apiMsg = res['message'] != null
            ? res['message'].toString()
            : 'Registration failed.';
        emit(state.copyWith(status: RegisterStatus.failure, error: apiMsg));
      }
    } on ServerException catch (se) {
      final apiMsg = se.errModel.message.isNotEmpty
          ? se.errModel.message
          : 'Registration failed.';
      emit(state.copyWith(status: RegisterStatus.failure, error: apiMsg));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  void clearError() => emit(state.copyWith(error: null));

  void reset() => emit(const RegisterState());
}
