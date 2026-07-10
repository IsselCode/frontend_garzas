import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class ClosedCutSaleEntity extends Equatable {
  final String folio;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;
  final double quantity;
  final PaymentMethod paymentMethod;
  final double total;

  const ClosedCutSaleEntity({
    required this.folio,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.quantity,
    required this.paymentMethod,
    required this.total,
  });

  factory ClosedCutSaleEntity.fromMap(Map<String, dynamic> map) {
    return ClosedCutSaleEntity(
      folio: map["folio"],
      waterType: WaterType.fromString(map["water_type"]),
      unitOfMeasurement: UnitOfMeasurement.fromString(
        map["unit_of_measurement"],
      ),
      quantity: (map["quantity"] as num).toDouble(),
      paymentMethod: PaymentMethod.fromString(map["payment_method"]),
      total: (map["total"] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    folio,
    waterType,
    unitOfMeasurement,
    quantity,
    paymentMethod,
    total,
  ];
}

class ClosedCutSummaryEntity extends Equatable {
  final double openingAmount;
  final double cashTotal;
  final double cardTotal;
  final double creditTotal;
  final double expectedCashTotal;
  final int salesCount;
  final int cashSalesCount;
  final int cardSalesCount;
  final int creditSalesCount;
  final double totalLitersSold;
  final List<ClosedCutSaleEntity> sales;

  const ClosedCutSummaryEntity({
    required this.openingAmount,
    required this.cashTotal,
    required this.cardTotal,
    required this.creditTotal,
    required this.expectedCashTotal,
    required this.salesCount,
    required this.cashSalesCount,
    required this.cardSalesCount,
    required this.creditSalesCount,
    required this.totalLitersSold,
    required this.sales,
  });

  factory ClosedCutSummaryEntity.fromMap(Map<String, dynamic> map) {
    final sales = (map["sales"] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ClosedCutSaleEntity.fromMap)
        .toList(growable: false);

    return ClosedCutSummaryEntity(
      openingAmount: (map["opening_amount"] as num).toDouble(),
      cashTotal: (map["cash_total"] as num).toDouble(),
      cardTotal: (map["card_total"] as num).toDouble(),
      creditTotal: (map["credit_total"] as num).toDouble(),
      expectedCashTotal: (map["expected_cash_total"] as num).toDouble(),
      salesCount: (map["sales_count"] as num).toInt(),
      cashSalesCount: (map["cash_sales_count"] as num).toInt(),
      cardSalesCount: (map["card_sales_count"] as num).toInt(),
      creditSalesCount: (map["credit_sales_count"] as num).toInt(),
      totalLitersSold: (map["total_liters_sold"] as num).toDouble(),
      sales: sales,
    );
  }

  @override
  List<Object?> get props => [
    openingAmount,
    cashTotal,
    cardTotal,
    creditTotal,
    expectedCashTotal,
    salesCount,
    cashSalesCount,
    cardSalesCount,
    creditSalesCount,
    totalLitersSold,
    sales,
  ];
}
