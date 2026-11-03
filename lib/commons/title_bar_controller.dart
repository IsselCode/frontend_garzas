import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app/theme.dart';
import '../core/services/app_preferences.dart';

class TitleBarController extends ChangeNotifier {
  TitleBarController({required AppPreferences appPreferences})
    : _appPreferences = appPreferences,
      _isDarkMode = appPreferences.darkMode;

  final AppPreferences _appPreferences;
  String _title = "";
  bool _showElements = false;
  bool _isDarkMode;

  String get title => _title;
  bool get showElements => _showElements;
  bool get isDarkMode => _isDarkMode;
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  //* Name
  void setTitle(String value) {
    if (_title == value) return;
    _title = value;
    notifyListeners();
  }

  //* Theme
  void toggleTheme() {
    unawaited(setDarkMode(!_isDarkMode));
  }

  Future<bool> setDarkMode(bool value) async {
    if (_isDarkMode == value) return true;
    _isDarkMode = value;
    notifyListeners();
    final saved = await _appPreferences.setDarkMode(value);
    if (!saved) {
      _isDarkMode = _appPreferences.darkMode;
      notifyListeners();
    }
    return saved;
  }

  //* Show elements
  void _setShowElements(bool value) {
    if (_showElements == value) return;
    _showElements = value;
    notifyListeners();
  }

  void showAllElements() => _setShowElements(true);
  void hideAllElements() => _setShowElements(false);
}
