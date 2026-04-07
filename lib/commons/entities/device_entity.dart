class DeviceEntity {
  final String name;
  final String host;
  final int port;
  final Map<String, dynamic> txt;
  DeviceEntity({
    required this.name,
    required this.host,
    required this.port,
    required this.txt
  });
}