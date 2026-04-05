import 'package:equatable/equatable.dart';

class ActiveCutSummaryEntity extends Equatable {

  double openingAmount;
  double cashTotal;
  double cardTotal;
  double expectedCashTotal;

  ActiveCutSummaryEntity({
    required this.openingAmount,
    required this.cashTotal,
    required this.cardTotal,
    required this.expectedCashTotal
  });

  factory ActiveCutSummaryEntity.fromMap(Map<String, dynamic> map) {
    return ActiveCutSummaryEntity(
      openingAmount: map["opening_amount"],
      cashTotal: map["cash_total"],
      cardTotal: map["card_total"],
      expectedCashTotal: map["expected_cash_total"]
    );
  }

  @override
  List<Object?> get props => [openingAmount, cashTotal, cardTotal, expectedCashTotal];

}