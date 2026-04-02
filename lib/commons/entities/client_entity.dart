import 'package:equatable/equatable.dart';

import '../../src/admin/clean/enums/enums.dart';

class ClientEntity extends Equatable {

  final String name;
  final String phone;
  final double potableGalPricing;
  final double potableM3Pricing;
  final double pozoGalPricing;
  final double pozoM3Pricing;
  final DateTime createdAt;

  ClientEntity({
    required this.name,
    required this.phone,
    required this.potableGalPricing,
    required this.potableM3Pricing,
    required this.pozoGalPricing,
    required this.pozoM3Pricing,
    required this.createdAt
  });

  factory ClientEntity.fromMap(Map<String, dynamic> map) {
    return ClientEntity(
      name: map["name"],
      phone: map["phone"],
      potableGalPricing: map["potable_gal_pricing"],
      potableM3Pricing: map["potable_m3_pricing"],
      pozoGalPricing: map["pozo_gal_pricing"],
      pozoM3Pricing: map["pozo_m3_pricing"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }

  @override
  List<Object?> get props => [name, phone];

}