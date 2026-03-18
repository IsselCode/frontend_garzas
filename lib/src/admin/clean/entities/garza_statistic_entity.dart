import 'package:equatable/equatable.dart';

class GarzaStatisticEntity extends Equatable {

  int numberGarza;
  double liters;
  double gallons;
  double total;

  GarzaStatisticEntity({
    required this.numberGarza,
    required this.liters,
    required this.gallons,
    required this.total
  });

  factory GarzaStatisticEntity.fromMap(Map<String, dynamic> map) {
    return GarzaStatisticEntity(
      numberGarza: map["number_garza"],
      liters: map["liters"],
      gallons: map["gallons"],
      total: map["total"]
    );
  }

  @override
  List<Object?> get props => [numberGarza, liters, gallons, total];

}