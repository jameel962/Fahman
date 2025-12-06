import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/auth/change_password/data/change_password_repository.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordRepository repository;

  ChangePasswordCubit({required this.repository})
    : super(const ChangePasswordState());

  void updateCurrentPassword(String value) {
    emit(state.copyWith(currentPassword: value, errorMessage: null));
  }

  void updateNewPassword(String value) {
    emit(state.copyWith(newPassword: value, errorMessage: null));
  }

  void updateConfirmNewPassword(String value) {
    emit(state.copyWith(confirmNewPassword: value, errorMessage: null));
  }

  /// Validate all fields before submission
  String? validate() {
    // Current password validation
    if (state.currentPassword.trim().isEmpty) {
      return 'auth_current_password_required'; // Localization key
    }

    // New password validation
    if (state.newPassword.trim().isEmpty) {
      return 'auth_new_password_required'; // Localization key
    }

    if (state.newPassword.trim().length < 6) {
      return 'auth_password_min_length'; // Localization key
    }

    // Confirm password validation
    if (state.newPassword.trim() != state.confirmNewPassword.trim()) {
      return 'auth_password_mismatch'; // Localization key
    }

    // Check if new password is different from current
    if (state.currentPassword.trim() == state.newPassword.trim()) {
      return 'يجب أن تكون كلمة المرور الجديدة مختلفة عن الحالية';
    }

    return null; // No errors
  }

  Future<bool> submit() async {
    // Validate
    final validationError = validate();
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError));
      return false;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));

    try {
      final response = await repository.changePassword(
        currentPassword: state.currentPassword.trim(),
        newPassword: state.newPassword.trim(),
        confirmNewPassword: state.confirmNewPassword.trim(),
      );

      final success = response['success'] as bool? ?? false;

      if (success) {
        emit(
          state.copyWith(isLoading: false, isSuccess: true, errorMessage: null),
        );
        return true;
      } else {
        // Extract error message from server response
        final serverMessage =
            response['message'] as String? ??
            response['errorMessage'] as String? ??
            response['error'] as String? ??
            'فشل في تغيير كلمة المرور';

        emit(state.copyWith(isLoading: false, errorMessage: serverMessage));
        return false;
      }
    } catch (e) {
      // Extract error message from exception if available
      String errorMessage = 'خطأ في تغيير كلمة المرور';

      if (e.toString().contains('message')) {
        // Try to extract message from error string
        errorMessage = e.toString();
      }

      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
      return false;
    }
  }

  void reset() {
    emit(const ChangePasswordState());
  }
}
