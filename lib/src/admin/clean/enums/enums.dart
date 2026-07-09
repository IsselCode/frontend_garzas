import 'package:frontend_garzas/core/app/consts.dart';

import '../../../../core/errors/exceptions.dart';

enum AppRole {
  admin(label: "Admin", wireName: "admin"),
  dispatch(label: "Despachador", wireName: "dispatch"),
  seller(label: "Vendedor", wireName: "seller"),
  salesDispatch(label: "Venta/Despacho", wireName: "sales_dispatch");

  final String label;
  final String wireName;
  const AppRole({required this.label, required this.wireName});

  bool get canDispatch =>
      this == AppRole.dispatch || this == AppRole.salesDispatch;
  bool get canSell => this == AppRole.seller || this == AppRole.salesDispatch;

  static AppRole fromString(String role) {
    for (final appRole in AppRole.values) {
      if (appRole.wireName == role || appRole.name == role) {
        return appRole;
      }
    }
    throw AppException(message: "Rol no identificado");
  }
}

enum PaymentMethod {
  cash(label: "Efectivo", image: AppAssets.cash),
  card(label: "Tarjeta", image: AppAssets.card),
  credit(label: "Credito", image: AppAssets.credit);

  final String label;
  final String image;
  const PaymentMethod({required this.label, required this.image});

  static PaymentMethod fromString(String role) {
    switch (role) {
      case "cash":
        return PaymentMethod.cash;
      case "card":
        return PaymentMethod.card;
      case "credit":
        return PaymentMethod.credit;
      default:
        throw AppException(message: "Método no identificado");
    }
  }
}

enum CashRegisterStatus {
  open(label: "Abierto"),
  closed(label: "Cerrado");

  final String label;
  const CashRegisterStatus({required this.label});

  static CashRegisterStatus fromString(String role) {
    switch (role) {
      case "open":
        return CashRegisterStatus.open;
      case "closed":
        return CashRegisterStatus.closed;
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
  saleCreditLimitRejected,
  dispatchCompleted,
}
