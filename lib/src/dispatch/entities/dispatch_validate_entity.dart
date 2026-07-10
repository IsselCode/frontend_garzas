import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class DispatchValidateEntity extends Equatable {
  final String dispatchCode;
  final String folio;
  final bool isDispatched;
  final bool canDispatched;
  final WaterType waterType;
  final double quantity;
  final UnitOfMeasurement unitOfMeasurement;
  final double totalLiters;
  final double dispatchedLiters;
  final double remainingLiters;
  final String? commercialName;

  const DispatchValidateEntity({
    required this.dispatchCode,
    required this.folio,
    required this.isDispatched,
    required this.canDispatched,
    required this.waterType,
    required this.quantity,
    required this.unitOfMeasurement,
    required this.totalLiters,
    required this.dispatchedLiters,
    required this.remainingLiters,
    required this.commercialName,
  });

  factory DispatchValidateEntity.fromMap(Map<String, dynamic> map) {
    return DispatchValidateEntity(
      dispatchCode: map["dispatch_code"],
      folio: map["folio"],
      isDispatched: map["is_dispatched"],
      canDispatched: map["can_dispatch"],
      quantity: (map["quantity"] as num).toDouble(),
      waterType: WaterType.fromString(map["water_type"]),
      unitOfMeasurement: UnitOfMeasurement.fromString(
        map["unit_of_measurement"],
      ),
      totalLiters: (map["total_liters"] as num).toDouble(),
      dispatchedLiters: (map["dispatched_liters"] as num).toDouble(),
      remainingLiters: (map["remaining_liters"] as num).toDouble(),
      commercialName: map["commercial_name"],
    );
  }

  @override
  List<Object?> get props => [
    dispatchCode,
    folio,
    isDispatched,
    canDispatched,
    waterType,
    quantity,
    unitOfMeasurement,
    totalLiters,
    dispatchedLiters,
    remainingLiters,
    commercialName,
  ];
}
