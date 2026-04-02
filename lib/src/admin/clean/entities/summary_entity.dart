import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

int _getValue(PaymentMethod method, WaterType water, UnitOfMeasurement unit) {
  switch (method) {
    case PaymentMethod.cash:
      switch (water) {
        case WaterType.potable:
          switch (unit) {
            case UnitOfMeasurement.cubic_meters:
              return 1;
            case UnitOfMeasurement.gallons:
              return 2;
          }
        case WaterType.pozo:
          switch (unit) {
            case UnitOfMeasurement.cubic_meters:
              return 3;
            case UnitOfMeasurement.gallons:
              return 4;
          }
      }
    case PaymentMethod.card:
      switch (water) {
        case WaterType.potable:
          switch (unit) {
            case UnitOfMeasurement.cubic_meters:
              return 5;
            case UnitOfMeasurement.gallons:
              return 6;
          }
        case WaterType.pozo:
          switch (unit) {
            case UnitOfMeasurement.cubic_meters:
              return 7;
            case UnitOfMeasurement.gallons:
              return 8;
          }
      }
    case PaymentMethod.credit:
      switch (water) {
        case WaterType.potable:
          switch (unit) {
            case UnitOfMeasurement.cubic_meters:
              return 9;
            case UnitOfMeasurement.gallons:
              return 10;
          }
        case WaterType.pozo:
          switch (unit) {
            case UnitOfMeasurement.cubic_meters:
              return 11;
            case UnitOfMeasurement.gallons:
              return 12;
          }
      }
  }
}

class SummaryEntity extends Equatable {

  PaymentMethod paymentMethod;
  WaterType waterType;
  UnitOfMeasurement unitOfMeasurement;
  double totalAmount;
  int salesCount;
  int value;

  SummaryEntity({
    required this.paymentMethod,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.totalAmount,
    required this.salesCount,
    required this.value,
  });

  factory SummaryEntity.fromMap(Map<String, dynamic> map) {
    PaymentMethod paymentMethod = PaymentMethod.fromString(map["payment_method"]);
    WaterType waterType = WaterType.fromString(map["water_type"]);
    UnitOfMeasurement unitOfMeasurement = UnitOfMeasurement.fromString(map["unit_of_measurement"]);
    return SummaryEntity(
      paymentMethod: paymentMethod,
      waterType: waterType,
      unitOfMeasurement: unitOfMeasurement,
      totalAmount: map["total_amount"],
      salesCount: map["sales_count"],
      value: _getValue(paymentMethod, waterType, unitOfMeasurement)
    );
  }

  @override
  List<Object?> get props => throw UnimplementedError();

}