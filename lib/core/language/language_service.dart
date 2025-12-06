/// Service to track current app language for use in API requests
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'ar'; // Default to Arabic

  /// Get the current language code ('ar' or 'en')
  String get currentLanguage => _currentLanguage;

  /// Set the current language code
  void setLanguage(String languageCode) {
    if (languageCode == 'ar' || languageCode == 'en') {
      _currentLanguage = languageCode;
    }
  }
}
