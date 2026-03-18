import 'package:equatable/equatable.dart';

class GeneralConfigEntity extends Equatable {

  bool loadData;
  bool userCreated;
  bool userDeleted;
  bool login;
  bool logout;
  bool clientCreated;
  bool clientDeleted;
  bool clientModified;

  String businessName;
  String businessAddress;
  String extraInfo1;
  String extraInfo2;

  GeneralConfigEntity({
    required this.loadData,
    required this.userCreated,
    required this.userDeleted,
    required this.login,
    required this.logout,
    required this.clientCreated,
    required this.clientDeleted,
    required this.clientModified,
    required this.businessName,
    required this.businessAddress,
    required this.extraInfo1,
    required this.extraInfo2
  });

  factory GeneralConfigEntity.fromMap(Map<String, dynamic> map) {
    return GeneralConfigEntity(
      loadData: map['load_data'],
      userCreated: map['user_created'],
      userDeleted: map['user_deleted'],
      login: map['login'],
      logout: map['logout'],
      clientCreated: map['client_created'],
      clientDeleted: map['client_deleted'],
      clientModified: map['client_modified'],
      businessName: map['business_name'],
      businessAddress: map['business_address'],
      extraInfo1: map['extra_info_1'],
      extraInfo2: map['extra_info_2'],
    );
  }

  GeneralConfigEntity copyWith({
    bool? loadData,
    bool? userCreated,
    bool? userDeleted,
    bool? login,
    bool? logout,
    bool? clientCreated,
    bool? clientDeleted,
    bool? clientModified,
    String? businessName,
    String? businessAddress,
    String? extraInfo1,
    String? extraInfo2,
  }) {
    return GeneralConfigEntity(
      loadData: loadData ?? this.loadData,
      userCreated: userCreated ?? this.userCreated,
      userDeleted: userDeleted ?? this.userDeleted,
      login: login ?? this.login,
      logout: logout ?? this.logout,
      clientCreated: clientCreated ?? this.clientCreated,
      clientDeleted: clientDeleted ?? this.clientDeleted,
      clientModified: clientModified ?? this.clientModified,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      extraInfo1: extraInfo1 ?? this.extraInfo1,
      extraInfo2: extraInfo2 ?? this.extraInfo2,
    );
  }

  @override
  List<Object?> get props => [
    loadData,
    userCreated,
    userDeleted,
    login,
    logout,
    clientCreated,
    clientDeleted,
    clientModified,
    businessName,
    businessAddress,
    extraInfo1,
    extraInfo2
  ];


}
