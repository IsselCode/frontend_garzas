import '../../../../core/errors/exceptions.dart';

enum AppRole {

  admin(label: "Admin"),
  dispatcher(label: "Despachador"),
  seller(label: "Vendedor");

  final String label;
  const AppRole({required this.label});

  static fromString(String role) {
    switch (role) {
      case "admin":
        return AppRole.admin;
      case "dispatcher":
        return AppRole.dispatcher;
      case "seller":
        return AppRole.seller;
      default:
        throw AppException(message: "Rol no identificado");
    }
  }

}