import 'package:equatable/equatable.dart';

import '../../src/admin/clean/enums/enums.dart';

class UserEntity extends Equatable {

  final String uid;
  final String username;
  final String displayName;
  final AppRole role;
  final bool isActive;
  final DateTime createAt;

  UserEntity({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.role,
    required this.isActive,
    required this.createAt
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map["uid"],
      username: map["username"],
      displayName: map["display_name"],
      role: AppRole.fromString(map["role"]),
      isActive: map["is_active"],
      createAt: DateTime.parse(map["created_at"]),
    );
  }

  @override
  List<Object?> get props => [uid, username, displayName, role, isActive, createAt];

}