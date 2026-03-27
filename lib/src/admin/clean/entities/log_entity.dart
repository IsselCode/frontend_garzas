import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class LogEntity extends Equatable {

  int id;
  String userUid;
  String username;
  String displayName;
  AppRole role;
  String tipo;
  String info;
  int statusCode;
  double durationMs;
  DateTime createdAt;

  LogEntity({
    required this.id,
    required this.userUid,
    required this.username,
    required this.displayName,
    required this.role,
    required this.tipo,
    required this.info,
    required this.statusCode,
    required this.durationMs,
    required this.createdAt,
  });

  factory LogEntity.fromMap(Map<String, dynamic> data) {
    return LogEntity(
      id: data["id"],
      userUid: data["user_uid"],
      username: data["username"],
      displayName: data["display_name"],
      role: AppRole.fromString(data["role"]),
      tipo: data["tipo"],
      info: data["info"],
      statusCode: data["status_code"],
      durationMs: data["duration_ms"],
      createdAt: DateTime.parse(data["created_at"])
    );
  }

  @override
  List<Object?> get props => [id, userUid, username, displayName, role, tipo, info, statusCode, durationMs, createdAt];

}