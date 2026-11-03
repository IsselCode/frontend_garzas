import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferences for this workstation, separate from the business configuration.
class AppPreferences extends ChangeNotifier {
  AppPreferences({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  bool get rememberSession =>
      sharedPreferences.getBool('remember_session') ?? true;
  bool get confirmBeforeLogout =>
      sharedPreferences.getBool('confirm_before_logout') ?? true;
  bool get darkMode => sharedPreferences.getBool('dark_mode') ?? false;
  bool get startMaximized =>
      sharedPreferences.getBool('start_maximized') ?? false;

  Future<bool> setRememberSession(bool value) =>
      _save('remember_session', value);
  Future<bool> setConfirmBeforeLogout(bool value) =>
      _save('confirm_before_logout', value);
  Future<bool> setDarkMode(bool value) => _save('dark_mode', value);
  Future<bool> setStartMaximized(bool value) => _save('start_maximized', value);

  Future<bool> _save(String key, bool value) async {
    final saved = await sharedPreferences.setBool(key, value);
    if (saved) notifyListeners();
    return saved;
  }
}
