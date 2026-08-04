import 'package:flutter_test/flutter_test.dart';
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
}
