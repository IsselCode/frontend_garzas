import 'package:equatable/equatable.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class LogEntity extends Equatable {

  int id;
  String type;
  String user;
  String info;

  DateTime date;

  LogEntity({
    required this.id,
    required this.type,
    required this.user,
    required this.info,
    required this.date
  });

  factory LogEntity.fromMap(Map<String, dynamic> data) {
    return LogEntity(
      id: data["id"],
      type: data["type"],
        user: data["user"],
      info: data["info"],
      date: DateTime.fromMillisecondsSinceEpoch(data["date"], isUtc: true).toLocal()
    );
  }

  @override
  List<Object?> get props => [id, type, user, info, date];

}