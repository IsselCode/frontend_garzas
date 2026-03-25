import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/auth/models/auth_session.dart';

class AuthApi {
  final ApiClient apiClient;
  final String loginPath;
  final String refreshPath;

  AuthApi({
    required this.apiClient,
    this.loginPath = const String.fromEnvironment('AUTH_LOGIN_PATH', defaultValue: '/auth/login',),
    this.refreshPath = const String.fromEnvironment('AUTH_REFRESH_PATH', defaultValue: '/auth/refresh',),
  });

  Future<AuthSession> signIn({required String username, required String password,}) async {
    final response = await apiClient.post(
      loginPath,
      authRequired: false,
      body: {'username': username, 'password': password},
    );

    return _buildSessionFromResponse(response);
  }

  Future<AuthSession> refreshToken({required String refreshToken, String? previousRefreshToken}) async {
    final response = await apiClient.post(
      refreshPath,
      authRequired: false,
      body: {'refresh_token': refreshToken},
    );

    return _buildSessionFromResponse(
      response,
      fallbackRefreshToken: previousRefreshToken ?? refreshToken,
    );
  }

  AuthSession _buildSessionFromResponse(Map<String, dynamic> data, {String? fallbackRefreshToken,}) {
    final accessToken = _readString(
      data,
      keys: const ['access_token', 'access', 'token'],
    );

    final refreshToken = _readOptionalString(data, keys: const ['refresh_token', 'refresh']) ?? fallbackRefreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      throw AppException(
        message: 'La respuesta no contiene un refresh token valido',
      );
    }

    return AuthSession.fromTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  String _readString(Map<String, dynamic> data, {required List<String> keys}) {
    final value = _readOptionalString(data, keys: keys);
    if (value == null || value.isEmpty) {
      throw AppException(
        message: 'La respuesta no contiene los tokens esperados',
      );
    }
    return value;
  }

  String? _readOptionalString(Map<String, dynamic> data, {required List<String> keys}) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
