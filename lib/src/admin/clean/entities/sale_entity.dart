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
  DispatchStatus dispatchStatus;
  String? dispatchedAt;
  String? dispatchedByUid;
  String? dispatchedByUsername;
  DateTime createdAt;

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
    required this.dispatchStatus,
    required this.dispatchedAt,
    required this.dispatchedByUid,
    required this.dispatchedByUsername,
    required this.createdAt,
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
      unitOfMeasurement: UnitOfMeasurement.fromString(data["unit_of_measurement"]),
      quantity: data["quantity"],
      unitPrice: data["unit_price"],
      total: data["total"],
      paymentMethod: PaymentMethod.fromString(data["payment_method"]),
      amountPaid: data["amount_paid"],
      changeAmount: data["change_amount"],
      isDispatched: data["is_dispatched"],
      dispatchStatus: DispatchStatus.fromString(data["dispatch_status"]),
      dispatchedAt: data["dispatched_at"],
      dispatchedByUid: data["dispatched_by_uid"],
      dispatchedByUsername: data["dispatched_by_username"],
      createdAt: DateTime.parse(data["created_at"])
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
      "dispatch_status": dispatchStatus,
      "dispatched_at": dispatchedAt,
      "dispatched_by_uid": dispatchedByUid,
      "dispatched_by_username": dispatchedByUsername,
      "created_at": createdAt,
    };
  }

  @override
  List<Object?> get props => [folio, dispatchCode, sellerUid, dispatchedByUid, isDispatched, dispatchStatus];

}