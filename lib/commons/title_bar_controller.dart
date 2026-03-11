import 'package:flutter/material.dart';

import '../core/app/theme.dart';

class TitleBarController extends ChangeNotifier {

  String _title = "";
  bool _showElements = false;
  ThemeData _themeData = lightTheme;

  String get title => _title;
  bool get showElements => _showElements;
  bool get isDarkMode => _themeData == darkTheme;
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  //* Name
  void setTitle(String value) {
    if (_title == value) return;
    _title = value;
    notifyListeners();
  }

  //* Theme
  void toggleTheme() {
    if (_themeData == lightTheme) {
      _themeData = darkTheme;
    } else {
      _themeData = lightTheme;
    }
    notifyListeners();
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
