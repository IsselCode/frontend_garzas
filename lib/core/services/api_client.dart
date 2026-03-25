import 'dart:convert';
import 'dart:io';

import 'package:frontend_garzas/core/errors/exceptions.dart';

typedef AccessTokenProvider = Future<String?> Function();
typedef UnauthorizedHandler = Future<bool> Function();

class ApiError {
  String code;
  String detail;

  ApiError({required this.code, required this.detail});
}

class ApiClient {
  final HttpClient _httpClient;
  final String baseUrl;

  AccessTokenProvider? _accessTokenProvider;
  UnauthorizedHandler? _unauthorizedHandler;

  ApiClient({
    HttpClient? httpClient,
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/api/v1',
    ),
  }) : _httpClient = httpClient ?? HttpClient();

  void configureAuth({
    AccessTokenProvider? accessTokenProvider,
    UnauthorizedHandler? unauthorizedHandler,
  }) {
    _accessTokenProvider = accessTokenProvider;
    _unauthorizedHandler = unauthorizedHandler;
  }

  Future<dynamic> get(
    String path, {
    bool authRequired = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) {
    return _send(
      method: 'GET',
      path: path,
      authRequired: authRequired,
      headers: headers,
      queryParams: queryParams,
    );
  }

  Future<dynamic> post(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) {
    return _send(
      method: 'POST',
      path: path,
      authRequired: authRequired,
      body: body,
      headers: headers,
      queryParams: queryParams,
    );
  }

  Future<dynamic> patch(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      authRequired: authRequired,
      body: body,
      headers: headers,
      queryParams: queryParams,
    );
  }

  Future<dynamic> delete(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      authRequired: authRequired,
      body: body,
      headers: headers,
      queryParams: queryParams,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    required bool authRequired,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool retrying = false,
  }) async {
    final url = _buildUri(path, queryParams: queryParams);
    final request = await _openRequest(method, url);

    request.headers.contentType = ContentType.json;

    if (headers != null) {
      headers.forEach(request.headers.set);
    }

    if (authRequired) {
      final accessToken = await _accessTokenProvider?.call();
      if (accessToken == null || accessToken.isEmpty) {
        throw AppException(message: 'No existe un token de acceso disponible');
      }
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    if (body != null) {
      request.add(utf8.encode(jsonEncode(body)));
    }

    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);

    if (response.statusCode == 401 && authRequired && !retrying) {
      final refreshed = await _unauthorizedHandler?.call() ?? false;
      if (refreshed) {
        return _send(
          method: method,
          path: path,
          authRequired: authRequired,
          body: body,
          headers: headers,
          queryParams: queryParams,
          retrying: true,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        message: _extractMessage(decoded)?.detail ?? 'La solicitud a la API fallo (${response.statusCode})',
      );
    }

    if (decoded == null) {
      return <String, dynamic>{};
    }

    return decoded;
  }

  Future<HttpClientRequest> _openRequest(String method, Uri url) {
    switch (method) {
      case 'GET':
        return _httpClient.getUrl(url);
      case 'POST':
        return _httpClient.postUrl(url);
      case 'PATCH':
        return _httpClient.patchUrl(url);
      case 'DELETE':
        return _httpClient.deleteUrl(url);
      default:
        throw AppException(message: 'Metodo HTTP no soportado: $method');
    }
  }

  String _normalizeBaseUrl() {
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  String _normalizePath(String path) {
    if (path.startsWith('/')) return path;
    return '/$path';
  }

  Uri _buildUri(String path, {Map<String, dynamic>? queryParams}) {
    final baseUri = Uri.parse('${_normalizeBaseUrl()}${_normalizePath(path)}');

    if (queryParams == null || queryParams.isEmpty) {
      return baseUri;
    }

    final normalizedQueryParams = <String, String>{};

    queryParams.forEach((key, value) {
      if (value == null) return;
      normalizedQueryParams[key] = '$value';
    });

    return baseUri.replace(queryParameters: normalizedQueryParams);
  }

  ApiError? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final key in const ['message', 'detail', 'error']) {
        final value = decoded[key];
        if (value is Map<String, dynamic> && value.isNotEmpty) {
          return ApiError(code: value['code'], detail: value['detail']);
        }
      }

      if (decoded['data'] is Map<String, dynamic>) {
        return _extractMessage(decoded['data']);
      }
    }

    return null;
  }
}
