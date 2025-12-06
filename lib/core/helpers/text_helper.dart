class TextHelper {
  /// Mask email address showing only first 2 characters of local part
  /// Example: john@example.com -> jo***@example.com
  static String maskEmail(String? email) {
    if (email == null || !email.contains('@')) return '******@******';
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    final visible = local.length >= 2 ? local.substring(0, 2) : local;
    return '$visible***@$domain';
  }

  /// Mask phone number showing only last 4 digits
  /// Example: +1234567890 -> ******7890
  static String maskPhone(String? phone) {
    if (phone == null || phone.length < 4) return '******';
    final visible = phone.substring(phone.length - 4);
    return '******$visible';
  }
}
