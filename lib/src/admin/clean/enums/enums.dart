import '../../../../core/errors/exceptions.dart';

enum AppRole {

  admin(label: "Admin"),
  dispatch(label: "Despachador"),
  seller(label: "Vendedor");

  final String label;
  const AppRole({required this.label});

  static fromString(String role) {
    switch (role) {
      case "admin":
        return AppRole.admin;
      case "dispatch":
        return AppRole.dispatch;
      case "seller":
        return AppRole.seller;
      default:
        throw AppException(message: "Rol no identificado");
    }
  }

}

enum GeneralConfigLogField {
  loadData,
  userCreated,
  userDeleted,
  login,
  logout,
  clientCreated,
  clientDeleted,
  clientModified,
}
