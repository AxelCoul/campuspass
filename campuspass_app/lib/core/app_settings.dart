import 'package:flutter/material.dart';

/// Configuration globale simple pour le thème et la langue.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'fr';

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguageCode(String code) {
    if (code == _languageCode) return;
    _languageCode = code;
    notifyListeners();
  }
}

