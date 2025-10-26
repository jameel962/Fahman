import 'package:easy_localization/easy_localization.dart';

class AuthValidator {
  static String? validateEmail(String email) {
    if (email.isEmpty) return 'auth_email_required'.tr();
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return 'auth_email_invalid'.tr();
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'auth_password_required'.tr();
    if (password.length < 6) return 'auth_password_short'.tr();
    return null;
  }
}
