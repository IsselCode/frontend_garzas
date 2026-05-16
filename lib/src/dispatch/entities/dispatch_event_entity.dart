import 'package:equatable/equatable.dart';

class DispatchEventEntity extends Equatable {
  final int id;
  final int? dispatchSessionId;
  final String saleFolio;
  final String type;
  final int dispatchedGarzaNumber;
  final double litersDispensed;
  final String? dispatchedByUid;
  final String? dispatchedByUsername;
  final String? message;
  final String? snapshotJson;
  final String dispatchedAt;

  const DispatchEventEntity({
    required this.id,
    required this.dispatchSessionId,
    required this.saleFolio,
    required this.type,
    required this.dispatchedGarzaNumber,
    required this.litersDispensed,
    required this.dispatchedByUid,
    required this.dispatchedByUsername,
    required this.message,
    required this.snapshotJson,
    required this.dispatchedAt,
  });

  factory DispatchEventEntity.fromMap(Map<String, dynamic> map) {
    return DispatchEventEntity(
      id: map['id'],
      dispatchSessionId: map['dispatch_session_id'],
      saleFolio: map['sale_folio'],
      type: map['type'],
      dispatchedGarzaNumber: map['dispatched_garza_number'],
      litersDispensed: (map['liters_dispensed'] as num).toDouble(),
      dispatchedByUid: map['dispatched_by_uid'],
      dispatchedByUsername: map['dispatched_by_username'],
      message: map['message'],
      snapshotJson: map['snapshot_json'],
      dispatchedAt: map['dispatched_at'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    dispatchSessionId,
    saleFolio,
    type,
    dispatchedGarzaNumber,
    litersDispensed,
    dispatchedByUid,
    dispatchedByUsername,
    message,
    snapshotJson,
    dispatchedAt,
  ];
}
