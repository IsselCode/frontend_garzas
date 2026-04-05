import 'package:equatable/equatable.dart';

class CreditEntity extends Equatable {

  String saleFolio;
  String clientPhone;
  String clientName;
  double total;
  double amountPaid;
  double salePendingAmount;
  DateTime createdAt;

  CreditEntity({
    required this.saleFolio,
    required this.clientPhone,
    required this.clientName,
    required this.total,
    required this.amountPaid,
    required this.salePendingAmount,
    required this.createdAt
  });

  factory CreditEntity.fromMap(Map<String, dynamic> map) {
    print(map);
    return CreditEntity(
      saleFolio: map["sale_folio"],
      clientPhone: map["client_phone"],
      clientName: map["client_name"],
      total: map["total"],
      amountPaid: map["amount_paid"],
      salePendingAmount: map["sale_pending_amount"],
      createdAt: DateTime.parse(map["created_at"])
    );
  }

  @override
  List<Object?> get props => [saleFolio, clientPhone, clientName, total, amountPaid, salePendingAmount, createdAt];

}