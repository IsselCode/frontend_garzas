import 'package:equatable/equatable.dart';

class GeneralConfigEntity extends Equatable {

  bool waterSupply;
  bool userCreated;
  bool userDeleted;
  bool userModified;
  bool login;
  bool logout;
  bool clientCreated;
  bool clientDeleted;
  bool clientModified;
  bool cashRegisterOpening;
  bool cashRegisterClosing;
  bool saleCreated;
  bool dispatchCompleted;
  String businessName;
  String businessAddress;
  String extraInfo1;
  String extraInfo2;
  double potableM3Pricing;
  double potableGalPricing;
  double pozoM3Pricing;
  double pozoGalPricing;

  GeneralConfigEntity({
    required this.waterSupply,
    required this.userCreated,
    required this.userDeleted,
    required this.userModified,
    required this.login,
    required this.logout,
    required this.clientCreated,
    required this.clientDeleted,
    required this.clientModified,
    required this.cashRegisterOpening,
    required this.cashRegisterClosing,
    required this.saleCreated,
    required this.dispatchCompleted,
    required this.businessName,
    required this.businessAddress,
    required this.extraInfo1,
    required this.extraInfo2,
    required this.potableM3Pricing,
    required this.potableGalPricing,
    required this.pozoM3Pricing,
    required this.pozoGalPricing,
  });

  factory GeneralConfigEntity.fromMap(Map<String, dynamic> map) {
    return GeneralConfigEntity(
      waterSupply: map['water_supply'],
      userCreated: map['user_created'],
      userDeleted: map['user_deleted'],
      userModified: map['user_modified'],
      login: map['login'],
      logout: map['logout'],
      clientCreated: map['client_created'],
      clientDeleted: map['client_deleted'],
      clientModified: map['client_modified'],
      cashRegisterOpening: map['cash_register_opening'],
      cashRegisterClosing: map['cash_register_closing'],
      saleCreated: map['sale_created'],
      dispatchCompleted: map['dispatch_completed'],
      businessName: map['business_name'],
      businessAddress: map['business_address'],
      extraInfo1: map['extra_info_1'],
      extraInfo2: map['extra_info_2'],
      potableM3Pricing: map["potable_m3_pricing"],
      potableGalPricing: map["potable_gal_pricing"],
      pozoM3Pricing: map["pozo_m3_pricing"],
      pozoGalPricing: map["pozo_gal_pricing"],
    );
  }

  GeneralConfigEntity copyWith({
    bool? waterSupply,
    bool? userCreated,
    bool? userDeleted,
    bool? userModified,
    bool? login,
    bool? logout,
    bool? clientCreated,
    bool? clientDeleted,
    bool? clientModified,
    bool? cashRegisterOpening,
    bool? cashRegisterClosing,
    bool? saleCreated,
    bool? dispatchCompleted,
    String? businessName,
    String? businessAddress,
    String? extraInfo1,
    String? extraInfo2,
    double? potableM3Pricing,
    double? potableGalPricing,
    double? pozoM3Pricing,
    double? pozoGalPricing,
  }) {
    return GeneralConfigEntity(
      waterSupply: waterSupply ?? this.waterSupply,
      userCreated: userCreated ?? this.userCreated,
      userDeleted: userDeleted ?? this.userDeleted,
      userModified: userModified ?? this.userModified,
      login: login ?? this.login,
      logout: logout ?? this.logout,
      clientCreated: clientCreated ?? this.clientCreated,
      clientDeleted: clientDeleted ?? this.clientDeleted,
      clientModified: clientModified ?? this.clientModified,
      cashRegisterOpening: cashRegisterOpening ?? this.cashRegisterOpening,
      cashRegisterClosing: cashRegisterClosing ?? this.cashRegisterClosing,
      saleCreated: saleCreated ?? this.saleCreated,
      dispatchCompleted: dispatchCompleted ?? this.dispatchCompleted,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      extraInfo1: extraInfo1 ?? this.extraInfo1,
      extraInfo2: extraInfo2 ?? this.extraInfo2,
      potableM3Pricing: potableM3Pricing ?? this.potableM3Pricing,
      potableGalPricing: potableGalPricing ?? this.potableGalPricing,
      pozoM3Pricing: pozoM3Pricing ?? this.pozoM3Pricing,
      pozoGalPricing: pozoGalPricing ?? this.pozoGalPricing,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'water_supply': waterSupply,
      'user_created': userCreated,
      'user_deleted': userDeleted,
      'user_modified': userModified,
      'login': login,
      'logout': logout,
      'client_created': clientCreated,
      'client_deleted': clientDeleted,
      'client_modified': clientModified,
      'cash_register_opening': cashRegisterOpening,
      'cash_register_closing': cashRegisterClosing,
      'sale_created': saleCreated,
      'dispatch_completed': dispatchCompleted,
      'business_name': businessName,
      'business_address': businessAddress,
      'extra_info_1': extraInfo1,
      'extra_info_2': extraInfo2,
      "potable_m3_pricing": potableM3Pricing,
      "potable_gal_pricing": potableGalPricing,
      "pozo_m3_pricing": pozoM3Pricing,
      "pozo_gal_pricing": pozoGalPricing,
    };
  }

  @override
  List<Object?> get props => [
    waterSupply,
    userCreated,
    userDeleted,
    userModified,
    login,
    logout,
    clientCreated,
    clientDeleted,
    clientModified,
    cashRegisterOpening,
    cashRegisterClosing,
    saleCreated,
    dispatchCompleted,
    businessName,
    businessAddress,
    extraInfo1,
    extraInfo2,
    potableM3Pricing,
    potableGalPricing,
    pozoM3Pricing,
    pozoGalPricing,
  ];


}
