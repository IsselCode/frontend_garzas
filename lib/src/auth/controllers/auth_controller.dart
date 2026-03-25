import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/views/home_admin_view.dart';
import 'package:frontend_garzas/src/auth/data/auth_api.dart';
import 'package:frontend_garzas/src/auth/data/auth_storage.dart';
import 'package:frontend_garzas/src/auth/models/auth_session.dart';
import 'package:frontend_garzas/src/auth/views/sign_in_view.dart';
import 'package:frontend_garzas/src/dispatch/views/home_dispatch_view.dart';
import 'package:frontend_garzas/src/sales/views/home_sales_view.dart';

class AuthController extends ChangeNotifier {
  final AuthApi authApi;
  final AuthStorage authStorage;
  final ApiClient apiClient;
  final NavigationService navigationService;
  final TitleBarController titleBarController;

  AuthController({
    required this.authApi,
    required this.authStorage,
    required this.apiClient,
    required this.navigationService,
    required this.titleBarController,
  }) {
    apiClient.configureAuth(
      accessTokenProvider: () async => _session?.accessToken,
      unauthorizedHandler: () async {
        final response = await refreshSession(navigateOnFailure: true);
        return response.success;
      },
    );
  }

  AuthSession? _session;
  Timer? _refreshTimer;
  Future<CtrlResponse>? _refreshRequest;
  bool _isLoading = false;
  bool _initialized = false;

  AuthSession? get session => _session;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _session != null;
  bool get initialized => _initialized;
  String? get accessToken => _session?.accessToken;
  AppRole? get role => _session?.role;

  //! Sessión

  Future<CtrlResponse> signIn(String username, String password) async {
    _setLoading(true);

    try {
      final session = await authApi.signIn(
        username: username,
        password: password,
      );

      await _setSession(session, persist: true);

      return CtrlResponse(success: true, message: 'Inicio de sesion exitoso');
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    } catch (e) {
      return CtrlResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _initialized = true;
      _setLoading(false);
    }
  }

  Future<CtrlResponse> restoreSession() async {
    _setLoading(true);

    try {
      final storedSession = authStorage.readSession();
      _initialized = true;

      if (storedSession == null) {
        await _clearSession(persist: false);
        _navigateToSignIn();
        return CtrlResponse(success: false);
      }

      if (!storedSession.isExpired && !storedSession.shouldRefreshSoon) {
        await _setSession(storedSession, persist: false);
        _navigateToHome();
        return CtrlResponse(success: true);
      }

      return refreshSession(navigateOnFailure: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<CtrlResponse> refreshSession({bool navigateOnFailure = false}) async {
    if (_refreshRequest != null) {
      return _refreshRequest!;
    }

    _refreshRequest = _performRefresh(navigateOnFailure: navigateOnFailure);
    final response = await _refreshRequest!;
    _refreshRequest = null;
    return response;
  }

  Future<void> logout() async {
    await _clearSession();
    _navigateToSignIn();
  }

  void navigateToHome() {
    _navigateToHome();
  }

  Future<CtrlResponse> _performRefresh({
    required bool navigateOnFailure,
  }) async {
    final currentSession = _session ?? authStorage.readSession();

    if (currentSession == null) {
      if (navigateOnFailure) {
        await _clearSession();
        _navigateToSignIn();
      }
      return CtrlResponse(
        success: false,
        message: 'No existe una sesion activa',
      );
    }

    try {
      final refreshedSession = await authApi.refreshToken(
        refreshToken: currentSession.refreshToken,
        previousRefreshToken: currentSession.refreshToken,
      );

      await _setSession(refreshedSession, persist: true);
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      await _clearSession();
      if (navigateOnFailure) {
        _navigateToSignIn();
      }
      return CtrlResponse(success: false, message: e.message);
    } catch (_) {
      await _clearSession();
      if (navigateOnFailure) {
        _navigateToSignIn();
      }
      return CtrlResponse(
        success: false,
        message: 'No fue posible refrescar la sesion',
      );
    }
  }

  Future<void> _setSession(
    AuthSession newSession, {
    required bool persist,
  }) async {
    _session = newSession;
    titleBarController.setTitle(newSession.displayName);
    _scheduleRefresh();

    if (persist) {
      await authStorage.saveSession(newSession);
    }

    notifyListeners();
  }

  Future<void> _clearSession({bool persist = true}) async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _session = null;
    titleBarController.setTitle('');

    if (persist) {
      await authStorage.clearSession();
    }

    notifyListeners();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();

    final currentSession = _session;
    if (currentSession == null) return;

    final refreshIn = currentSession.expiresAt
        .subtract(const Duration(minutes: 5))
        .difference(DateTime.now());

    if (refreshIn.isNegative) {
      unawaited(refreshSession(navigateOnFailure: true));
      return;
    }

    _refreshTimer = Timer(refreshIn, () {
      unawaited(refreshSession(navigateOnFailure: true));
    });
  }

  void _navigateToHome() {
    final currentSession = _session;
    if (currentSession == null) {
      _navigateToSignIn();
      return;
    }

    switch (currentSession.role) {
      case AppRole.admin:
        navigationService.pushAndRemoveUntil(const HomeAdminView());
        return;
      case AppRole.dispatch:
        navigationService.pushAndRemoveUntil(const HomeDispatchView());
        return;
      case AppRole.seller:
        navigationService.pushAndRemoveUntil(const HomeSalesView());
        return;
    }
  }

  void _navigateToSignIn() {
    navigationService.pushAndRemoveUntil(SignInView());
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
