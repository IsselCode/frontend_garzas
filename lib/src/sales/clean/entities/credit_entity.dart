import 'package:equatable/equatable.dart';

class CreditEntity extends Equatable {
  final String saleFolio;
  final int clientId;
  final String commercialName;
  final double total;
  final double amountPaid;
  final double salePendingAmount;
  final DateTime createdAt;

  const CreditEntity({
    required this.saleFolio,
    required this.clientId,
    required this.commercialName,
    required this.total,
    required this.amountPaid,
    required this.salePendingAmount,
    required this.createdAt,
  });

  factory CreditEntity.fromMap(Map<String, dynamic> map) {
    return CreditEntity(
      saleFolio: map["sale_folio"],
      clientId: map["client_id"],
      commercialName: map["commercial_name"],
      total: map["total"],
      amountPaid: map["amount_paid"],
      salePendingAmount: map["sale_pending_amount"],
      createdAt: DateTime.parse(map["created_at"]).toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    saleFolio,
    clientId,
    commercialName,
    total,
    amountPaid,
    salePendingAmount,
    createdAt,
  ];
}
