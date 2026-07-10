import 'package:equatable/equatable.dart';

class ClientEntity extends Equatable {
  final int id;
  final String commercialName;
  final double potableGalPricing;
  final double potableLiterPricing;
  final double pozoGalPricing;
  final double pozoLiterPricing;
  final double creditLimit;
  final bool creditEnabled;
  final double creditUsed;
  final DateTime createdAt;

  const ClientEntity({
    required this.id,
    required this.commercialName,
    required this.potableGalPricing,
    required this.potableLiterPricing,
    required this.pozoGalPricing,
    required this.pozoLiterPricing,
    required this.creditLimit,
    required this.creditEnabled,
    required this.creditUsed,
    required this.createdAt,
  });

  factory ClientEntity.fromMap(Map<String, dynamic> map) {
    return ClientEntity(
      id: map["id"],
      commercialName: map["commercial_name"],
      potableGalPricing: map["potable_gal_pricing"],
      potableLiterPricing: map["potable_liter_pricing"],
      pozoGalPricing: map["pozo_gal_pricing"],
      pozoLiterPricing: map["pozo_liter_pricing"],
      creditLimit: map["credit_limit"],
      creditEnabled: map["credit_enabled"],
      creditUsed: map["credit_used"],
      createdAt: DateTime.parse(map["created_at"]).toLocal(),
    );
  }

  @override
  List<Object?> get props => [id, commercialName];
}
