import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'user_language_code';
  Locale _locale = const Locale('fr');
  bool _languageChanged = false;

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final languageCode = preferences.getString(_languageKey);
      if (!_languageChanged && (languageCode == 'en' || languageCode == 'fr')) {
        // The guard above restricts this value to the two supported,
        // non-null language codes.
        _locale = Locale(languageCode!);
        notifyListeners();
      }
    } catch (_) {
      // The application remains usable in French if preferences are unavailable.
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final supportedLanguage = languageCode == 'en' ? 'en' : 'fr';
    _languageChanged = true;
    if (_locale.languageCode == supportedLanguage) return;

    _locale = Locale(supportedLanguage);
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_languageKey, supportedLanguage);
    } catch (_) {
      // Applying the language immediately takes priority over persistence.
    }
  }
}
