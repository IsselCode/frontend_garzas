import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

class CreditPaymentEntity extends Equatable {
  final String saleFolio;
  final int clientId;
  final String commercialName;
  final int cashCutId;
  final String receivedByUid;
  final String receivedByUsername;
  final PaymentMethod paymentMethod;
  final double amount;
  final DateTime createdAt;

  const CreditPaymentEntity({
    required this.saleFolio,
    required this.clientId,
    required this.commercialName,
    required this.cashCutId,
    required this.receivedByUid,
    required this.receivedByUsername,
    required this.paymentMethod,
    required this.amount,
    required this.createdAt,
  });

  factory CreditPaymentEntity.fromMap(Map<String, dynamic> map) {
    return CreditPaymentEntity(
      saleFolio: map["sale_folio"],
      clientId: map["client_id"],
      commercialName: map["commercial_name"],
      cashCutId: map["cash_cut_id"],
      receivedByUid: map["received_by_uid"],
      receivedByUsername: map["received_by_username"],
      paymentMethod: PaymentMethod.fromString(map["payment_method"]),
      amount: map["amount"],
      createdAt: DateTime.parse(map["created_at"]).toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    saleFolio,
    clientId,
    commercialName,
    cashCutId,
    receivedByUid,
    receivedByUsername,
    paymentMethod,
    amount,
    createdAt,
  ];
}
