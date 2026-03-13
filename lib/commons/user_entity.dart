import 'package:equatable/equatable.dart';

import '../src/admin/clean/enums/enums.dart';

class UserEntity extends Equatable {

  final int id;
  final String name;
  final AppRole role;
  final DateTime createAt;
  final String accessToken;

  UserEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.createAt,
    required this.accessToken,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map["id"],
      name: map["name"],
      role: AppRole.fromString(map["role"]),
      createAt: DateTime.parse(map["create_at"]),
      accessToken: map["access_token"]
    );
  }

  @override
  List<Object?> get props => [id, name, role];

}