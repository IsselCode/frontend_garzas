import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/services/app_preferences.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/admin/data/general_api.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/data/auth_api.dart';
import 'package:frontend_garzas/src/auth/data/auth_storage.dart';
import 'package:frontend_garzas/src/auth/models/auth_session.dart';

import '../support/admin_fixture_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences storage;
  late AppPreferences preferences;
  late AuthStorage authStorage;
  late TitleBarController title;
  late AuthController auth;
  late CashRegisterController cash;
  late GeneralConfigController general;
  late _AuthApi api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await SharedPreferences.getInstance();
    preferences = AppPreferences(sharedPreferences: storage);
    authStorage = AuthStorage(sharedPreferences: storage);
    title = TitleBarController(appPreferences: preferences);
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
      authStorage: authStorage,
      apiClient: client,
      navigationService: NavigationService(),
      titleBarController: title,
      appPreferences: preferences,
    );
  });

  tearDown(() async {
    await auth.logout();
    auth.dispose();
    general.dispose();
    cash.dispose();
    title.dispose();
    preferences.dispose();
  });

  test(
    'defaults preserve existing session, confirmation, window and theme behavior',
    () {
      expect(preferences.rememberSession, isTrue);
      expect(preferences.confirmBeforeLogout, isTrue);
      expect(preferences.startMaximized, isFalse);
      expect(title.isDarkMode, isFalse);
    },
  );

  test(
    'theme, window and confirmation preferences survive recreation',
    () async {
      await title.setDarkMode(true);
      await preferences.setStartMaximized(true);
      await preferences.setConfirmBeforeLogout(false);
      await storage.reload();
      final restoredPreferences = AppPreferences(sharedPreferences: storage);
      final restoredTitle = TitleBarController(
        appPreferences: restoredPreferences,
      );
      expect(restoredTitle.isDarkMode, isTrue);
      expect(restoredPreferences.startMaximized, isTrue);
      expect(restoredPreferences.confirmBeforeLogout, isFalse);
      restoredTitle.dispose();
      restoredPreferences.dispose();
    },
  );

  test(
    'disabling remember session clears stored tokens and keeps the active session',
    () async {
      expect((await auth.signIn('admin', 'password')).success, isTrue);
      expect(authStorage.readSession(), isNotNull);
      expect(await auth.setRememberSession(false), isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(authStorage.readSession(), isNull);
      expect((await auth.refreshSession()).success, isTrue);
      expect(authStorage.readSession(), isNull);
      expect(await auth.setRememberSession(true), isTrue);
      expect(authStorage.readSession()?.accessToken, auth.accessToken);
    },
  );

  test(
    'signing in without remembering never persists tokens, including on refresh',
    () async {
      await preferences.setRememberSession(false);
      await authStorage.saveSession(api.session);
      expect((await auth.signIn('admin', 'password')).success, isTrue);
      expect(authStorage.readSession(), isNull);
      expect((await auth.refreshSession()).success, isTrue);
      expect(authStorage.readSession(), isNull);
      expect(auth.isAuthenticated, isTrue);
    },
  );

  test(
    'startup ignores and removes stored tokens when remembering is disabled',
    () async {
      await authStorage.saveSession(api.session);
      await preferences.setRememberSession(false);
      expect((await auth.restoreSession()).success, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(authStorage.readSession(), isNull);
      expect(api.refreshCalls, 0);
    },
  );
}

class _AuthApi extends AuthApi {
  _AuthApi(AdminFixtureClient client) : super(apiClient: client);
  int refreshCalls = 0;
  AuthSession get session => AuthSession(
    accessToken: 'test-access-$refreshCalls',
    refreshToken: 'test-refresh',
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
    return session;
  }
}
