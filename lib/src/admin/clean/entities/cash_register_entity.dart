

import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

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
  double? declaredCreditTotal;

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
    required this.creditTotal,
    required this.declaredCashTotal,
    required this.declaredCardTotal,
    required this.declaredCreditTotal,
  });

  factory CashRegisterEntity.fromMap(Map<String, dynamic> data) {
    return CashRegisterEntity(
      id: data["id"],
      openedByUid: data["opened_by_uid"],
      openedByUsername: data["opened_by_username"],
      openingAmount: data["opening_amount"],
      openedAt: DateTime.parse(data["opened_at"]),
      closedByUid: data["closed_by_uid"],
      closedByUsername: data["closed_by_username"],
      closedAt: data["closed_at"] != null ? DateTime.parse(data["closed_at"]) : null,
      status: CashRegisterStatus.fromString(data["status"]),
      cashTotal: data["cash_total"],
      cardTotal: data["card_total"],
      creditTotal: data["credit_total"],
      declaredCashTotal: data["declared_cash_total"],
      declaredCardTotal: data["declared_card_total"],
      declaredCreditTotal: data["declared_credit_total"],
    );
  }

  @override
  List<Object?> get props => [id, openedByUid, closedByUid, cashTotal, cardTotal, creditTotal];

}