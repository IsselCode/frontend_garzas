import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/data/dispatch_sessions_api.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';

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
    if (!api.snapshots.isClosed) await api.snapshots.close();
  });

  Future<void> emit(GarzaRuntimeEntity runtime) async {
    api.snapshots.add(
      GarzaRuntimeResponseEntity(
        garzas: [runtime],
        updatedAt: runtime.updatedAt,
        message: null,
      ),
    );
    await Future<void>.delayed(Duration.zero);
  }

  test('a late screen load cannot replace the next selected garza', () async {
    final delayed = Completer<DispatchSessionEntity>();
    api.load = (id) =>
        id == 11 ? delayed.future : Future.value(_session(2, 22));
    controller.selectRuntimeGarza(_runtime(1, 11));
    final firstLoad = controller.loadRuntimeSession(11);
    controller.selectRuntimeGarza(_runtime(2, 22));
    await controller.loadRuntimeSession(22);
    delayed.complete(_session(1, 11));
    await firstLoad;

    expect(controller.activeSession?.id, 22);
    expect(controller.selectedRuntimeGarza?.garzaNumber, 2);
  });

  test(
    'opening a screen uses the live runtime instead of an older HTTP state',
    () async {
      await emit(_runtime(1, 11, elapsedMs: 5000));
      controller.selectRuntimeGarza(
        _runtime(1, 11, state: 'PAUSED', second: 8, elapsedMs: 1000),
      );
      api.load = (_) async =>
          _session(1, 11, state: 'PAUSED', second: 8, elapsedMs: 1000);
      await controller.loadRuntimeSession(11);

      expect(controller.activeSession?.state, DispatchState.dispensing);
      expect(
        controller.dispatchElapsed.inMilliseconds,
        greaterThanOrEqualTo(5000),
      );
      expect(
        controller.shouldRunDispatchTimer(controller.activeSession!),
        isTrue,
      );
    },
  );

  test(
    'a response started before a newer stream event cannot roll the clock back',
    () async {
      final delayed = Completer<DispatchSessionEntity>();
      api.load = (_) => delayed.future;
      controller.selectRuntimeGarza(_runtime(1, 11));
      final load = controller.loadRuntimeSession(11);
      await emit(_runtime(1, 11, elapsedMs: 7000, second: 11));
      delayed.complete(
        _session(1, 11, state: 'PAUSED', elapsedMs: 1000, second: 8),
      );
      await load;

      expect(controller.activeSession?.state, DispatchState.dispensing);
      expect(
        controller.dispatchElapsed.inMilliseconds,
        greaterThanOrEqualTo(7000),
      );
    },
  );

  test(
    'a late pause response cannot replace another screen selection',
    () async {
      api.load = (id) async => _session(id == 11 ? 1 : 2, id);
      final delayed = Completer<DispatchSessionEntity>();
      api.pause = (_) => delayed.future;
      controller.selectRuntimeGarza(_runtime(1, 11));
      await controller.loadRuntimeSession(11);
      final action = controller.pauseActiveSession();
      controller.selectRuntimeGarza(_runtime(2, 22));
      await controller.loadRuntimeSession(22);
      delayed.complete(_session(1, 11, state: 'PAUSED', second: 11));
      await action;

      expect(controller.activeSession?.id, 22);
      expect(controller.activeSession?.state, DispatchState.dispensing);
    },
  );

  test(
    'duplicate elapsed readings do not restart the local stopwatch',
    () async {
      api.load = (_) async => _session(1, 11);
      controller.selectRuntimeGarza(_runtime(1, 11));
      await controller.loadRuntimeSession(11);
      for (var count = 0; count < 3; count++) {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await emit(_runtime(1, 11));
      }
      expect(
        controller.dispatchElapsed.inMilliseconds,
        greaterThanOrEqualTo(1060),
      );
    },
  );

  test(
    'stream disconnection stops extrapolation until runtime returns',
    () async {
      api.load = (_) async => _session(1, 11);
      controller.selectRuntimeGarza(_runtime(1, 11));
      await controller.loadRuntimeSession(11);
      await emit(_runtime(1, 11));
      await api.snapshots.close();
      await Future<void>.delayed(Duration.zero);
      final stopped = controller.dispatchElapsed;
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        controller.shouldRunDispatchTimer(controller.activeSession!),
        isFalse,
      );
      expect(controller.dispatchElapsed, stopped);
      expect(controller.hasRuntimeWarning, isTrue);
    },
  );

  testWidgets(
    'a stalled stream is detected and a fresh heartbeat restores synchronization',
    (tester) async {
      controller.syncRuntimeStream(shouldRun: false);
      controller.syncRuntimeStream(shouldRun: true);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.selectRuntimeGarza(_runtime(1, 11));
      void heartbeat() => api.snapshots.add(
        GarzaRuntimeResponseEntity(
          garzas: [_runtime(1, 11)],
          updatedAt: null,
          message: null,
        ),
      );
      heartbeat();
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      heartbeat();
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      expect(controller.runtimeStreamInterrupted, isFalse);
      await tester.pump(const Duration(seconds: 6));
      expect(controller.runtimeStreamInterrupted, isTrue);
      expect(
        controller.shouldRunDispatchTimer(controller.activeSession!),
        isFalse,
      );

      await tester.pump(const Duration(seconds: 5));
      heartbeat();
      await tester.pump();
      expect(controller.runtimeStreamInterrupted, isFalse);
      expect(
        controller.shouldRunDispatchTimer(controller.activeSession!),
        isTrue,
      );
      controller.syncRuntimeStream(shouldRun: false);
    },
  );
}

class _SessionApi extends DispatchSessionsApi {
  _SessionApi(ApiClient client) : super(apiClient: client);
  final snapshots = StreamController<GarzaRuntimeResponseEntity>.broadcast();
  late Future<DispatchSessionEntity> Function(int) load;
  late Future<DispatchSessionEntity> Function(int) pause;
  @override
  Stream<GarzaRuntimeResponseEntity> streamGarzaRuntime() => snapshots.stream;
  @override
  Future<DispatchSessionEntity> getSession(int id) => load(id);
  @override
  Future<DispatchSessionEntity> pauseSession(int id) => pause(id);
}

GarzaRuntimeEntity _runtime(
  int number,
  int id, {
  String state = 'DISPENSING',
  int second = 10,
  int elapsedMs = 1000,
}) => GarzaRuntimeEntity.fromMap({
  'garza_number': number,
  'is_enabled': true,
  'mode': 'automatic',
  'is_busy': true,
  'current_state': state,
  'active_session_id': id,
  'unit_of_measurement': 'liters',
  'authorized_volume': 100,
  'dispensed_volume': 25,
  'dispatch_elapsed_ms': elapsedMs,
  'alarms': <String, bool>{},
  'updated_at': '2026-11-02T18:30:${second.toString().padLeft(2, '0')}Z',
});

DispatchSessionEntity _session(
  int number,
  int id, {
  String state = 'DISPENSING',
  int second = 10,
  int elapsedMs = 1000,
}) => DispatchSessionEntity.fromMap({
  'id': id,
  'garza_number': number,
  'mode': 'automatic',
  'state': state,
  'unit_of_measurement': 'liters',
  'authorized_volume': 100,
  'dispensed_volume': 25,
  'dispatch_elapsed_ms': elapsedMs,
  'created_at': '2026-11-02T18:28:00Z',
  'updated_at': '2026-11-02T18:30:${second.toString().padLeft(2, '0')}Z',
});
