import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

import '../../../admin/clean/widgets/config_garza_container.dart';

class SaleInfoDto extends Equatable {
  final int? clientId;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;
  final double quantity;
  final PaymentMethod paymentMethod;
  final double amountPaid; // Para guardar dato de la venta
  final double changeAmount; // Para guardar dato de la venta

  const SaleInfoDto._({
    required this.clientId,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.quantity,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
  });

  factory SaleInfoDto({
    int? clientId,
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

    if (paymentMethod != PaymentMethod.cash) {
      amountPaid = 0;
      changeAmount = 0;
    }

    if (amountPaid == null) {
      throw AppException(message: "El dinero del cliente es obligatorio");
    }

    if (paymentMethod == PaymentMethod.cash && changeAmount == null) {
      throw AppException(message: "El cambio restante es obligatorio");
    }

    return SaleInfoDto._(
      clientId: clientId,
      waterType: waterType,
      unitOfMeasurement: unitOfMeasurement,
      quantity: quantity,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: changeAmount ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      "water_type": waterType.name,
      "unit_of_measurement": unitOfMeasurement.name,
      "quantity": quantity,
      "payment_method": paymentMethod.name,
      "amount_paid": amountPaid,
      "change_amount": changeAmount,
    };

    if (clientId != null) body["client_id"] = clientId;

    return body;
  }

  @override
  List<Object?> get props => [quantity, waterType, paymentMethod, clientId];

  @override
  String toString() => toJson().toString();
}
