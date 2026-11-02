import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/data/dispatch_sessions_api.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';
import 'package:frontend_garzas/src/dispatch/views/dispatch_session_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('clock advances without rebuilding the summary or pause button', (
    tester,
  ) async {
    final fixture = await _mount(tester);
    final fields = _fields(tester);
    final pause = tester.widget<IsselButton>(find.byType(IsselButton));
    expect(find.text('00:01:000'), findsOneWidget);

    for (var tick = 1; tick <= 60; tick++) {
      fixture.controller.displayElapsed = Duration(
        milliseconds: 1000 + tick * 50,
      );
      await tester.pump(const Duration(milliseconds: 20));
      final current = _fields(tester);
      for (var index = 0; index < fields.length; index++) {
        expect(identical(current[index], fields[index]), isTrue);
      }
      expect(
        identical(tester.widget<IsselButton>(find.byType(IsselButton)), pause),
        isTrue,
      );
    }
    expect(find.text('00:04:000'), findsOneWidget);
    await fixture.dispose(tester);
  });

  testWidgets('runtime updates liters using the same field controllers', (
    tester,
  ) async {
    final fixture = await _mount(tester);
    final controllers = _fields(
      tester,
    ).map((field) => field.controller).toList();
    fixture.controller.syncRuntimeStream(shouldRun: true);

    for (var liters = 26; liters <= 75; liters++) {
      fixture.api.snapshots.add(_snapshot(liters.toDouble()));
      await tester.pump(const Duration(milliseconds: 50));
      final fields = _fields(tester);
      for (var index = 0; index < fields.length; index++) {
        expect(identical(fields[index].controller, controllers[index]), isTrue);
      }
      expect(fields.last.controller!.text, startsWith('$liters.00 / 100.00'));
      expect(find.text('Pausar'), findsOneWidget);
    }
    await fixture.dispose(tester);
    for (final controller in controllers) {
      expect(() => controller!.addListener(() {}), throwsFlutterError);
    }
  });

  testWidgets(
    'older runtime readings cannot hide a newer session volume or state',
    (tester) async {
      final response = Completer<DispatchSessionEntity>();
      final fixture = await _mount(tester, sessionResponse: response.future);
      fixture.controller.syncRuntimeStream(shouldRun: true);
      fixture.api.snapshots.add(_snapshot(25, state: 'PAUSED'));
      await tester.pump();
      expect(find.text('25.00 / 100.00 l'), findsOneWidget);

      response.complete(
        _session.copyWith(
          dispensedVolume: 30,
          updatedAt: '2026-09-17T00:00:02Z',
        ),
      );
      await tester.pump();
      expect(find.text('30.00 / 100.00 l'), findsOneWidget);
      expect(find.text('Despachando'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);

      fixture.api.snapshots.add(_snapshot(28, state: 'PAUSED'));
      await tester.pump();
      expect(find.text('30.00 / 100.00 l'), findsOneWidget);
      expect(find.text('Despachando'), findsOneWidget);

      fixture.api.snapshots.add(_snapshot(35, second: 3));
      await tester.pump();
      expect(find.text('35.00 / 100.00 l'), findsOneWidget);
      expect(find.text('Despachando'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);
      await fixture.dispose(tester);
    },
  );

  testWidgets(
    'pause and resume keep the clock synchronized with confirmed state',
    (tester) async {
      final fixture = await _mount(tester);
      locator.registerSingleton<ToastService>(_SilentToastService());
      addTearDown(() => locator.unregister<ToastService>());

      fixture.controller.displayElapsed = const Duration(milliseconds: 2500);
      await tester.tap(find.text('Pausar'));
      await tester.pump();
      await tester.pump();
      expect(fixture.api.actions, ['pause']);
      expect(find.text('Reanudar'), findsOneWidget);
      expect(find.text('00:02:500'), findsOneWidget);

      fixture.controller.displayElapsed = const Duration(seconds: 9);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:02:500'), findsOneWidget);

      fixture.controller.displayElapsed = const Duration(milliseconds: 2500);
      await tester.tap(find.text('Reanudar'));
      await tester.pump();
      await tester.pump();
      expect(fixture.api.actions, ['pause', 'resume']);
      expect(find.text('Pausar'), findsOneWidget);
      fixture.controller.displayElapsed = const Duration(seconds: 3);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('00:03:000'), findsOneWidget);

      await fixture.dispose(tester);
    },
  );

  testWidgets('alarm stops visual clock updates and removes dispatch actions', (
    tester,
  ) async {
    final fixture = await _mount(tester);
    fixture.controller.syncRuntimeStream(shouldRun: true);
    fixture.controller.displayElapsed = const Duration(seconds: 2);
    fixture.api.snapshots.add(_snapshot(25, alarm: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Pausar'), findsNothing);
    expect(find.text('00:02:000'), findsOneWidget);
    fixture.controller.displayElapsed = const Duration(seconds: 10);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:02:000'), findsOneWidget);
    await fixture.dispose(tester);
  });

  testWidgets(
    'stream loss freezes the displayed time and explains the interruption',
    (tester) async {
      final fixture = await _mount(tester);
      fixture.controller.syncRuntimeStream(shouldRun: true);
      fixture.controller.displayElapsed = const Duration(seconds: 2);
      fixture.api.snapshots.add(_snapshot(25));
      await tester.pump();
      await fixture.api.snapshots.close();
      await tester.pump();
      expect(
        find.text('Sin actualizaciones del despacho. Esperando reconexión.'),
        findsOneWidget,
      );
      expect(find.text('00:02:000'), findsOneWidget);
      fixture.controller.displayElapsed = const Duration(seconds: 10);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:02:000'), findsOneWidget);
      await fixture.dispose(tester);
    },
  );

  testWidgets('live time remains visible while a screen refresh is pending', (
    tester,
  ) async {
    final response = Completer<DispatchSessionEntity>();
    final fixture = await _mount(tester, sessionResponse: response.future);
    expect(find.byType(IsselTextFormField), findsWidgets);
    expect(find.text('00:01:000'), findsOneWidget);
    fixture.controller.syncRuntimeStream(shouldRun: true);
    fixture.controller.displayElapsed = const Duration(seconds: 2);
    fixture.api.snapshots.add(_snapshot(30));
    await tester.pump();
    await tester.pump();
    expect(find.text('00:02:000'), findsOneWidget);
    response.complete(_session.copyWith(state: DispatchState.paused));
    await tester.pump();
    expect(fixture.controller.activeSession?.state, DispatchState.dispensing);
    expect(find.text('Pausar'), findsOneWidget);
    await fixture.dispose(tester);
  });
}

List<IsselTextFormField> _fields(WidgetTester tester) => tester
    .widgetList<IsselTextFormField>(find.byType(IsselTextFormField))
    .toList();

Future<_Fixture> _mount(
  WidgetTester tester, {
  Future<DispatchSessionEntity>? sessionResponse,
}) async {
  tester.view.physicalSize = const Size(1366, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final client = ApiClient(serverStatusController: ServerStatusController());
  final api = _SessionApi(client)..sessionResponse = sessionResponse;
  final controller = _ClockController(client, api)..activeSession = _session;
  await tester.pumpWidget(
    ChangeNotifierProvider<DispatchController>.value(
      value: controller,
      child: const GlobalLoaderOverlay(
        child: MaterialApp(home: DispatchSessionView()),
      ),
    ),
  );
  await tester.pump();
  return _Fixture(controller, api);
}

class _Fixture {
  _Fixture(this.controller, this.api);
  final _ClockController controller;
  final _SessionApi api;

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    controller.syncRuntimeStream(shouldRun: false);
    controller.dispose();
    await api.snapshots.close();
  }
}

// Control elapsed time independently from pump's virtual clock. Production
// Stopwatch behavior is exercised by the controller tests, not this UI probe.
class _ClockController extends DispatchController {
  _ClockController(ApiClient client, DispatchSessionsApi api)
    : super(
        salesApi: SalesApi(apiClient: client),
        garzasApi: GarzasApi(apiClient: client),
        dispatchSessionsApi: api,
        pendingDispatchesApi: PendingDispatchesApi(apiClient: client),
      );

  Duration displayElapsed = const Duration(seconds: 1);
  @override
  Duration get dispatchElapsed => displayElapsed;
}

class _SessionApi extends DispatchSessionsApi {
  _SessionApi(ApiClient client) : super(apiClient: client);
  final snapshots = StreamController<GarzaRuntimeResponseEntity>.broadcast();
  final actions = <String>[];
  Future<DispatchSessionEntity>? sessionResponse;
  @override
  Stream<GarzaRuntimeResponseEntity> streamGarzaRuntime() => snapshots.stream;
  @override
  Future<DispatchSessionEntity> getSession(int id) async =>
      sessionResponse ?? _session;
  @override
  Future<DispatchSessionEntity> pauseSession(int id) async {
    actions.add('pause');
    return _session.copyWith(
      state: DispatchState.paused,
      dispatchElapsedMs: 2500,
    );
  }

  @override
  Future<DispatchSessionEntity> resumeSession(int id) async {
    actions.add('resume');
    return _session.copyWith(dispatchElapsedMs: 2500);
  }
}

class _SilentToastService extends ToastService {
  @override
  void success(String text) {}
}

final _session = DispatchSessionEntity.fromMap({
  'id': 1,
  'garza_number': 1,
  'mode': 'automatic',
  'unit_of_measurement': 'liters',
  'authorized_volume': 100,
  'dispensed_volume': 25,
  'dispatch_elapsed_ms': 1000,
  'state': 'DISPENSING',
  'created_at': '2026-09-17T00:00:00Z',
  'updated_at': '2026-09-17T00:00:00Z',
});

GarzaRuntimeResponseEntity _snapshot(
  double liters, {
  bool alarm = false,
  int second = 1,
  String state = 'DISPENSING',
}) => GarzaRuntimeResponseEntity.fromMap({
  'garzas': [
    {
      'garza_number': 1,
      'is_enabled': true,
      'mode': 'automatic',
      'is_busy': true,
      'current_state': state,
      'active_session_id': 1,
      'unit_of_measurement': 'liters',
      'authorized_volume': 100,
      'dispensed_volume': liters,
      'dispatch_elapsed_ms': 2000,
      'alarms': <String, bool>{'emergency_stop': alarm},
      'updated_at': '2026-09-17T00:00:${second.toString().padLeft(2, '0')}Z',
    },
  ],
  'updated_at': '2026-09-17T00:00:${second.toString().padLeft(2, '0')}Z',
});
