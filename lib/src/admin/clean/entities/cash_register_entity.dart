import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/sales/clean/entities/closed_cut_summary_entity.dart';

class CashRegisterEntity extends Equatable {
  int id;
  String openedByUid;
  String openedByUsername;
  double openingAmount;
  DateTime openedAt;
  String? closedByUid;
  String? closedByUsername;
  DateTime? closedAt;
  CashRegisterStatus status;
  double cashTotal;
  double cardTotal;
  double creditTotal;
  double? declaredCashTotal;
  double? declaredCardTotal;
  double expectedCashTotal;
  int salesCount;
  int cashSalesCount;
  int cardSalesCount;
  int creditSalesCount;
  double totalLitersSold;
  LitersSoldByWaterTypeEntity litersSoldByWaterType;

  CashRegisterEntity({
    required this.id,
    required this.openedByUid,
    required this.openedByUsername,
    required this.openingAmount,
    required this.openedAt,
    required this.closedByUid,
    required this.closedByUsername,
    required this.closedAt,
    required this.status,
    required this.cashTotal,
    required this.cardTotal,
    this.creditTotal = 0,
    required this.declaredCashTotal,
    required this.declaredCardTotal,
    this.expectedCashTotal = 0,
    this.salesCount = 0,
    this.cashSalesCount = 0,
    this.cardSalesCount = 0,
    this.creditSalesCount = 0,
    this.totalLitersSold = 0,
    this.litersSoldByWaterType = const LitersSoldByWaterTypeEntity(),
  });

  factory CashRegisterEntity.fromMap(Map<String, dynamic> data) {
    return CashRegisterEntity(
      id: data["id"],
      openedByUid: data["opened_by_uid"],
      openedByUsername: data["opened_by_username"],
      openingAmount: (data["opening_amount"] as num).toDouble(),
      openedAt: DateTime.parse(data["opened_at"]).toLocal(),
      closedByUid: data["closed_by_uid"],
      closedByUsername: data["closed_by_username"],
      closedAt: data["closed_at"] != null
          ? DateTime.parse(data["closed_at"]).toLocal()
          : null,
      status: CashRegisterStatus.fromString(data["status"]),
      cashTotal: (data["cash_total"] as num).toDouble(),
      cardTotal: (data["card_total"] as num).toDouble(),
      creditTotal: (data["credit_total"] as num?)?.toDouble() ?? 0,
      declaredCashTotal: (data["declared_cash_total"] as num?)?.toDouble(),
      declaredCardTotal: (data["declared_card_total"] as num?)?.toDouble(),
      expectedCashTotal: (data["expected_cash_total"] as num?)?.toDouble() ?? 0,
      salesCount: (data["sales_count"] as num?)?.toInt() ?? 0,
      cashSalesCount: (data["cash_sales_count"] as num?)?.toInt() ?? 0,
      cardSalesCount: (data["card_sales_count"] as num?)?.toInt() ?? 0,
      creditSalesCount: (data["credit_sales_count"] as num?)?.toInt() ?? 0,
      totalLitersSold: (data["total_liters_sold"] as num?)?.toDouble() ?? 0,
      litersSoldByWaterType: LitersSoldByWaterTypeEntity.fromMap(
        (data["liters_sold_by_water_type"] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    openedByUid,
    openedByUsername,
    openingAmount,
    openedAt,
    closedByUid,
    closedByUsername,
    closedAt,
    status,
    cashTotal,
    cardTotal,
    creditTotal,
    declaredCashTotal,
    declaredCardTotal,
    expectedCashTotal,
    salesCount,
    cashSalesCount,
    cardSalesCount,
    creditSalesCount,
    totalLitersSold,
    litersSoldByWaterType,
  ];
}
