import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

enum DispatchState {
  authorized(label: 'Autorizada'),
  dispensing(label: 'Despachando'),
  paused(label: 'Pausada'),
  completed(label: 'Completada'),
  interrupted(label: 'Interrumpida');

  final String label;

  const DispatchState({required this.label});

  static DispatchState? fromString(String? value) {
    switch (value) {
      case 'AUTHORIZED':
        return DispatchState.authorized;
      case 'DISPENSING':
        return DispatchState.dispensing;
      case 'PAUSED':
        return DispatchState.paused;
      case 'COMPLETED':
        return DispatchState.completed;
      case 'INTERRUPTED':
        return DispatchState.interrupted;
      case null:
        return null;
      default:
        return DispatchState.interrupted;
    }
  }
}

enum DispatchMode {
  automatic(label: 'Automatico'),
  manual(label: 'Manual');

  final String label;

  const DispatchMode({required this.label});

  static DispatchMode fromString(String? value) {
    switch (value) {
      case 'automatic':
        return DispatchMode.automatic;
      case 'manual':
        return DispatchMode.manual;
      default:
        return DispatchMode.manual;
    }
  }
}

class DispatchSessionEntity extends Equatable {
  final int id;
  final String saleFolio;
  final String dispatchCode;
  final int garzaNumber;
  final String? operatorUid;
  final String? operatorUsername;
  final DispatchMode mode;
  final UnitOfMeasurement unitOfMeasurement;
  final double authorizedVolume;
  final double dispensedVolume;
  final DispatchState state;
  final String? closeReason;
  final String? lastPlcSnapshotJson;
  final String? startedAt;
  final String? pausedAt;
  final String? completedAt;
  final String? interruptedAt;
  final String createdAt;
  final String updatedAt;

  const DispatchSessionEntity({
    required this.id,
    required this.saleFolio,
    required this.dispatchCode,
    required this.garzaNumber,
    required this.operatorUid,
    required this.operatorUsername,
    required this.mode,
    required this.unitOfMeasurement,
    required this.authorizedVolume,
    required this.dispensedVolume,
    required this.state,
    required this.closeReason,
    required this.lastPlcSnapshotJson,
    required this.startedAt,
    required this.pausedAt,
    required this.completedAt,
    required this.interruptedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DispatchSessionEntity.fromMap(Map<String, dynamic> map) {
    return DispatchSessionEntity(
      id: map['id'],
      saleFolio: map['sale_folio'],
      dispatchCode: map['dispatch_code'],
      garzaNumber: map['garza_number'],
      operatorUid: map['operator_uid'],
      operatorUsername: map['operator_username'],
      mode: DispatchMode.fromString(map['mode']),
      unitOfMeasurement: UnitOfMeasurement.fromString(
        map['unit_of_measurement'],
      ),
      authorizedVolume: (map['authorized_volume'] as num).toDouble(),
      dispensedVolume: (map['dispensed_volume'] as num).toDouble(),
      state: DispatchState.fromString(map['state']) ?? DispatchState.interrupted,
      closeReason: map['close_reason'],
      lastPlcSnapshotJson: map['last_plc_snapshot_json'],
      startedAt: map['started_at'],
      pausedAt: map['paused_at'],
      completedAt: map['completed_at'],
      interruptedAt: map['interrupted_at'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  DispatchSessionEntity copyWith({
    int? id,
    String? saleFolio,
    String? dispatchCode,
    int? garzaNumber,
    String? operatorUid,
    String? operatorUsername,
    DispatchMode? mode,
    UnitOfMeasurement? unitOfMeasurement,
    double? authorizedVolume,
    double? dispensedVolume,
    DispatchState? state,
    String? closeReason,
    String? lastPlcSnapshotJson,
    String? startedAt,
    String? pausedAt,
    String? completedAt,
    String? interruptedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return DispatchSessionEntity(
      id: id ?? this.id,
      saleFolio: saleFolio ?? this.saleFolio,
      dispatchCode: dispatchCode ?? this.dispatchCode,
      garzaNumber: garzaNumber ?? this.garzaNumber,
      operatorUid: operatorUid ?? this.operatorUid,
      operatorUsername: operatorUsername ?? this.operatorUsername,
      mode: mode ?? this.mode,
      unitOfMeasurement: unitOfMeasurement ?? this.unitOfMeasurement,
      authorizedVolume: authorizedVolume ?? this.authorizedVolume,
      dispensedVolume: dispensedVolume ?? this.dispensedVolume,
      state: state ?? this.state,
      closeReason: closeReason ?? this.closeReason,
      lastPlcSnapshotJson: lastPlcSnapshotJson ?? this.lastPlcSnapshotJson,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      interruptedAt: interruptedAt ?? this.interruptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    saleFolio,
    dispatchCode,
    garzaNumber,
    operatorUid,
    operatorUsername,
    mode,
    unitOfMeasurement,
    authorizedVolume,
    dispensedVolume,
    state,
    closeReason,
    lastPlcSnapshotJson,
    startedAt,
    pausedAt,
    completedAt,
    interruptedAt,
    createdAt,
    updatedAt,
  ];
}
