import 'package:equatable/equatable.dart';

import '../../src/admin/clean/enums/enums.dart';

class ClientEntity extends Equatable {

  final String name;
  final String phone;
  final double potableGalPricing;
  final double potableLiterPricing;
  final double pozoGalPricing;
  final double pozoLiterPricing;
  final DateTime createdAt;

  ClientEntity({
    required this.name,
    required this.phone,
    required this.potableGalPricing,
    required this.potableLiterPricing,
    required this.pozoGalPricing,
    required this.pozoLiterPricing,
    required this.createdAt
  });

  factory ClientEntity.fromMap(Map<String, dynamic> map) {
    return ClientEntity(
      name: map["name"],
      phone: map["phone"],
      potableGalPricing: map["potable_gal_pricing"],
      potableLiterPricing: map["potable_liter_pricing"],
      pozoGalPricing: map["pozo_gal_pricing"],
      pozoLiterPricing: map["pozo_liter_pricing"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }

  @override
  List<Object?> get props => [name, phone];

}