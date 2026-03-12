import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';
import 'package:frontend_garzas/src/sales/clean/enums/enums.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../commons/ctrl_response.dart';
import '../clean/entities/sale_info_entity.dart';

class OrderController extends ChangeNotifier {

  TabSwitcherAlignStates _state = TabSwitcherAlignStates.left;
  TabSwitcherAlignStates get state => _state;
  set state(TabSwitcherAlignStates value) {
    _state = value;
    notifyListeners();
  }
  TextEditingController quantityController = TextEditingController();

  TextEditingController clientMoneyCtrl = TextEditingController();
  double total = 0;
  double totalRemaining = 0;

  SaleInfoEntity? _saleInfoEntity;

  //! Login Methods
  CtrlResponse calculateTotalRemaining() {
    try {

      final double? clientMoney = double.tryParse(clientMoneyCtrl.text.trim());

      if (clientMoney == null) {
        throw AppException(message: "Ingresa una cantidad valida");
      }

      if (clientMoney < total) {
        throw AppException(message: "La cantidad entregada no cubre el total de la venta");
      }

      totalRemaining = clientMoney - total;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      totalRemaining = 0;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    }
  }

  // Model Methods
  // TODO: Implementar con método de módelo
  Future<CtrlResponse<double>> calculateTotal() async {

    try {

      double response = await Future.delayed(const Duration(milliseconds: 500), () => 250,);
      total = response;

      return CtrlResponse(success: true, element: response);

    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  // TODO: Implementar con método de módelo
  Future<CtrlResponse<SaleInfoEntity>> createSell() async {

    try {

      SaleInfoDto dto = SaleInfoDto(
        quantity: double.parse(quantityController.text),
        waterType: WaterType.fromTabSwitcher(state),
        estimateTotal: total,
        clientMoney: double.parse(clientMoneyCtrl.text),
        totalRemaining: totalRemaining
      );

      print(dto.toString());

      return CtrlResponse(success: true);
      throw AppException(message: "Controlador no implementado");

    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  // TODO: Implementar Driver Impresora
  Future<void> printTicket() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  void dispose() {
    quantityController.dispose();
    clientMoneyCtrl.dispose();
    super.dispose();
  }

  

}
