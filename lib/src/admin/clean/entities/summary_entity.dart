import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

int _getValue(PaymentMethod method, WaterType water) {
  switch (method) {
    case PaymentMethod.cash:
      switch (water) {
        case WaterType.potable:
          return 1;
        case WaterType.pozo:
          return 2;
      }
    case PaymentMethod.card:
      switch (water) {
        case WaterType.potable:
          return 3;
        case WaterType.pozo:
          return 4;
      }
    case PaymentMethod.credit:
      switch (water) {
        case WaterType.potable:
          return 5;
        case WaterType.pozo:
          return 6;
      }
  }
}

class SummaryEntity extends Equatable {

  PaymentMethod paymentMethod;
  WaterType waterType;
  double totalAmount;
  double totalLiters;
  int salesCount;
  int value;

  SummaryEntity({
    required this.paymentMethod,
    required this.waterType,
    required this.totalLiters,
    required this.totalAmount,
    required this.salesCount,
    required this.value,
  });

  factory SummaryEntity.fromMap(Map<String, dynamic> map) {
    PaymentMethod paymentMethod = PaymentMethod.fromString(map["payment_method"]);
    WaterType waterType = WaterType.fromString(map["water_type"]);
    return SummaryEntity(
      paymentMethod: paymentMethod,
      waterType: waterType,
      totalLiters: map["total_liters"],
      totalAmount: map["total_amount"],
      salesCount: map["sales_count"],
      value: _getValue(paymentMethod, waterType)
    );
  }

  @override
  List<Object?> get props => throw UnimplementedError();

}