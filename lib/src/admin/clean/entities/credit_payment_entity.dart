import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

class CreditPaymentEntity extends Equatable {

  String saleFolio;
  String clientPhone;
  int cashCutId;
  String receivedByUid;
  String receivedByUsername;
  PaymentMethod paymentMethod;
  double amount;
  DateTime createdAt;

  CreditPaymentEntity({
    required this.saleFolio,
    required this.clientPhone,
    required this.cashCutId,
    required this.receivedByUid,
    required this.receivedByUsername,
    required this.paymentMethod,
    required this.amount,
    required this.createdAt
  });

  factory CreditPaymentEntity.fromMap(Map<String, dynamic> map) {
    print(map);
    return CreditPaymentEntity(
      saleFolio: map["sale_folio"],
      clientPhone: map["client_phone"],
      cashCutId: map["cash_cut_id"],
      receivedByUid: map["received_by_uid"],
      receivedByUsername: map["received_by_username"],
      paymentMethod: PaymentMethod.fromString(map["payment_method"]),
      amount: map["amount"],
      createdAt: DateTime.parse(map["created_at"])
    );
  }

  @override
  List<Object?> get props => [saleFolio, clientPhone, cashCutId, receivedByUid, receivedByUsername, paymentMethod, amount, createdAt];

}