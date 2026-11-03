import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/app_preferences.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/admin/data/general_api.dart';
import 'package:frontend_garzas/src/admin/views/home_admin_view.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/data/auth_api.dart';
import 'package:frontend_garzas/src/auth/data/auth_storage.dart';
import 'package:frontend_garzas/src/auth/models/auth_session.dart';
import 'package:frontend_garzas/src/auth/views/sign_in_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/admin_fixture_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController auth;
  late AuthStorage storage;
  late AppPreferences preferences;
  late TitleBarController title;
  late CashRegisterController cash;
  late GeneralConfigController general;
  late _AuthApi api;
  late _Navigation navigation;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    storage = AuthStorage(sharedPreferences: sharedPreferences);
    preferences = AppPreferences(sharedPreferences: sharedPreferences);
    title = TitleBarController(appPreferences: preferences);
    navigation = _Navigation();
    final client = AdminFixtureClient();
    api = _AuthApi(client);
    cash = CashRegisterController(
      cashRegisterApi: CashRegisterApi(apiClient: client),
    );
    general = GeneralConfigController(
      generalApi: GeneralApi(apiClient: client),
    );
    auth = AuthController(
      authApi: api,
      cashRegisterController: cash,
      generalConfigController: general,
      authStorage: storage,
      apiClient: client,
      navigationService: navigation,
      titleBarController: title,
      appPreferences: preferences,
    );
  });

  tearDown(() async {
    await auth.logout();
    auth.dispose();
    cash.dispose();
    general.dispose();
    title.dispose();
    preferences.dispose();
  });

  test('restoring a valid session opens home without refreshing', () async {
    final session = api.session;
    await storage.saveSession(session);

    final response = await auth.restoreSession();

    expect(response.success, isTrue);
    expect(auth.session, session);
    expect(api.refreshCalls, 0);
    expect(general.generalConfigEntity, isNotNull);
    expect(navigation.destinations.single, isA<HomeAdminView>());
    expect(auth.isLoading, isFalse);
  });

  for (final expiry in [
    (label: 'expired', remaining: const Duration(hours: -1)),
    (label: 'expiring soon', remaining: const Duration(minutes: 2)),
  ]) {
    test(
      'restoring an ${expiry.label} session refreshes and opens home',
      () async {
        await storage.saveSession(_storedSession(expiry.remaining));

        final response = await auth.restoreSession();

        expect(response.success, isTrue);
        expect(api.refreshCalls, 1);
        expect(auth.accessToken, 'access-1');
        expect(storage.readSession(), auth.session);
        expect(title.title, 'Administrador');
        expect(general.generalConfigEntity, isNotNull);
        expect(navigation.destinations.single, isA<HomeAdminView>());
        expect(auth.initialized, isTrue);
        expect(auth.isLoading, isFalse);
      },
    );
  }

  test('restoration stays loading while the refresh is pending', () async {
    await storage.saveSession(_storedSession(const Duration(hours: -1)));
    final pending = Completer<AuthSession>();
    api.onRefresh = () => pending.future;

    final restoration = auth.restoreSession();
    final loadingDuringRefresh = auth.isLoading;
    expect(navigation.destinations, isEmpty);
    pending.complete(api.session);
    await restoration;

    expect(loadingDuringRefresh, isTrue);
    expect(auth.isLoading, isFalse);
    expect(navigation.destinations.single, isA<HomeAdminView>());
  });

  test('a rejected refresh clears the session and opens sign in', () async {
    await storage.saveSession(_storedSession(const Duration(hours: -1)));
    api.onRefresh = () async {
      throw AppException(message: 'Sesion vencida');
    };

    final response = await auth.restoreSession();

    expect(response.success, isFalse);
    expect(response.message, 'Sesion vencida');
    expect(auth.isAuthenticated, isFalse);
    expect(storage.readSession(), isNull);
    expect(title.title, isEmpty);
    expect(general.generalConfigEntity, isNull);
    expect(navigation.destinations.single, isA<SignInView>());
    expect(auth.isLoading, isFalse);
  });

  test('refreshing an active session keeps the current page', () async {
    await auth.signIn('admin', 'password');

    final response = await auth.refreshSession();

    expect(response.success, isTrue);
    expect(auth.accessToken, 'access-1');
    expect(navigation.destinations, isEmpty);
  });
}

AuthSession _storedSession(Duration remaining) => AuthSession(
  accessToken: 'stored-access',
  refreshToken: 'stored-refresh',
  uid: 'admin',
  username: 'admin',
  displayName: 'Administrador',
  role: AppRole.admin,
  expiresAt: DateTime.now().add(remaining),
);

class _AuthApi extends AuthApi {
  _AuthApi(AdminFixtureClient client) : super(apiClient: client);

  int refreshCalls = 0;
  Future<AuthSession> Function()? onRefresh;

  AuthSession get session => AuthSession(
    accessToken: 'access-$refreshCalls',
    refreshToken: 'refresh-$refreshCalls',
    uid: 'admin',
    username: 'admin',
    displayName: 'Administrador',
    role: AppRole.admin,
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  @override
  Future<AuthSession> signIn({
    required String username,
    required String password,
  }) async => session;

  @override
  Future<AuthSession> refreshToken({
    required String refreshToken,
    String? previousRefreshToken,
  }) async {
    refreshCalls++;
    return onRefresh?.call() ?? session;
  }
}

class _Navigation extends NavigationService {
  final destinations = <Widget>[];

  @override
  void pushAndRemoveUntil(Widget route) => destinations.add(route);
}
