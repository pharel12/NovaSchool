import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  void changeLanguage(String languageCode) {
    if (languageCode == 'en') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('fr');
    }
    notifyListeners();
  }
}
