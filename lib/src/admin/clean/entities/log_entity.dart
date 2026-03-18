import 'package:equatable/equatable.dart';

class LogEntity extends Equatable {

  int id;
  String type;
  String info;
  DateTime date;

  LogEntity({
    required this.id,
    required this.type,
    required this.info,
    required this.date
  });

  factory LogEntity.fromMap(Map<String, dynamic> data) {
    return LogEntity(
      id: data["id"],
      type: data["type"],
      info: data["info"],
      date: DateTime.fromMillisecondsSinceEpoch(data["date"], isUtc: true).toLocal()
    );
  }

  @override
  List<Object?> get props => [id, type, info, date];

}