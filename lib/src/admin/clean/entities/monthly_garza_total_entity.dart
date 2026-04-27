import 'package:equatable/equatable.dart';

class MonthlyGarzaTotalEntity extends Equatable {

  DateTime monthStart;
  DateTime monthEnd;
  List<GarzaTotalEntity> totals;

  MonthlyGarzaTotalEntity({
    required this.monthStart,
    required this.monthEnd,
    required this.totals
  });

  factory MonthlyGarzaTotalEntity.fromMap(Map<String, dynamic> data) {
    final summaries = (data["summaries"] as List<dynamic>).map((e) => GarzaTotalEntity.fromMap(e as Map<String, dynamic>),).toList();
    return MonthlyGarzaTotalEntity(
      monthStart: DateTime.parse(data["month_start"]),
      monthEnd: DateTime.parse(data["month_end"]),
      totals: summaries,
    );
  }

  @override
  List<Object?> get props => [monthStart, monthEnd, totals];

}


class GarzaTotalEntity extends Equatable {

  int garzaNumber;
  String garzaTitle;
  double totalAmount;
  double totalLiters;
  int salesCount;

  GarzaTotalEntity({
    required this.garzaNumber,
    required this.garzaTitle,
    required this.totalAmount,
    required this.totalLiters,
    required this.salesCount
  });

  factory GarzaTotalEntity.fromMap(Map<String, dynamic> data) {
    return GarzaTotalEntity(
        garzaNumber: data["garza_number"],
        garzaTitle: data["garza_title"],
        totalAmount: (data["total_amount"] as num).toDouble(),
        totalLiters: (data["total_liters"] as num).toDouble(),
        salesCount: data["sales_count"],
    );
  }

  @override
  List<Object?> get props => [garzaNumber, garzaTitle, totalAmount, totalLiters, salesCount];

}

