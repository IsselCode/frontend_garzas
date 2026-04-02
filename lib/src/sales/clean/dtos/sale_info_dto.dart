import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

import '../../../admin/clean/widgets/config_garza_container.dart';

class SaleInfoDto extends Equatable {

  final String? customerPhone;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;
  final double quantity;
  final PaymentMethod paymentMethod;
  final double amountPaid; // Para guardar dato de la venta
  final double changeAmount; // Para guardar dato de la venta

  const SaleInfoDto._({
    required this.customerPhone,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.quantity,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
  });

  factory SaleInfoDto({
    String? customerPhone,
    required WaterType? waterType,
    required UnitOfMeasurement? unitOfMeasurement,
    required double? quantity,
    required PaymentMethod? paymentMethod,
    required double? amountPaid,
    required double? changeAmount,
  }) {

    if (waterType == null) {
      throw AppException(message: "El tipo de agua es obligatorio");
    }

    if (unitOfMeasurement == null) {
      throw AppException(message: "El tipo de unidad es obligatorio");
    }

    if (quantity == null) {
      throw AppException(message: "La cantidad es obligatoria");
    }

    if (paymentMethod == null) {
      throw AppException(message: "El tipo de pago es obligatorio");
    }

    if (paymentMethod == PaymentMethod.card) {
      amountPaid = 0;
    }

    if (amountPaid == null) {
      throw AppException(message: "El dinero del cliente es obligatorio");
    }

    if (changeAmount == null) {
      throw AppException(message: "El cambio restante es obligatorio");
    }

    return SaleInfoDto._(
      customerPhone: customerPhone,
      waterType: waterType,
      unitOfMeasurement: unitOfMeasurement,
      quantity: quantity,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: changeAmount
    );
  }

  Map<String, dynamic> toJson() {

    Map<String, dynamic> body = {
      "water_type": waterType.name,
      "unit_of_measurement": unitOfMeasurement.name,
      "quantity": quantity,
      "payment_method": paymentMethod.name,
      "amount_paid": amountPaid,
      "change_amount": changeAmount
    };

    if (customerPhone != null) body["client_phone"] = customerPhone;

    return body;
  }

  @override
  List<Object?> get props => [quantity, waterType, paymentMethod, customerPhone];

  @override
  String toString() => toJson().toString();

}
