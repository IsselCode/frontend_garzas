import 'package:equatable/equatable.dart';

class StatisticsEntity extends Equatable {

  DateTime monthStart;
  DateTime monthEnd;
  double cashTotal;
  double cardTotal;
  double checkTotal;

  StatisticsEntity({
    required this.monthStart,
    required this.monthEnd,
    required this.cashTotal,
    required this.cardTotal,
    required this.checkTotal
  });

  factory StatisticsEntity.fromMap(Map<String, dynamic> data) {
    return StatisticsEntity(
      monthStart: DateTime.parse(data["month_start"]),
      monthEnd: DateTime.parse(data["month_end"]),
      cashTotal: data["cash_total"],
      cardTotal: data["card_total"],
      checkTotal: data["check_total"]
    );
  }

  @override
  List<Object?> get props => [monthStart, monthEnd, cashTotal, cardTotal, checkTotal];

}