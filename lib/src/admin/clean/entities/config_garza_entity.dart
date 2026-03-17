import 'package:equatable/equatable.dart';

import '../widgets/config_garza_container.dart';

class ConfigGarzaEntity extends Equatable {
  final String title;
  final int number;
  final GarzaType garzaType;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;

  const ConfigGarzaEntity({
    required this.title,
    required this.number,
    required this.garzaType,
    required this.waterType,
    required this.unitOfMeasurement,
  });

  factory ConfigGarzaEntity.fromMap(Map<String, dynamic> map) {
    return ConfigGarzaEntity(
      title: map["title"],
      number: map["number"],
      garzaType: map["garza_type"],
      waterType: map["water_type"],
      unitOfMeasurement: map["unit_of_measurement"],
    );
  }

  ConfigGarzaEntity updated({
    GarzaType? garzaType,
    WaterType? waterType,
    UnitOfMeasurement? unitOfMeasurement,
  }) {
    return ConfigGarzaEntity(
      title: title,
      number: number,
      garzaType: garzaType ?? this.garzaType,
      waterType: waterType ?? this.waterType,
      unitOfMeasurement: unitOfMeasurement ?? this.unitOfMeasurement,
    );
  }

  @override
  List<Object?> get props => [
    title,
    number,
    garzaType,
    waterType,
    unitOfMeasurement,
  ];
}
