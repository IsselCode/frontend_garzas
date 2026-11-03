import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/commons/app_top_bar.dart';
import 'package:frontend_garzas/commons/app_window_layout.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/commons/dialogs/exit_to_app_dialog.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/core/services/app_preferences.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/users_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/credits_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/flow_meter_controller.dart';
import 'package:frontend_garzas/src/admin/data/flow_meter_api.dart';
import 'package:frontend_garzas/src/admin/views/liters_statistics_view.dart';
import 'package:frontend_garzas/src/admin/views/sales_reports_view.dart';
import 'package:frontend_garzas/src/admin/clean/enums/credit_status.dart';
import 'package:frontend_garzas/src/admin/views/credits_view.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/admin/data/users_api.dart';
import 'package:frontend_garzas/src/admin/views/user_management_view.dart';
import 'package:frontend_garzas/src/admin/widgets/users/user_form_dialog.dart';
import 'package:frontend_garzas/commons/widgets/pagination_footer.dart';
import 'package:frontend_garzas/src/admin/data/general_api.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/admin/data/logs_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/admin/navigation/admin_navigation.dart';
import 'package:frontend_garzas/src/admin/views/home_admin_view.dart';
import 'package:frontend_garzas/src/admin/views/logs_view.dart';
import 'package:frontend_garzas/src/admin/views/business_settings_view.dart';
import 'package:frontend_garzas/src/admin/views/system_settings_view.dart';
import 'package:frontend_garzas/src/admin/widgets/settings/business_ticket_settings.dart';
import 'package:frontend_garzas/src/admin/widgets/settings/business_general_settings.dart';
import 'package:frontend_garzas/src/admin/widgets/settings/business_prices_settings.dart';
import 'package:frontend_garzas/src/admin/widgets/settings/business_plc_settings.dart';
import 'package:frontend_garzas/src/admin/widgets/monthly_sales_summary.dart';
import 'package:frontend_garzas/src/admin/widgets/admin_date_range_fields.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/users_fixture_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late NavigationService navigation;
  late UsersFixtureClient client;
  late StatisticsController statistics;
  late TitleBarController title;
  late AppPreferences preferences;
  late _Auth auth;
  late CashRegisterController cash;
  late GeneralConfigController general;
  late UsersController users;
  late CreditsController credits;
  late FlowMeterController flow;
  var maximizedReads = 0;

  setUpAll(() async {
    final fonts = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-400.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-500.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-700.ttf'));
    await fonts.load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = AppPreferences(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    client = UsersFixtureClient();
    users = UsersController(usersApi: UsersApi(apiClient: client));
    credits = CreditsController(salesApi: SalesApi(apiClient: client));
    flow = FlowMeterController(flowMeterApi: FlowMeterApi(apiClient: client));
    statistics = StatisticsController(
      logsApi: LogsApi(apiClient: client),
      salesApi: SalesApi(apiClient: client),
    );
    cash = CashRegisterController(
      cashRegisterApi: CashRegisterApi(apiClient: client),
    );
    general = GeneralConfigController(
      generalApi: GeneralApi(apiClient: client),
    );
    title = TitleBarController(appPreferences: preferences);
    auth = _Auth(preferences);
    navigation = NavigationService(
      routes: {
        ...adminRoutes,
        _Detail: const AppRouteInfo(
          sectionId: 'logs',
          title: 'Detalle del registro',
        ),
      },
    );
    locator.registerSingleton<NavigationService>(navigation);
    locator.registerSingleton<ToastService>(_Toast());
    locator.registerSingleton<PendingDispatchesApi>(
      PendingDispatchesApi(apiClient: client),
    );
    maximizedReads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (
          call,
        ) async {
          if (call.method == 'isMaximized') {
            maximizedReads++;
            return false;
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('net.nfet.printing'),
          (_) async => {'canRaster': false},
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('snap_layouts'),
          (_) async => null,
        );
  });

  tearDown(() {
    locator.unregister<NavigationService>();
    locator.unregister<ToastService>();
    locator.unregister<PendingDispatchesApi>();
    statistics.dispose();
    cash.dispose();
    general.dispose();
    users.dispose();
    credits.dispose();
    flow.dispose();
    title.dispose();
    preferences.dispose();
    auth.dispose();
  });

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(1280, 720),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppPreferences>.value(value: preferences),
          ChangeNotifierProvider<GeneralConfigController>.value(value: general),
          ChangeNotifierProvider<UsersController>.value(value: users),
          ChangeNotifierProvider<CreditsController>.value(value: credits),
          ChangeNotifierProvider<FlowMeterController>.value(value: flow),
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<TitleBarController>.value(value: title),
          ChangeNotifierProvider<CashRegisterController>.value(value: cash),
          ChangeNotifierProvider<StatisticsController>.value(value: statistics),
        ],
        child: Consumer<TitleBarController>(
          builder: (_, value, child) => GlobalLoaderOverlay(
            child: MaterialApp(
              theme: value.currentTheme,
              navigatorKey: navigation.navigatorKey,
              navigatorObservers: [navigation.observer],
              locale: const Locale('es', 'MX'),
              supportedLocales: const [Locale('es', 'MX')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              builder: (_, child) => AppWindowLayout(child: child!),
              home: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    navigation.pushAndRemoveUntil(const HomeAdminView());
    await tester.pumpAndSettle();
  }

  testWidgets(
    'admin home loads liters and horizontal summaries without fetching logs',
    (tester) async {
      await mount(tester);
      expect(find.byTooltip('Abrir o cerrar menú'), findsNothing);
      final sidebar = find.byType(IsselNavigationPane);
      expect(
        find.image(const AssetImage(AppAssets.drawerIcon)),
        findsOneWidget,
      );
      final sectionButtons = find.descendant(
        of: sidebar,
        matching: find.byType(TextButton),
      );
      expect(sectionButtons, findsNWidgets(adminDestinations.length));
      for (final button in sectionButtons.evaluate()) {
        expect(
          tester.getSize(find.byWidget(button.widget)),
          const Size(220, 40),
        );
      }
      expect(
        tester.getSize(
          find.descendant(of: sidebar, matching: find.byType(FilledButton)),
        ),
        const Size(220, 40),
      );
      expect(find.text('Ventas'), findsNothing);
      expect(find.byType(MonthlySalesSummary), findsOneWidget);
      expect(
        tester
            .widget<MonthlySalesSummary>(find.byType(MonthlySalesSummary))
            .horizontal,
        isTrue,
      );
      expect(find.byType(LitersStatisticsView), findsOneWidget);
      expect(
        client.requests,
        containsAll([
          '/flow-meter/daily/range',
          '/sales/monthly-payment-totals',
          '/sales/monthly-garza-totals',
        ]),
      );
      expect(client.requests, isNot(contains('/logs')));
      expect(client.requests, isNot(contains('/sales')));
      expect(
        tester
            .widget<IsselNavigationPane>(find.byType(IsselNavigationPane))
            .selectedId,
        'home',
      );
      expect(find.text('¿Qué quieres hacer hoy?'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'menu opens Logs directly and route selection survives dialogs and back',
    (tester) async {
      await mount(tester);
      final salesRequests = client.requests
          .where((path) => path == '/sales')
          .length;
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();
      expect(find.byType(LogsView), findsOneWidget);
      expect(find.byType(MonthlySalesSummary), findsNothing);
      expect(find.text('Acceso al sistema'), findsOneWidget);
      expect(
        client.requests.where((path) => path == '/sales').length,
        salesRequests,
      );
      expect(navigation.state.value.current?.sectionId, 'logs');

      showDialog<void>(
        context: navigation.navigatorKey.currentContext!,
        builder: (_) => const AlertDialog(content: Text('Prueba de diálogo')),
      );
      await tester.pumpAndSettle();
      expect(navigation.state.value.current?.sectionId, 'logs');
      expect(navigation.state.value.hasModal, isTrue);
      expect(
        tester.widget<AppTopBar>(find.byType(AppTopBar)).actionsEnabled,
        isFalse,
      );
      navigation.goBack();
      await tester.pumpAndSettle();
      expect(navigation.state.value.hasModal, isFalse);

      navigation.navigateTo(const _Detail());
      await tester.pumpAndSettle();
      expect(navigation.state.value.canGoBack, isTrue);
      expect(navigation.state.value.current?.title, 'Detalle del registro');
      navigation.goBack();
      await tester.pumpAndSettle();
      expect(navigation.state.value.current?.title, 'Logs');
      expect(
        tester
            .widget<IsselNavigationPane>(find.byType(IsselNavigationPane))
            .selectedId,
        'logs',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'sales and logs filter through separate inline date fields and the existing APIs',
    (tester) async {
      client.pageCounts.addAll({
        '/sales': 45,
        '/sales/range': 45,
        '/logs': 105,
        '/logs/range': 105,
      });
      await mount(tester);
      for (final path in ['/sales/range', '/logs/range']) {
        if (path == '/sales/range') {
          await tester.tap(find.text('Reportes'));
          await tester.pumpAndSettle();
          expect(find.byType(SalesReportsView), findsOneWidget);
        }
        if (path == '/logs/range') {
          await tester.tap(find.text('Logs'));
          await tester.pumpAndSettle();
        }
        expect(find.byType(AdminDateRangeFields), findsOneWidget);
        expect(find.text('Todas las fechas'), findsNWidgets(2));
        await tester.tap(
          find.descendant(
            of: find.byType(PaginationFooter),
            matching: find.text('2'),
          ),
        );
        await tester.pumpAndSettle();
        for (var index = 0; index < 2; index++) {
          final field = find.byType(AdminDateFilterField).at(index);
          await tester.tap(field);
          await tester.pumpAndSettle();
          tester
              .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
              .onDateChanged(DateTime(2026, 11, index == 0 ? 2 : 4));
          await tester.pump();
          await tester.tap(find.text('Seleccionar'));
          await tester.pumpAndSettle();
        }
        expect(
          client.queries[path]?['start_at'],
          startsWith('2026-11-02T00:00:00'),
        );
        expect(
          client.queries[path]?['end_at'],
          startsWith('2026-11-05T00:00:00'),
        );
        expect(find.text('02/11/2026'), findsOneWidget);
        expect(find.text('04/11/2026'), findsOneWidget);
        expect(
          tester
              .widget<PaginationFooter>(find.byType(PaginationFooter))
              .data
              .page,
          1,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(PaginationFooter),
            matching: find.text('2'),
          ),
        );
        await tester.pumpAndSettle();
        expect(client.queries[path]?['page'], 2);
        expect(
          client.queries[path]?['start_at'],
          startsWith('2026-11-02T00:00:00'),
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'switching sections is immediate and never accumulates previous pages',
    (tester) async {
      await mount(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Logs'));
        await tester.pump();
        await tester.pump();
        expect(find.byType(HomeAdminView, skipOffstage: false), findsNothing);
        expect(navigation.state.value.pages, hasLength(1));
        expect(navigation.state.value.canGoBack, isFalse);
        final route =
            ModalRoute.of(tester.element(find.byType(LogsView)))! as PageRoute;
        expect(route.transitionDuration, Duration.zero);
        expect(route.reverseTransitionDuration, Duration.zero);
        await tester.tap(find.text('Inicio').first);
        await tester.pumpAndSettle();
        expect(find.byType(LogsView, skipOffstage: false), findsNothing);
        expect(navigation.state.value.pages, hasLength(1));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('business log settings retain the existing update contract', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Config. del negocio'));
    await tester.pumpAndSettle();
    expect(find.byType(BusinessSettingsView), findsOneWidget);
    expect(find.byType(BusinessGeneralSettings), findsOneWidget);
    expect(find.byType(BusinessPricesSettings), findsOneWidget);
    expect(find.byType(BusinessPlcSettings), findsOneWidget);
    expect(find.byType(BusinessTicketPreview), findsNothing);
    final tabs = tester.widget<IsselFilterBar<BusinessSettingsSection>>(
      find.byType(IsselFilterBar<BusinessSettingsSection>),
    );
    expect(tabs.options.map((option) => option.label), ['General', 'Ticket']);
    expect(find.byType(IsselToggleField), findsNWidgets(14));
    expect(
      tester.getRect(find.text('Guardar cambios')).top,
      lessThan(tester.getRect(find.byType(BusinessGeneralSettings)).top),
    );
    expect(navigation.state.value.current?.title, 'Config. del negocio');
    tester
        .widget<IsselToggleField>(find.byType(IsselToggleField).first)
        .onChanged(false);
    await tester.pumpAndSettle();
    expect(client.configUpdates.single['water_supply'], isFalse);
    expect(
      client.configUpdates.single['business_name'],
      'Purificadora de prueba',
    );
    expect(general.generalConfigEntity?.waterSupply, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('one save validates PLC and sends all prices and PLC together', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Config. del negocio'));
    await tester.pumpAndSettle();
    expect(find.text('Guardar precios'), findsNothing);
    expect(find.text('Guardar PLC'), findsNothing);
    expect(find.text('Guardar cambios'), findsOneWidget);
    tester
        .widget<IsselStepperField>(find.byType(IsselStepperField).at(0))
        .onChanged(.75);
    tester
        .widget<IsselStepperField>(find.byType(IsselStepperField).at(1))
        .onChanged(2.5);
    await tester.enterText(find.byType(IsselTextFormField), 'sin-puerto');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa una IP y puerto válidos'), findsOneWidget);
    expect(client.configUpdates, isEmpty);
    await tester.enterText(find.byType(IsselTextFormField), '10.0.0.20:502');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    expect(client.configUpdates.single['potable_liter_pricing'], .75);
    expect(client.configUpdates.single['potable_gal_pricing'], 2.5);
    expect(client.configUpdates.single['pozo_liter_pricing'], .3);
    expect(client.configUpdates.single['pozo_gal_pricing'], 1.2);
    expect(client.configUpdates.single['plc_endpoint'], '10.0.0.20:502');
    expect(
      client.configUpdates.single['business_name'],
      'Purificadora de prueba',
    );
    expect(client.configUpdates.single['print_qnty'], 2);
    expect(
      tester
          .widget<IsselTextFormField>(find.byType(IsselTextFormField))
          .controller
          ?.text,
      '10.0.0.20:502',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    expect(client.configUpdates, hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'failed joint save restores both settings and retains drafts for retry',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Config. del negocio'));
      await tester.pumpAndSettle();
      tester
          .widget<IsselStepperField>(find.byType(IsselStepperField).first)
          .onChanged(.75);
      await tester.enterText(find.byType(IsselTextFormField), '10.0.0.22:502');
      client.failConfigUpdates = true;
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      expect(client.configUpdates, hasLength(1));
      expect(general.generalConfigEntity?.potableLiterPricing, .5);
      expect(general.generalConfigEntity?.plcEndpoint, '192.168.0.20:502');
      expect(
        tester
            .widget<IsselStepperField>(find.byType(IsselStepperField).first)
            .initValue,
        .75,
      );
      expect(
        tester
            .widget<IsselTextFormField>(find.byType(IsselTextFormField))
            .controller
            ?.text,
        '10.0.0.22:502',
      );
      client.failConfigUpdates = false;
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      expect(client.configUpdates, hasLength(2));
      expect(general.generalConfigEntity?.potableLiterPricing, .75);
      expect(general.generalConfigEntity?.plcEndpoint, '10.0.0.22:502');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('ticket retains its preview, drafts and independent save', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Config. del negocio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ticket'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.byType(BusinessTicketPreview), findsOneWidget);
    expect(find.text('Vista previa del ticket'), findsNothing);
    expect(
      tester.getRect(find.text('Guardar ticket')).top,
      lessThan(tester.getRect(find.byType(BusinessTicketPreview)).top),
    );
    await tester.enterText(
      find.byType(IsselTextFormField).first,
      'Nuevo negocio',
    );
    await tester.pump();
    expect(
      tester
          .widget<BusinessTicketPreview>(find.byType(BusinessTicketPreview))
          .config
          .businessName,
      'Nuevo negocio',
    );
    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ticket'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(
      tester
          .widget<IsselTextFormField>(find.byType(IsselTextFormField).first)
          .controller
          ?.text,
      'Nuevo negocio',
    );
    await tester.tap(find.text('Guardar ticket'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(client.configUpdates.single['business_name'], 'Nuevo negocio');
    expect(client.configUpdates.single['print_qnty'], 2);
    expect(client.configUpdates.single['plc_endpoint'], '192.168.0.20:502');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'system settings use local preferences and share the caption theme',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Config. del sistema'));
      await tester.pumpAndSettle();
      expect(find.byType(SystemSettingsView), findsOneWidget);
      expect(client.requests, isNot(contains('/settings/general')));
      final windowSetting = find.byWidgetPredicate(
        (widget) =>
            widget is IsselToggleField && widget.title == 'Iniciar maximizada',
      );
      await tester.tap(
        find.descendant(of: windowSetting, matching: find.byType(IsselToggle)),
      );
      await tester.pumpAndSettle();
      expect(preferences.startMaximized, isTrue);
      final rememberSetting = find.byWidgetPredicate(
        (widget) =>
            widget is IsselToggleField && widget.title == 'Recordar sesión',
      );
      await tester.tap(
        find.descendant(
          of: rememberSetting,
          matching: find.byType(IsselToggle),
        ),
      );
      await tester.pumpAndSettle();
      expect(preferences.rememberSession, isFalse);
      await tester.ensureVisible(find.text('Oscuro'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      expect(title.isDarkMode, isTrue);
      expect(preferences.darkMode, isTrue);
      await tester.tap(find.byTooltip('Usar tema claro'));
      await tester.pumpAndSettle();
      expect(preferences.darkMode, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('both logout controls honor the confirmation preference', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(ExitToAppDialog), findsOneWidget);
    expect(auth.logoutCalls, 0);
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    await preferences.setConfirmBeforeLogout(false);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(ExitToAppDialog), findsNothing);
    expect(auth.logoutCalls, 1);
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(auth.logoutCalls, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'theme and menu controls work without repeated native maximize queries',
    (tester) async {
      await mount(tester);
      final reads = maximizedReads;
      final themeButton = tester.widget<IsselCaptionButton>(
        find.ancestor(
          of: find.byTooltip('Usar tema oscuro'),
          matching: find.byType(IsselCaptionButton),
        ),
      );
      expect(themeButton.size, 32);
      expect(themeButton.iconSize, 22);
      await tester.tap(find.byTooltip('Usar tema oscuro'));
      await tester.pumpAndSettle();
      expect(title.isDarkMode, isTrue);
      expect(maximizedReads, reads);
      await tester.tap(find.byTooltip('Ocultar menú'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IsselDesktopScaffold>(find.byType(IsselDesktopScaffold))
            .sidebarOpen,
        isFalse,
      );
      await tester.tap(find.byTooltip('Abrir o cerrar menú'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Abrir o cerrar menú'), findsNothing);
      expect(
        tester
            .widget<IsselDesktopScaffold>(find.byType(IsselDesktopScaffold))
            .sidebarOpen,
        isTrue,
      );
      expect(maximizedReads, reads);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'sidebar is hidden for other roles and actions follow existing permissions',
    (tester) async {
      await mount(tester);
      for (final role in [
        AppRole.dispatch,
        AppRole.seller,
        AppRole.salesDispatch,
      ]) {
        auth.setRole(role);
        cash.openCash = true;
        await tester.pumpAndSettle();
        expect(find.byType(IsselNavigationPane), findsNothing);
        expect(
          find.byTooltip('Configurar impresora'),
          role == AppRole.dispatch ? findsNothing : findsOneWidget,
        );
        expect(
          find.byTooltip('Registrar pago de crédito'),
          role.canSell ? findsOneWidget : findsNothing,
        );
        expect(
          find.byTooltip('Cerrar corte de caja'),
          role.canSell ? findsOneWidget : findsNothing,
        );
      }
      auth.setRole(null);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Cerrar sesión'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('general business settings stack and scroll in narrow windows', (
    tester,
  ) async {
    await mount(tester, size: const Size(600, 720));
    await tester.tap(find.byTooltip('Ocultar menú'));
    await tester.pumpAndSettle();
    navigation.pushAndRemoveUntil(const BusinessSettingsView());
    await tester.pumpAndSettle();
    expect(find.byType(BusinessGeneralSettings), findsOneWidget);
    expect(find.byType(IsselToggleField), findsNWidgets(14));
    expect(find.byType(IsselStepperField), findsNWidgets(4));
    expect(
      find.descendant(
        of: find.byType(BusinessGeneralSettings),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNWidgets(2),
    );
    await tester.ensureVisible(find.byType(BusinessPlcSettings));
    await tester.enterText(find.byType(IsselTextFormField), '10.0.0.21:502');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    expect(client.configUpdates.single['plc_endpoint'], '10.0.0.21:502');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'users paginate and combine filters without changing global totals',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Usuarios'));
      await tester.pumpAndSettle();
      expect(find.byType(UserManagementView), findsOneWidget);
      expect(find.text('Mostrando 1 a 20 de 45 usuarios'), findsOneWidget);
      expect(users.userStatistics?.activeUsers, 30);
      final footer = find.byType(PaginationFooter);
      await tester.tap(find.descendant(of: footer, matching: find.text('2')));
      await tester.pumpAndSettle();
      expect(client.userQueries.last['page'], 2);
      expect(find.text('Mostrando 21 a 40 de 45 usuarios'), findsOneWidget);
      await tester.enterText(find.byType(IsselTextFormField), 'Usuario 2');
      await tester.pump(const Duration(milliseconds: 349));
      expect(client.userQueries.last['page'], 2);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(client.userQueries.last['page'], 1);
      expect(client.userQueries.last['name'], 'Usuario 2');
      tester
          .widget<IsselDropdown<AppRole>>(find.byType(IsselDropdown<AppRole>))
          .onChanged!(AppRole.seller);
      tester
          .widget<IsselDropdown<bool>>(find.byType(IsselDropdown<bool>))
          .onChanged!(true);
      await tester.pumpAndSettle();
      expect(client.userQueries.last, containsPair('role', 'seller'));
      expect(client.userQueries.last, containsPair('is_active', true));
      expect(
        users.paging.items.every((u) => u.role == AppRole.seller && u.isActive),
        isTrue,
      );
      expect(users.userStatistics?.activeUsers, 30);
      expect(client.statisticsRequests, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'user form validates, retains failed edits and refreshes statistics',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Usuarios'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nuevo usuario'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Ingresa entre 3 y 50 caracteres'), findsOneWidget);
      expect(client.users, hasLength(45));
      final fields = find.descendant(
        of: find.byType(UserFormDialog),
        matching: find.byType(IsselTextFormField),
      );
      await tester.enterText(fields.at(0), 'operador_nuevo');
      await tester.enterText(fields.at(1), 'Operador nuevo');
      await tester.enterText(fields.at(2), 'secreto123');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.byType(UserFormDialog), findsNothing);
      expect(client.users, hasLength(46));
      expect(client.statisticsRequests, 2);
      expect(users.userStatistics?.activeUsers, 31);
      await tester.tap(find.text('Editar usuario'));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(1), 'Administrador de prueba');
      client.rejectUserUpdates = true;
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.byType(UserFormDialog), findsOneWidget);
      expect(find.text('No se puede modificar este usuario'), findsOneWidget);
      expect(
        tester.widget<IsselTextFormField>(fields.at(1)).controller?.text,
        'Administrador de prueba',
      );
      client.rejectUserUpdates = false;
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.byType(UserFormDialog), findsNothing);
      expect(client.users.first['display_name'], 'Administrador de prueba');
      expect(client.statisticsRequests, 3);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'status and deleting the last user on a page reload valid totals',
    (tester) async {
      client.users.removeRange(21, client.users.length);
      await mount(tester);
      await tester.tap(find.text('Usuarios'));
      await tester.pumpAndSettle();
      final footer = find.byType(PaginationFooter);
      await tester.tap(find.descendant(of: footer, matching: find.text('2')));
      await tester.pumpAndSettle();
      expect(find.text('Mostrando 21 a 21 de 21 usuarios'), findsOneWidget);
      await tester.ensureVisible(find.text('Desactivar usuario'));
      await tester.tap(find.text('Desactivar usuario'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Desactivar'));
      await tester.pumpAndSettle();
      expect(client.users.last['is_active'], false);
      expect(find.text('Activar usuario'), findsOneWidget);
      await tester.ensureVisible(find.text('Eliminar usuario'));
      await tester.tap(find.text('Eliminar usuario'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(client.users, hasLength(20));
      expect(client.userQueries.last['page'], 1);
      expect(find.text('Mostrando 1 a 20 de 20 usuarios'), findsOneWidget);
      expect(client.statisticsRequests, 3);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('users fit a narrow window and open detail in a dialog', (
    tester,
  ) async {
    await mount(tester, size: const Size(600, 720));
    await tester.tap(find.text('Usuarios'));
    await tester.pumpAndSettle();
    if (find.byTooltip('Ocultar menú').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('Ocultar menú'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('usuario00'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Detalle del usuario'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Cerrar detalle'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'an initial list error can retry and display the recovered data',
    (tester) async {
      client.failedListPaths.add('/logs');
      await mount(tester);
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();
      expect(find.text('No se pudo consultar el listado'), findsOneWidget);
      client.failedListPaths.clear();
      await tester.tap(find.byTooltip('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Acceso al sistema'), findsOneWidget);
      expect(find.text('No se pudo consultar el listado'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'credit filters combine, reset pages, validate and restore on failure',
    (tester) async {
      client.pageCounts['/sales/credit/pending'] = 26;
      client.pageCounts['/sales/CR-1/credit-payments'] = 26;
      await mount(tester, size: const Size(1600, 1000));
      await tester.tap(find.text('Créditos'));
      await tester.pumpAndSettle();
      const path = '/sales/credit/pending';
      expect(client.queries[path], containsPair('status', 'pending'));
      tester
          .widget<PaginationFooter>(find.byType(PaginationFooter))
          .onPageChanged(2);
      await tester.pumpAndSettle();
      final search = find.descendant(
        of: find.byType(CreditsView),
        matching: find.byType(IsselTextFormField),
      );
      await tester.enterText(search, ' Rancho   Norte ');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(client.queries[path], containsPair('page', 1));
      expect(client.queries[path], containsPair('search', 'Rancho Norte'));
      tester
          .widget<IsselDropdown<CreditStatus>>(
            find.byType(IsselDropdown<CreditStatus>),
          )
          .onChanged!(CreditStatus.all);
      await tester.pumpAndSettle();
      expect(client.queries[path], containsPair('status', 'all'));
      final dates = find.byType(AdminDateFilterField);
      for (var index = 0; index < 2; index++) {
        await tester.tap(dates.at(index));
        await tester.pumpAndSettle();
        tester
            .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
            .onDateChanged(DateTime(2026, 11, index + 1));
        await tester.pump();
        await tester.tap(find.text('Seleccionar'));
        await tester.pumpAndSettle();
      }
      tester
          .widget<IsselTableWidget>(find.byType(IsselTableWidget).first)
          .onTapRow!(0);
      await tester.pumpAndSettle();
      expect(credits.selectedCredit, isNotNull);
      tester
          .widget<PaginationFooter>(find.byType(PaginationFooter).first)
          .onPageChanged(2);
      await tester.pumpAndSettle();
      expect(client.queries[path], containsPair('status', 'all'));
      expect(client.queries[path], containsPair('search', 'Rancho Norte'));
      expect(
        DateTime.parse(client.queries[path]!['start_at']).toLocal(),
        DateTime(2026, 11, 1),
      );
      expect(
        DateTime.parse(client.queries[path]!['end_at']).toLocal(),
        DateTime(2026, 11, 3),
      );
      final before = client.requests.where((request) => request == path).length;
      await tester.enterText(search, 'x' * 46);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Máximo 45 caracteres'), findsOneWidget);
      expect(
        client.requests.where((request) => request == path).length,
        before,
      );
      await tester.tap(find.byTooltip('Limpiar cliente'));
      await tester.pumpAndSettle();
      expect(client.queries[path], isNot(contains('search')));
      expect(credits.selectedCredit, isNull);
      expect(credits.creditPayments, isEmpty);
      client.failedListPaths.add(path);
      tester
          .widget<IsselDropdown<CreditStatus>>(
            find.byType(IsselDropdown<CreditStatus>),
          )
          .onChanged!(CreditStatus.paid);
      await tester.pumpAndSettle();
      expect(credits.status, CreditStatus.all);
      expect(find.text('No se pudo consultar el listado'), findsOneWidget);
      client.failedListPaths.clear();
      await tester.tap(find.byTooltip('Reintentar'));
      await tester.pumpAndSettle();
      expect(client.queries[path], containsPair('status', 'all'));
      expect(credits.paging.error, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('credit filters and abonos fit a narrow window', (tester) async {
    client.pageCounts['/sales/credit/pending'] = 26;
    client.pageCounts['/sales/CR-1/credit-payments'] = 26;
    await mount(tester, size: const Size(600, 760));
    await tester.tap(find.text('Créditos'));
    await tester.pumpAndSettle();
    tester
        .widget<IsselTableWidget>(find.byType(IsselTableWidget).first)
        .onTapRow!(0);
    await tester.pumpAndSettle();
    expect(find.text('Pago del crédito'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Cerrar detalle'));
    await tester.tap(find.byTooltip('Cerrar detalle'));
    await tester.pumpAndSettle();
    expect(credits.selectedCredit, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'credit detail is a single payment and cut sales retain pagination',
    (tester) async {
      client.pageCounts.addAll({
        '/sales/credit/pending': 26,
        '/sales/CR-1/credit-payments': 26,
        '/cash-register': 26,
        '/cash-register/1/sales': 26,
      });
      await mount(tester, size: const Size(1600, 1000));
      await tester.tap(find.text('Créditos'));
      await tester.pumpAndSettle();
      tester
          .widget<IsselTableWidget>(find.byType(IsselTableWidget).first)
          .onTapRow!(0);
      await tester.pumpAndSettle();
      expect(find.byType(PaginationFooter), findsOneWidget);
      expect(find.byType(IsselTableWidget), findsOneWidget);
      expect(find.text('Cantidad pagada'), findsOneWidget);
      expect(credits.paymentsPaging.data.page, 1);
      expect(credits.paging.data.page, 1);
      tester
          .widget<PaginationFooter>(find.byType(PaginationFooter).first)
          .onPageChanged(2);
      await tester.pumpAndSettle();
      expect(credits.paging.data.page, 2);
      expect(credits.paymentsPaging.data.page, 1);
      await tester.tap(find.text('Cortes de caja'));
      await tester.pumpAndSettle();
      tester
          .widget<IsselTableWidget>(find.byType(IsselTableWidget).first)
          .onTapRow!(0);
      await tester.pumpAndSettle();
      expect(find.byType(PaginationFooter), findsNWidgets(2));
      tester
          .widget<PaginationFooter>(find.byType(PaginationFooter).last)
          .onPageChanged(2);
      await tester.pumpAndSettle();
      expect(cash.salesPaging.data.page, 2);
      expect(cash.salesPaging.items, hasLength(6));
      expect(cash.paging.data.page, 1);
      expect(cash.selectedCut?.cashTotal, 1300.0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'the existing pending payments list sends status and date filters on every page',
    (tester) async {
      client.pageCounts['/pending-dispatches'] = 26;
      await mount(tester);
      await tester.tap(find.text('Pagos pendientes'));
      await tester.pumpAndSettle();
      final fields = find.byType(AdminDateFilterField);
      for (var index = 0; index < 2; index++) {
        await tester.tap(fields.at(index));
        await tester.pumpAndSettle();
        tester
            .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
            .onDateChanged(DateTime(2026, 11, index + 1));
        await tester.pump();
        await tester.tap(find.text('Seleccionar'));
        await tester.pumpAndSettle();
      }
      tester
          .widget<PaginationFooter>(find.byType(PaginationFooter))
          .onPageChanged(2);
      await tester.pumpAndSettle();
      expect(client.queries['/pending-dispatches'], containsPair('page', 2));
      expect(
        client.queries['/pending-dispatches'],
        containsPair('status', 'pending_payment'),
      );
      expect(
        client.queries['/pending-dispatches']?['start_at'],
        startsWith('2026-11-01T00:00:00'),
      );
      expect(
        client.queries['/pending-dispatches']?['end_at'],
        startsWith('2026-11-03T00:00:00'),
      );
      expect(find.text('Mostrando 21 a 26 de 26 registros'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('narrow windows overlay the menu without squeezing the tables', (
    tester,
  ) async {
    await mount(tester, size: const Size(600, 720));
    expect(find.byType(HomeAdminView), findsOneWidget);
    await tester.tap(find.byTooltip('Ocultar menú'));
    await tester.pumpAndSettle();
    expect(find.text('Ventas'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Auth extends ChangeNotifier implements AuthController {
  _Auth(this.appPreferences);
  @override
  final AppPreferences appPreferences;
  int logoutCalls = 0;
  @override
  Future<bool> setRememberSession(bool value) =>
      appPreferences.setRememberSession(value);
  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  AppRole? _role = AppRole.admin;
  @override
  AppRole? get role => _role;
  void setRole(AppRole? role) {
    _role = role;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Detail extends StatelessWidget {
  const _Detail();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Detalle'));
}

class _Toast extends ToastService {
  @override
  void success(String text) {}
  @override
  void error(String text) {}
}
