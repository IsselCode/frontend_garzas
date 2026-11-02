import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/data/dispatch_sessions_api.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';
import 'package:frontend_garzas/src/dispatch/views/dispatch_session_view.dart';
import 'package:frontend_garzas/src/dispatch/views/home_dispatch_view.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

void main() {
  late DispatchController controller;
  late _SessionApi api;

  setUp(() {
    final client = ApiClient(serverStatusController: ServerStatusController());
    api = _SessionApi(client);
    controller = DispatchController(
      salesApi: SalesApi(apiClient: client),
      garzasApi: GarzasApi(apiClient: client),
      dispatchSessionsApi: api,
      pendingDispatchesApi: PendingDispatchesApi(apiClient: client),
    )..syncRuntimeStream(shouldRun: true);
  });

  tearDown(() async {
    controller.dispose();
    await api.snapshots.close();
  });

  Future<void> emit(List<GarzaRuntimeEntity> garzas) async {
    api.snapshots.add(
      GarzaRuntimeResponseEntity(
        garzas: garzas,
        updatedAt: null,
        message: null,
      ),
    );
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'keeps an unselected garza visible when release clears its data',
    () async {
      final response = Completer<DispatchSessionEntity>();
      api.load = (_) => response.future;
      await emit([_runtime(1, sessionId: 11)]);
      await emit([_runtime(1)]);

      final last = controller.lastDispatchesForPanel.single;
      expect(last.session.id, 11);
      expect(last.session.state, DispatchState.completed);
      expect(last.session.authorizedVolume, 100);
      expect(last.session.dispensedVolume, 90);
      expect(last.dispatchElapsedMs, 120000);
      expect(controller.runtimePanelGarzasCount, 1);
      expect(controller.activeSession, isNull);

      response.complete(_session(1, 11, elapsedMs: 123456, volume: 100));
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.lastDispatchesForPanel.single.dispatchElapsedMs,
        123456,
      );
      expect(
        controller.lastDispatchesForPanel.single.session.dispensedVolume,
        100,
      );

      await emit([_runtime(1)]);
      expect(api.requestedIds, [11]);
      controller.selectLastDispatch(controller.lastDispatchesForPanel.single);
      expect(controller.dispatchElapsed.inMilliseconds, 123456);
      expect(
        controller.shouldRunDispatchTimer(controller.activeSession!),
        isFalse,
      );
    },
  );

  test(
    'remembers simultaneous releases without changing another selection',
    () async {
      api.load = (id) async => _session(id == 11 ? 1 : 2, id);
      final selected = _session(
        3,
        33,
      ).copyWith(state: DispatchState.dispensing);
      controller.activeSession = selected;
      final third = _runtime(3, sessionId: 33);
      await emit([
        _runtime(1, sessionId: 11),
        _runtime(2, sessionId: 22),
        third,
      ]);
      await emit([_runtime(1), _runtime(2), third]);

      expect(controller.lastDispatchesForPanel.map((last) => last.session.id), [
        11,
        22,
      ]);
      expect(controller.runtimePanelGarzasCount, 3);
      expect(controller.activeSession?.id, 33);
      expect(controller.activeSession?.state, DispatchState.dispensing);
      expect(api.requestedIds, containsAll([11, 22]));
    },
  );

  test('does not restore an old dispatch after a newer one starts', () async {
    final oldResponse = Completer<DispatchSessionEntity>();
    api.load = (id) =>
        id == 11 ? oldResponse.future : Future.value(_session(1, id));
    await emit([_runtime(1, sessionId: 11)]);
    await emit([_runtime(1)]);
    await emit([_runtime(1, sessionId: 12)]);
    expect(controller.lastDispatchesForPanel, isEmpty);

    await emit([_runtime(1)]);
    expect(controller.lastDispatchesForPanel.single.session.id, 12);
    oldResponse.complete(_session(1, 11));
    await Future<void>.delayed(Duration.zero);
    expect(controller.lastDispatchesForPanel.single.session.id, 12);
  });

  test(
    'keeps the last reading on a query error and retries on the next event',
    () async {
      api.load = (_) async => throw AppException(message: 'Sin conexión');
      await emit([_runtime(1, sessionId: 11)]);
      await emit([_runtime(1)]);
      expect(
        controller.lastDispatchesForPanel.single.dispatchElapsedMs,
        120000,
      );

      api.load = (id) async => _session(1, id, elapsedMs: 123456);
      await emit([_runtime(1)]);
      expect(
        controller.lastDispatchesForPanel.single.dispatchElapsedMs,
        123456,
      );
      expect(api.requestedIds, [11, 11]);
    },
  );

  test(
    'uses the final time instead of the selected session initial time',
    () async {
      api.load = (id) async => _session(1, id, elapsedMs: 123456);
      controller.activeSession = _session(
        1,
        11,
        elapsedMs: 1000,
      ).copyWith(state: DispatchState.dispensing);
      await emit([_runtime(1, sessionId: 11)]);
      await emit([_runtime(1)]);

      expect(controller.activeSession?.state, DispatchState.completed);
      expect(controller.activeSession?.dispensedVolume, 100);
      expect(controller.dispatchElapsed.inMilliseconds, 123456);
      expect(
        controller.lastDispatchesForPanel.single.dispatchElapsedMs,
        123456,
      );
    },
  );

  test(
    'retains interrupted state and final runtime metrics while the API catches up',
    () async {
      api.load = (id) async =>
          _session(1, id).copyWith(state: DispatchState.dispensing);
      await emit([_runtime(1, sessionId: 11)]);
      await emit([
        _runtime(1, state: 'INTERRUPTED', volume: 95, elapsedMs: 122000),
      ]);

      final last = controller.lastDispatchesForPanel.single;
      expect(last.session.state, DispatchState.interrupted);
      expect(last.session.dispensedVolume, 95);
      expect(last.dispatchElapsedMs, 122000);
    },
  );

  test('does not invent history for garzas that were already idle', () async {
    await emit([_runtime(1), _runtime(2)]);
    expect(controller.lastDispatchesForPanel, isEmpty);
    expect(controller.runtimePanelGarzasCount, 0);
    expect(api.requestedIds, isEmpty);
  });

  test(
    'does not replace confirmed final values with the last busy reading',
    () async {
      api.load = (_) async => throw AppException(message: 'Sin conexión');
      await emit([_runtime(1, sessionId: 11)]);
      controller.activeSession = _session(1, 11, elapsedMs: 123456);
      await emit([_runtime(1)]);

      final last = controller.lastDispatchesForPanel.single;
      expect(last.dispatchElapsedMs, 123456);
      expect(last.session.dispensedVolume, 100);
      expect(last.session.state, DispatchState.completed);
    },
  );

  test(
    'does not close a confirmed paused session using an older release',
    () async {
      await emit([_runtime(1, sessionId: 11)]);
      controller.activeSession = _session(1, 11).copyWith(
        state: DispatchState.paused,
        updatedAt: '2026-11-02T18:30:11Z',
      );
      await emit([_runtime(1)]);
      expect(controller.activeSession?.state, DispatchState.paused);
      expect(controller.lastDispatches, isEmpty);
      expect(api.requestedIds, isEmpty);
    },
  );

  test(
    'reopening a recent dispatch cannot restart it with a stale API response',
    () async {
      api.load = (id) async =>
          _session(1, id).copyWith(state: DispatchState.dispensing);
      await emit([_runtime(1, sessionId: 11)]);
      await emit([_runtime(1)]);
      controller.selectLastDispatch(controller.lastDispatchesForPanel.single);
      await controller.loadRuntimeSession(11);

      expect(controller.activeSession?.state, DispatchState.completed);
      expect(controller.dispatchElapsed.inMilliseconds, 120000);
      expect(
        controller.shouldRunDispatchTimer(controller.activeSession!),
        isFalse,
      );
    },
  );

  testWidgets('overlay keeps the released garza and opens its final time', (
    tester,
  ) async {
    controller.syncRuntimeStream(shouldRun: false);
    controller.syncRuntimeStream(shouldRun: true);
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final navigation = NavigationService();
    locator.registerSingleton<NavigationService>(navigation);
    addTearDown(() => locator.unregister<NavigationService>());
    api.load = (id) async => _session(1, id, elapsedMs: 123456);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DispatchController>.value(value: controller),
          ChangeNotifierProvider<AuthController>(
            create: (_) => _AuthController(),
          ),
        ],
        child: GlobalLoaderOverlay(
          child: MaterialApp(
            navigatorKey: navigation.navigatorKey,
            home: const HomeDispatchView(),
          ),
        ),
      ),
    );
    void send(GarzaRuntimeEntity garza) => api.snapshots.add(
      GarzaRuntimeResponseEntity(
        garzas: [garza],
        updatedAt: null,
        message: null,
      ),
    );
    send(_runtime(1, sessionId: 11));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.local_drink_outlined));
    await tester.pump();
    expect(find.text('Garza 1'), findsOneWidget);
    expect(find.text('Ocupadas'), findsOneWidget);

    send(_runtime(1));
    await tester.pump();
    await tester.pump();
    expect(find.text('Garza 1'), findsOneWidget);
    expect(find.text('Último despacho'), findsOneWidget);
    expect(controller.lastDispatchesForPanel.single.dispatchElapsedMs, 123456);
    expect(find.textContaining('02:03:456'), findsOneWidget);
    expect(find.text('Ocupadas'), findsNothing);

    await tester.tap(find.text('Garza 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(find.byType(DispatchSessionView), findsOneWidget);
    expect(find.text('02:03:456'), findsOneWidget);
    expect(find.text('Pausar'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('02:03:456'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _AuthController extends ChangeNotifier implements AuthController {
  @override
  AppRole get role => AppRole.dispatch;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SessionApi extends DispatchSessionsApi {
  _SessionApi(ApiClient client) : super(apiClient: client);

  final snapshots = StreamController<GarzaRuntimeResponseEntity>.broadcast();
  final requestedIds = <int>[];
  late Future<DispatchSessionEntity> Function(int) load;

  @override
  Stream<GarzaRuntimeResponseEntity> streamGarzaRuntime() => snapshots.stream;

  @override
  Future<DispatchSessionEntity> getSession(int sessionId) {
    requestedIds.add(sessionId);
    return load(sessionId);
  }
}

GarzaRuntimeEntity _runtime(
  int number, {
  int? sessionId,
  String? state,
  double? volume,
  int? elapsedMs,
}) => GarzaRuntimeEntity.fromMap({
  'garza_number': number,
  'is_enabled': true,
  'mode': 'automatic',
  'is_busy': sessionId != null,
  'current_state': state ?? (sessionId == null ? null : 'DISPENSING'),
  'active_session_id': sessionId,
  'sale_folio': sessionId == null ? null : 'F-$sessionId',
  'dispatch_code': sessionId == null ? null : 'D-$sessionId',
  'unit_of_measurement': 'liters',
  'authorized_volume': sessionId == null ? 0 : 100,
  'dispensed_volume': volume ?? (sessionId == null ? 0 : 90),
  'dispatch_elapsed_ms': elapsedMs ?? (sessionId == null ? 0 : 120000),
  'alarms': <String, bool>{},
  'updated_at': '2026-11-02T18:30:10Z',
});

DispatchSessionEntity _session(
  int number,
  int id, {
  int elapsedMs = 123000,
  double volume = 100,
}) => DispatchSessionEntity.fromMap({
  'id': id,
  'garza_number': number,
  'sale_folio': 'F-$id',
  'dispatch_code': 'D-$id',
  'mode': 'automatic',
  'state': 'COMPLETED',
  'unit_of_measurement': 'liters',
  'authorized_volume': 100,
  'dispensed_volume': volume,
  'dispatch_elapsed_ms': elapsedMs,
  'created_at': '2026-11-02T18:28:00Z',
  'updated_at': '2026-11-02T18:30:09Z',
});
