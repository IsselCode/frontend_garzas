import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/sales/clean/enums/enums.dart';

class SaleInfoDto extends Equatable {

  final double quantity;
  final WaterType waterType;
  final double estimateTotal; // Validar con el backend nuevamente los precios
  final double clientMoney; // Para guardar dato de la venta
  final double totalRemaining; // Para guardar dato de la venta
  final int? customerPhone;

  const SaleInfoDto._({
    required this.quantity,
    required this.waterType,
    required this.estimateTotal,
    required this.clientMoney,
    required this.totalRemaining,
    required this.customerPhone,
  });

  factory SaleInfoDto({
    required double? quantity,
    required WaterType? waterType,
    required double? estimateTotal,
    required double? clientMoney,
    required double? totalRemaining,
    int? customerPhone,
  }) {
    if (quantity == null) {
      throw AppException(message: "La cantidad es obligatoria");
    }

    if (waterType == null) {
      throw AppException(message: "El tipo de agua es obligatorio");
    }

    if (estimateTotal == null) {
      throw AppException(message: "El total estimado es obligatorio");
    }

    if (clientMoney == null) {
      throw AppException(message: "El dinero del cliente es obligatorio");
    }

    if (totalRemaining == null) {
      throw AppException(message: "El cambio restante es obligatorio");
    }

    return SaleInfoDto._(
      quantity: quantity,
      waterType: waterType,
      estimateTotal: estimateTotal,
      clientMoney: clientMoney,
      totalRemaining: totalRemaining,
      customerPhone: customerPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "quantity": quantity,
      "water_type": waterType.name,
      "estimate_total": estimateTotal,
      "client_money": clientMoney,
      "total_remaining": totalRemaining,
      "customer_phone": customerPhone,
    };
  }

  @override
  List<Object?> get props => [quantity, waterType, estimateTotal, clientMoney, totalRemaining, customerPhone];

  @override
  String toString() => toJson().toString();

}
