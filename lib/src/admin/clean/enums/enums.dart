import 'package:frontend_garzas/core/app/consts.dart';

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

enum PaymentMethod {

  cash(label: "Efectivo", image: AppAssets.cash),
  card(label: "Tarjeta", image: AppAssets.card),
  check(label: "Cheque", image: AppAssets.check);

  final String label;
  final String image;
  const PaymentMethod({required this.label, required this.image});

  static fromString(String role) {
    switch (role) {
      case "cash":
        return PaymentMethod.cash;
      case "card":
        return PaymentMethod.card;
      case "check":
        return PaymentMethod.check;
      default:
        throw AppException(message: "Método no identificado");
    }
  }

}

enum DispatchStatus {

  pending(label: "Pendiente"),
  success(label: "Éxito"),
  failed(label: "Error");

  final String label;
  const DispatchStatus({required this.label});

  static fromString(String role) {
    switch (role) {
      case "pending":
        return DispatchStatus.pending;
      case "success":
        return DispatchStatus.success;
      case "failed":
        return DispatchStatus.failed;
      default:
        throw AppException(message: "Estado no identificado");
    }
  }

}

enum GeneralConfigLogField {
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
}
