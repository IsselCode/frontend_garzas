import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class SaleEntity extends Equatable {
  String folio;
  String dispatchCode;
  int cashCutId;
  String sellerUid;
  String sellerUsername;
  String? clientPhone;
  String? clientName;
  WaterType waterType;
  UnitOfMeasurement unitOfMeasurement;
  double quantity;
  double unitPrice;
  double total;
  PaymentMethod paymentMethod;
  double amountPaid;
  double changeAmount;
  bool isDispatched;
  DateTime createdAt;
  double pendingAmount;
  bool isPaid;
  String? paidAt;
  String? paidByUid;
  String? paidByUsername;
  double totalLiters;
  double dispatchedLiters;
  double remainingLiters;

  SaleEntity({
    required this.folio,
    required this.dispatchCode,
    required this.cashCutId,
    required this.sellerUid,
    required this.sellerUsername,
    required this.clientPhone,
    required this.clientName,
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
  });

  factory SaleEntity.fromMap(Map<String, dynamic> data) {
    return SaleEntity(
      folio: data["folio"],
      dispatchCode: data["dispatch_code"],
      cashCutId: data["cash_cut_id"],
      sellerUid: data["seller_uid"],
      sellerUsername: data["seller_username"],
      clientPhone: data["client_phone"],
      clientName: data["client_name"],
      waterType: WaterType.fromString(data["water_type"]),
      unitOfMeasurement: UnitOfMeasurement.fromString(
        data["unit_of_measurement"],
      ),
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "folio": folio,
      "dispatch_code": dispatchCode,
      "cash_cut_id": cashCutId,
      "seller_uid": sellerUid,
      "seller_username": sellerUsername,
      "client_phone": clientPhone,
      "client_name": clientName,
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
