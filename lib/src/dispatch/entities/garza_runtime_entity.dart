import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';

class GarzaRuntimeResponseEntity extends Equatable {
  final List<GarzaRuntimeEntity> garzas;
  final String? updatedAt;
  final String? message;

  const GarzaRuntimeResponseEntity({
    required this.garzas,
    required this.updatedAt,
    required this.message,
  });

  factory GarzaRuntimeResponseEntity.fromMap(Map<String, dynamic> map) {
    final garzas = (map['garzas'] as List<dynamic>)
        .map((e) => GarzaRuntimeEntity.fromMap(e as Map<String, dynamic>))
        .toList();

    return GarzaRuntimeResponseEntity(
      garzas: garzas,
      updatedAt: map['updated_at'],
      message: map['message'],
    );
  }

  @override
  List<Object?> get props => [garzas, updatedAt, message];
}

class GarzaRuntimeEntity extends Equatable {
  final int garzaNumber;
  final bool isEnabled;
  final DispatchMode mode;
  final bool isBusy;
  final DispatchState? currentState;
  final int? activeSessionId;
  final String? saleFolio;
  final String? dispatchCode;
  final UnitOfMeasurement unitOfMeasurement;
  final double authorizedVolume;
  final double dispensedVolume;
  final int? dispatchElapsedMs;
  final Map<String, bool> alarms;
  final String updatedAt;

  const GarzaRuntimeEntity({
    required this.garzaNumber,
    required this.isEnabled,
    required this.mode,
    required this.isBusy,
    required this.currentState,
    required this.activeSessionId,
    required this.saleFolio,
    required this.dispatchCode,
    required this.unitOfMeasurement,
    required this.authorizedVolume,
    required this.dispensedVolume,
    this.dispatchElapsedMs,
    required this.alarms,
    required this.updatedAt,
  });

  bool get hasActiveAlarms => alarms.values.any((value) => value);

  List<String> get activeAlarmNames => alarms.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  List<String> get activeAlarmDisplayNames =>
      activeAlarmNames.map(alarmDisplayName).toList();

  static String alarmDisplayName(String alarmName) {
    switch (alarmName) {
      case 'emergency_stop':
        return 'paro de emergencia';
      case 'no_water_flow_alarm':
        return 'sin flujo de agua';
      case 'water_flow_active_alarm':
        return 'flujo de agua activo';
      default:
        return alarmName.replaceAll('_alarm', '').replaceAll('_', ' ');
    }
  }

  factory GarzaRuntimeEntity.fromMap(Map<String, dynamic> map) {
    return GarzaRuntimeEntity(
      garzaNumber: map['garza_number'],
      isEnabled: map['is_enabled'],
      mode: DispatchMode.fromString(map['mode']),
      isBusy: map['is_busy'],
      currentState: DispatchState.fromString(map['current_state']),
      activeSessionId: map['active_session_id'],
      saleFolio: map['sale_folio'],
      dispatchCode: map['dispatch_code'],
      unitOfMeasurement: UnitOfMeasurement.fromString(
        map['unit_of_measurement'],
      ),
      authorizedVolume: (map['authorized_volume'] as num).toDouble(),
      dispensedVolume: (map['dispensed_volume'] as num).toDouble(),
      dispatchElapsedMs: switch (map['dispatch_elapsed_ms']) {
        final num value => value.toInt(),
        _ => null,
      },
      alarms: Map<String, bool>.from(map['alarms'] ?? {}),
      updatedAt: map['updated_at'],
    );
  }

  @override
  List<Object?> get props => [
    garzaNumber,
    isEnabled,
    mode,
    isBusy,
    currentState,
    activeSessionId,
    saleFolio,
    dispatchCode,
    unitOfMeasurement,
    authorizedVolume,
    dispensedVolume,
    dispatchElapsedMs,
    alarms,
    updatedAt,
  ];
}
