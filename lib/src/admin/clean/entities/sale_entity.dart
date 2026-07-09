import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class SaleEntity extends Equatable {
  final String folio;
  final String dispatchCode;
  final int cashCutId;
  final String sellerUid;
  final String sellerUsername;
  final int? clientId;
  final String? commercialName;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;
  final double quantity;
  final double unitPrice;
  final double total;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final double changeAmount;
  final bool isDispatched;
  final DateTime createdAt;
  final double pendingAmount;
  final bool isPaid;
  final String? paidAt;
  final String? paidByUid;
  final String? paidByUsername;
  final double totalLiters;
  final double dispatchedLiters;
  final double remainingLiters;
  final int dispatchDurationMS;

  const SaleEntity({
    required this.folio,
    required this.dispatchCode,
    required this.cashCutId,
    required this.sellerUid,
    required this.sellerUsername,
    required this.clientId,
    required this.commercialName,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
    required this.isDispatched,
    required this.createdAt,
    required this.pendingAmount,
    required this.isPaid,
    required this.paidAt,
    required this.paidByUid,
    required this.paidByUsername,
    required this.totalLiters,
    required this.dispatchedLiters,
    required this.remainingLiters,
    required this.dispatchDurationMS
  });

  factory SaleEntity.fromMap(Map<String, dynamic> data) {
    return SaleEntity(
      folio: data["folio"],
      dispatchCode: data["dispatch_code"],
      cashCutId: data["cash_cut_id"],
      sellerUid: data["seller_uid"],
      sellerUsername: data["seller_username"],
      clientId: data["client_id"],
      commercialName: data["commercial_name"],
      waterType: WaterType.fromString(data["water_type"]),
      unitOfMeasurement: UnitOfMeasurement.fromString(data["unit_of_measurement"],),
      quantity: data["quantity"],
      unitPrice: data["unit_price"],
      total: data["total"],
      paymentMethod: PaymentMethod.fromString(data["payment_method"]),
      amountPaid: data["amount_paid"],
      changeAmount: data["change_amount"],
      isDispatched: data["is_dispatched"],
      createdAt: DateTime.parse(data["created_at"]).toLocal(),
      pendingAmount: data["pending_amount"],
      isPaid: data["is_paid"],
      paidAt: data["paid_at"],
      paidByUid: data["paid_by_uid"],
      paidByUsername: data["paid_by_username"],
      totalLiters: data["total_liters"],
      dispatchedLiters: data["dispatched_liters"],
      remainingLiters: data["remaining_liters"],
      dispatchDurationMS: data["dispatch_duration_ms"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "folio": folio,
      "dispatch_code": dispatchCode,
      "cash_cut_id": cashCutId,
      "seller_uid": sellerUid,
      "seller_username": sellerUsername,
      "client_id": clientId,
      "commercial_name": commercialName,
      "water_type": waterType,
      "unit_of_measurement": unitOfMeasurement,
      "quantity": quantity,
      "unit_price": unitPrice,
      "total": total,
      "payment_method": paymentMethod,
      "amount_paid": amountPaid,
      "change_amount": changeAmount,
      "is_dispatched": isDispatched,
      "created_at": createdAt,
      "pending_amount": pendingAmount,
      "is_paid": isPaid,
      "paid_at": paidAt,
      "paid_by_uid": paidByUid,
      "paid_by_username": paidByUsername,
      "total_liters": totalLiters,
      "dispatched_liters": dispatchedLiters,
      "remaining_liters": remainingLiters,
      "dispatch_duration_ms": dispatchDurationMS
    };
  }

  @override
  List<Object?> get props => [
    folio,
    dispatchCode,
    sellerUid,
    isDispatched,
    totalLiters,
    dispatchedLiters,
    remainingLiters,
  ];
}
