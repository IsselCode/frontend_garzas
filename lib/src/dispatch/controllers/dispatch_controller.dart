import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_validate_entity.dart';
import 'package:printing/printing.dart';

import '../../../commons/tickets/sell_ticket.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';

class DispatchController extends ChangeNotifier {

  SalesApi salesApi;
  GarzasApi garzasApi;
  GeneralConfigController generalConfigController;
  PrinterService printerService;
  AuthController authController;

  DispatchController({
    required this.salesApi,
    required this.garzasApi,
    required this.generalConfigController,
    required this.printerService,
    required this.authController,
  });

  DispatchValidateEntity? dispatchValidate;
  List<ConfigGarzaEntity> availableGarzas = [];
  ConfigGarzaEntity? _selectedGarza;
  ConfigGarzaEntity? get selectedGarza => _selectedGarza;
  set selectedGarza(ConfigGarzaEntity? value) {
    _selectedGarza = value;
  }
  SaleEntity? _saleEntity;

  Future<CtrlResponse> validateBarcode(String barcode) async {

    try {

      DispatchValidateEntity validate = await salesApi.validateDispatch(barcode);
      dispatchValidate = validate;
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> getAvailableGarzas() async {

    try {
      List<ConfigGarzaEntity> tempGarzas = await garzasApi.listGarzas(waterType: dispatchValidate!.waterType);
      availableGarzas = tempGarzas;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse<SaleEntity>> dispatch() async {

    try {
      Printer? printer = await printerService.getSelectedPrinter();
      if (printer == null){
        return CtrlResponse(success: false, message: "No hay ninguna impresora seleccionada");
      }

      _saleEntity = await salesApi.dispatch(dispatchValidate!.dispatchCode, selectedGarza!.number);

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<void> printTicket() async {
    ToastService toastService = locator();
    Printer? printer = await printerService.getSelectedPrinter();
    if (printer == null){
      toastService.error("No hay ninguna impresora seleccionada");
      return ;
    }

    if (generalConfigController.generalConfigEntity == null){
      await generalConfigController.loadGeneralConfig();
    }

    if (_saleEntity == null) {
      toastService.error("Ocurrio un error con la venta");
      return;
    }

    final config = generalConfigController.generalConfigEntity;
    final ticket = SellTicketEntity(
      folio: _saleEntity!.folio,
      clientName: _saleEntity!.clientName,
      clientPhone: _saleEntity!.clientPhone,
      waterType: _saleEntity!.waterType,
      unitOfMeasurement: _saleEntity!.unitOfMeasurement,
      quantity: _saleEntity!.quantity,
      total: _saleEntity!.total,
      amountPaid: _saleEntity!.amountPaid,
      changeAmount: _saleEntity!.changeAmount,
      dispatchCode: _saleEntity!.dispatchCode,
      createdAt: _saleEntity!.createdAt,
      sellerName: authController.session!.displayName
    );

    // Para probar o guardar ticket en PC
    // Uint8List bytes = await sellTicketPdf(config!, ticket);
    // await Printing.sharePdf(
    //   bytes: bytes,
    //   filename: "CUALQUIER NOMBRE",
    // );

    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (format) => sellTicketPdf(config!, ticket),
    );


  }

}