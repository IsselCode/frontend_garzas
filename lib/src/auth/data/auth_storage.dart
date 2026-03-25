import 'dart:convert';

import 'package:frontend_garzas/src/auth/models/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _sessionKey = 'auth_session';

  final SharedPreferences sharedPreferences;

  AuthStorage({required this.sharedPreferences});

  Future<bool> saveSession(AuthSession session) {
    return sharedPreferences.setString(
      _sessionKey,
      jsonEncode(session.toMap()),
    );
  }

  AuthSession? readSession() {
    final rawSession = sharedPreferences.getString(_sessionKey);
    if (rawSession == null || rawSession.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawSession);
      if (decoded is! Map<String, dynamic>) return null;
      return AuthSession.fromMap(decoded);
    } catch (_) {
      sharedPreferences.remove(_sessionKey);
      return null;
    }
  }

  Future<bool> clearSession() {
    return sharedPreferences.remove(_sessionKey);
  }
}
