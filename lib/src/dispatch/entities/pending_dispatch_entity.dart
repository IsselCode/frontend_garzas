import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

enum PendingDispatchStatus {
  pendingDispatch(label: 'Pendiente'),
  pendingPayment(label: 'Pendiente de pago'),
  dispatched(label: 'Despachado'),
  cancelled(label: 'Cancelado'),
  settled(label: 'Pagado');

  final String label;

  const PendingDispatchStatus({required this.label});

  static PendingDispatchStatus fromString(String value) {
    switch (value) {
      case 'pending_dispatch':
        return PendingDispatchStatus.pendingDispatch;
      case 'pending_payment':
        return PendingDispatchStatus.pendingPayment;
      case 'dispatched':
        return PendingDispatchStatus.dispatched;
      case 'cancelled':
        return PendingDispatchStatus.cancelled;
      case 'paid':
        return PendingDispatchStatus.settled;
      default:
        return PendingDispatchStatus.pendingDispatch;
    }
  }
}

class PendingDispatchEntity extends Equatable {
  final int id;
  final String plateOrUnitReference;
  final int garzaNumber;
  final String? operatorUid;
  final String? operatorUsername;
  final String? customerEmployeeName;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;
  final double? quantity;
  final PendingDispatchStatus status;
  final String? saleFolio;
  final double dispensedVolume;
  final double remainingVolume;
  final double totalLiters;
  final double dispensedLiters;
  final double remainingLiters;
  final String createdAt;
  final String updatedAt;
  final String? paidAt;

  const PendingDispatchEntity({
    required this.id,
    required this.plateOrUnitReference,
    required this.garzaNumber,
    required this.operatorUid,
    required this.operatorUsername,
    required this.customerEmployeeName,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.quantity,
    required this.status,
    required this.saleFolio,
    required this.dispensedVolume,
    required this.remainingVolume,
    required this.totalLiters,
    required this.dispensedLiters,
    required this.remainingLiters,
    required this.createdAt,
    required this.updatedAt,
    required this.paidAt,
  });

  factory PendingDispatchEntity.fromMap(Map<String, dynamic> map) {
    return PendingDispatchEntity(
      id: map['id'],
      plateOrUnitReference: map['plate_or_unit_reference'],
      garzaNumber: map['garza_number'],
      operatorUid: map['operator_uid'],
      operatorUsername: map['operator_username'],
      customerEmployeeName: map['customer_employee_name'],
      waterType: WaterType.fromString(map['water_type']),
      unitOfMeasurement: UnitOfMeasurement.fromString(
        map['unit_of_measurement'],
      ),
      quantity: _optionalDouble(map['quantity']),
      status: PendingDispatchStatus.fromString(map['status']),
      saleFolio: map['sale_folio'],
      dispensedVolume: _doubleOrZero(map['dispensed_volume']),
      remainingVolume: _doubleOrZero(map['remaining_volume']),
      totalLiters: _doubleOrZero(map['total_liters']),
      dispensedLiters: _doubleOrZero(map['dispensed_liters']),
      remainingLiters: _doubleOrZero(map['remaining_liters']),
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      paidAt: map['paid_at'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    plateOrUnitReference,
    garzaNumber,
    operatorUid,
    operatorUsername,
    customerEmployeeName,
    waterType,
    unitOfMeasurement,
    quantity,
    status,
    saleFolio,
    dispensedVolume,
    remainingVolume,
    totalLiters,
    dispensedLiters,
    remainingLiters,
    createdAt,
    updatedAt,
    paidAt,
  ];
}

double? _optionalDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

double _doubleOrZero(dynamic value) {
  return _optionalDouble(value) ?? 0;
}
