import 'dart:async';

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
  test('parses dispatch_elapsed_ms from a runtime snapshot', () {
    final runtime = GarzaRuntimeEntity.fromMap({
      'garza_number': 4,
      'is_enabled': true,
      'mode': 'automatic',
      'is_busy': true,
      'current_state': 'DISPENSING',
      'active_session_id': 2405,
      'sale_folio': 'F-1',
      'dispatch_code': 'D-1',
      'unit_of_measurement': 'liters',
      'authorized_volume': 100,
      'dispensed_volume': 25,
      'dispatch_elapsed_ms': 496340,
      'alarms': <String, bool>{},
      'updated_at': '2026-08-04T18:30:10.250Z',
    });

    expect(runtime.dispatchElapsedMs, 496340);
  });

  test('parses dispatch_elapsed_ms from a dispatch session', () {
    final session = DispatchSessionEntity.fromMap({
      'id': 2405,
      'sale_folio': 'F-1',
      'dispatch_code': 'D-1',
      'garza_number': 4,
      'operator_uid': 'operator-1',
      'operator_username': 'Operator',
      'mode': 'automatic',
      'unit_of_measurement': 'liters',
      'authorized_volume': 100,
      'dispensed_volume': 25,
      'dispatch_elapsed_ms': 496340,
      'state': 'DISPENSING',
      'close_reason': null,
      'last_plc_snapshot_json': null,
      'started_at': '2026-08-04T18:20:00Z',
      'paused_at': null,
      'completed_at': null,
      'interrupted_at': null,
      'created_at': '2026-08-04T18:19:00Z',
      'updated_at': '2026-08-04T18:30:10Z',
    });

    expect(session.dispatchElapsedMs, 496340);
  });

  test(
    'does not run the timer when the selected garza has an active alarm',
    () {
      final controller = _createController();
      final session = _session(state: 'DISPENSING');
      final runtime = _runtime(
        currentState: 'DISPENSING',
        alarms: {'emergency_stop': true},
      );

      expect(
        controller.shouldRunDispatchTimer(session, runtimeGarza: runtime),
        isFalse,
      );
    },
  );

  test('does not run the timer for a paused session or released runtime', () {
    final controller = _createController();
    final runtime = _runtime(currentState: 'DISPENSING');

    expect(
      controller.shouldRunDispatchTimer(
        _session(state: 'PAUSED'),
        runtimeGarza: runtime,
      ),
      isFalse,
    );
    expect(
      controller.shouldRunDispatchTimer(
        _session(state: 'DISPENSING'),
        runtimeGarza: runtime,
        isBusy: false,
      ),
      isFalse,
    );
  });

  test(
    'ignores a runtime snapshot older than the confirmed session state',
    () async {
      final streamApi = _StreamDispatchSessionsApi(
        apiClient: _createApiClient(),
      );
      final controller = _createController(dispatchSessionsApi: streamApi);
      controller.activeSession = _session(
        state: 'PAUSED',
        updatedAt: '2026-08-04T18:30:10.250Z',
      );
      controller.syncRuntimeStream(shouldRun: true);

      streamApi.runtimeStreamController.add(
        GarzaRuntimeResponseEntity(
          garzas: [
            _runtime(
              currentState: 'DISPENSING',
              updatedAt: '2026-08-04T18:30:09.250Z',
            ),
          ],
          updatedAt: '2026-08-04T18:30:09.250Z',
          message: null,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.activeSession?.state, DispatchState.paused);

      controller.dispose();
      await streamApi.runtimeStreamController.close();
    },
  );
}

ApiClient _createApiClient() {
  return ApiClient(serverStatusController: ServerStatusController());
}

DispatchController _createController({
  DispatchSessionsApi? dispatchSessionsApi,
}) {
  final apiClient = _createApiClient();
  return DispatchController(
    salesApi: SalesApi(apiClient: apiClient),
    garzasApi: GarzasApi(apiClient: apiClient),
    dispatchSessionsApi:
        dispatchSessionsApi ?? DispatchSessionsApi(apiClient: apiClient),
    pendingDispatchesApi: PendingDispatchesApi(apiClient: apiClient),
  );
}

DispatchSessionEntity _session({
  required String state,
  String updatedAt = '2026-08-04T18:30:10.250Z',
}) {
  return DispatchSessionEntity.fromMap({
    'id': 2405,
    'sale_folio': 'F-1',
    'dispatch_code': 'D-1',
    'garza_number': 4,
    'operator_uid': 'operator-1',
    'operator_username': 'Operator',
    'mode': 'automatic',
    'unit_of_measurement': 'liters',
    'authorized_volume': 100,
    'dispensed_volume': 25,
    'dispatch_elapsed_ms': 496340,
    'state': state,
    'close_reason': null,
    'last_plc_snapshot_json': null,
    'started_at': '2026-08-04T18:20:00Z',
    'paused_at': null,
    'completed_at': null,
    'interrupted_at': null,
    'created_at': '2026-08-04T18:19:00Z',
    'updated_at': updatedAt,
  });
}

GarzaRuntimeEntity _runtime({
  required String currentState,
  Map<String, bool> alarms = const {},
  String updatedAt = '2026-08-04T18:30:10.250Z',
  bool isBusy = true,
}) {
  return GarzaRuntimeEntity.fromMap({
    'garza_number': 4,
    'is_enabled': true,
    'mode': 'automatic',
    'is_busy': isBusy,
    'current_state': currentState,
    'active_session_id': 2405,
    'sale_folio': 'F-1',
    'dispatch_code': 'D-1',
    'unit_of_measurement': 'liters',
    'authorized_volume': 100,
    'dispensed_volume': 25,
    'dispatch_elapsed_ms': 496340,
    'alarms': alarms,
    'updated_at': updatedAt,
  });
}

class _StreamDispatchSessionsApi extends DispatchSessionsApi {
  final StreamController<GarzaRuntimeResponseEntity> runtimeStreamController =
      StreamController<GarzaRuntimeResponseEntity>.broadcast();

  _StreamDispatchSessionsApi({required super.apiClient});

  @override
  Stream<GarzaRuntimeResponseEntity> streamGarzaRuntime() =>
      runtimeStreamController.stream;
}
