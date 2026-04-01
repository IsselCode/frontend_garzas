import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class DispatchValidateEntity extends Equatable {

  String dispatchCode;
  String folio;
  DispatchStatus dispatchStatus;
  bool isDispatched;
  bool canDispatched;
  WaterType waterType;
  double quantity;
  UnitOfMeasurement unitOfMeasurement;

  DispatchValidateEntity({
    required this.dispatchCode,
    required this.folio,
    required this.dispatchStatus,
    required this.isDispatched,
    required this.canDispatched,
    required this.waterType,
    required this.quantity,
    required this.unitOfMeasurement,
  });

  factory DispatchValidateEntity.fromMap(Map<String, dynamic> map) {
    return DispatchValidateEntity(
      dispatchCode: map["dispatch_code"],
      folio: map["folio"],
      dispatchStatus: DispatchStatus.fromString(map["dispatch_status"]),
      isDispatched: map["is_dispatched"],
      canDispatched: map["can_dispatch"],
      quantity: map["quantity"],
      waterType: WaterType.fromString(map["water_type"]),
      unitOfMeasurement: UnitOfMeasurement.fromString(map["unit_of_measurement"])
    );
  }

  @override
  List<Object?> get props => [dispatchCode, folio, dispatchStatus, isDispatched, canDispatched, waterType, quantity, unitOfMeasurement];

}