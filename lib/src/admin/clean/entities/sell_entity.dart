import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class SellEntity extends Equatable {

  int id;
  int numberGarza;
  String employee;
  double quantity;
  WaterType waterType;
  double total;
  DateTime date;

  SellEntity({
    required this.id,
    required this.numberGarza,
    required this.employee,
    required this.quantity,
    required this.waterType,
    required this.total,
    required this.date
  });

  factory SellEntity.fromMap(Map<String, dynamic> data) {
    return SellEntity(
      id: data["id"],
      numberGarza: data["number_garza"],
      employee: data["employee"],
      quantity: data["quantity"],
      waterType: WaterType.fromString(data["water_type"]),
      total: data["total"],
      date: DateTime.fromMillisecondsSinceEpoch(data["date"], isUtc: true).toLocal()
    );
  }

  @override
  List<Object?> get props => [id, numberGarza, employee, quantity, waterType, total, date];

}