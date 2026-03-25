import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

class AuthSession extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String uid;
  final String username;
  final String displayName;
  final AppRole role;
  final DateTime expiresAt;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.uid,
    required this.username,
    required this.displayName,
    required this.role,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get shouldRefreshSoon => DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));

  factory AuthSession.fromTokens({required String accessToken, required String refreshToken}) {
    final claims = _decodeJwtPayload(accessToken);
    final exp = claims['exp'];

    if (exp is! int) {
      throw AppException(message: 'El token no contiene una expiracion valida');
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      uid: '${claims['uid'] ?? ''}',
      username: '${claims['sub'] ?? ''}',
      displayName: '${claims['display_name'] ?? claims['sub'] ?? ''}',
      role: AppRole.fromString('${claims['role'] ?? ''}'),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(exp * 1000),
    );
  }

  factory AuthSession.fromMap(Map<String, dynamic> map) {
    return AuthSession(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      uid: map['uid'] as String,
      username: map['username'] as String,
      displayName: map['display_name'] as String,
      role: AppRole.fromString(map['role'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'uid': uid,
      'username': username,
      'display_name': displayName,
      'role': role.name,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw AppException(message: 'El formato del token es invalido');
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        throw AppException(message: 'El payload del token es invalido');
      }

      return decoded;
    } catch (_) {
      throw AppException(message: 'No fue posible decodificar el token');
    }
  }

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    uid,
    username,
    displayName,
    role,
    expiresAt,
  ];
}
