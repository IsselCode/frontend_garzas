import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/sales/clean/enums/enums.dart';

class SaleInfoDto extends Equatable {

  final double quantity;
  final WaterType waterType;
  final double estimateTotal; // Validar con el backend nuevamente los precios
  final double clientMoney; // Para guardar dato de la venta
  final double totalRemaining; // Para guardar dato de la venta

  SaleInfoDto({
    required this.quantity,
    required this.waterType,
    required this.estimateTotal,
    required this.clientMoney,
    required this.totalRemaining,
  });

  Map<String, dynamic> toJson() {
    return {
      "quantity": quantity,
      "water_type": waterType.name,
      "estimate_total": estimateTotal,
      "client_money": clientMoney,
      "total_remaining": totalRemaining
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [quantity, waterType, estimateTotal, clientMoney, totalRemaining];

  @override
  String toString() => toJson().toString();

}