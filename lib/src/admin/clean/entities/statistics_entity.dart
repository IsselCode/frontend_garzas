import 'package:equatable/equatable.dart';

class StatisticsEntity extends Equatable {

  DateTime monthStart;
  DateTime monthEnd;
  double cashTotal;
  double cashLiters;
  double cardTotal;
  double cardLiters;
  double creditTotal;
  double creditLiters;

  StatisticsEntity({
    required this.monthStart,
    required this.monthEnd,
    required this.cashTotal,
    required this.cashLiters,
    required this.cardTotal,
    required this.cardLiters,
    required this.creditTotal,
    required this.creditLiters
  });

  factory StatisticsEntity.fromMap(Map<String, dynamic> data) {
    return StatisticsEntity(
      monthStart: DateTime.parse(data["month_start"]),
      monthEnd: DateTime.parse(data["month_end"]),
      cashTotal: data["cash_total"],
      cashLiters: data["cash_liters"],
      cardTotal: data["card_total"],
      cardLiters: data["card_liters"],
      creditTotal: data["credit_total"],
      creditLiters: data["credit_liters"]
    );
  }

  @override
  List<Object?> get props => [monthStart, monthEnd, cashTotal, cashLiters, cardTotal, cardLiters, creditTotal, creditLiters];

}