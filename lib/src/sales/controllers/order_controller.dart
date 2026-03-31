import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/tickets/sell_ticket.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:printing/printing.dart';

import '../../../commons/ctrl_response.dart';
import '../../../commons/entities/client_entity.dart';
import '../../../inject_container.dart';
import '../../admin/clean/enums/enums.dart';

class OrderController extends ChangeNotifier {

  ClientsApi clientsApi;
  SalesApi salesApi;
  PrinterService printerService;
  GeneralConfigController generalConfigController;

  OrderController({
    required this.clientsApi,
    required this.salesApi,
    required this.printerService,
    required this.generalConfigController,
  });

  TabSwitcherAlignStates _state = TabSwitcherAlignStates.left;
  TabSwitcherAlignStates get state => _state;
  set state(TabSwitcherAlignStates value) {
    _state = value;
    notifyListeners();
  }

  TabSwitcherAlignStates _stateUnit = TabSwitcherAlignStates.left;
  TabSwitcherAlignStates get stateUnit => _stateUnit;
  set stateUnit(TabSwitcherAlignStates value) {
    _stateUnit = value;
    notifyListeners();
  }

  TextEditingController quantityController = TextEditingController();

  TextEditingController clientMoneyCtrl = TextEditingController();
  double total = 0;
  double totalRemaining = 0;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  PaymentMethod get paymentMethod => _paymentMethod;
  set paymentMethod(PaymentMethod value) {
    _paymentMethod = value;
    notifyListeners();
  }

  SaleEntity? _saleEntity;

  ClientEntity? _selectedClient;
  ClientEntity? get selectedClient => _selectedClient;
  set selectedClient(ClientEntity? value) {
    if (value == _selectedClient) {
      _selectedClient = null;
    } else {
      _selectedClient = value;
    }
    notifyListeners();
  }
  List<ClientEntity> clients = [];
  List<ClientEntity> showedClients = [];

  //! Logic Methods
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

  Future<void> getClients() async {

    try {

      List<ClientEntity> tempClients = await clientsApi.listClients(limit: 10);
      clients = tempClients;
      showedClients = tempClients;

      notifyListeners();

    } on AppException catch(e) {
     rethrow;
    }

  }

  Future<CtrlResponse> getSearchClients(String phone) async {

    if (phone.isEmpty) {
      showedClients = clients;
      notifyListeners();
      return CtrlResponse(success: true);
    };

    try {

      ClientEntity tempClient = await clientsApi.getClientByPhone(phone);
      showedClients = [tempClient];

      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse<double>> calculateTotal() async {

    try {

      WaterType waterType = WaterType.fromTabSwitcher(state);
      UnitOfMeasurement unitOfMeasurement = UnitOfMeasurement.fromTabSwitcher(stateUnit);
      double quantity = double.parse(quantityController.text);
      String? customerPhone = selectedClient?.phone;

      double response = await salesApi.quotSale(waterType, unitOfMeasurement, quantity, customerPhone);
      total = response;
      return CtrlResponse(success: true, element: response);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse<SaleEntity>> createSell() async {

    try {
      Printer? printer = printerService.selectedPrinter;
      if (printer == null){
        return CtrlResponse(success: false, message: "No hay ninguna impresora seleccionada");
      }

      SaleInfoDto dto = SaleInfoDto(
        customerPhone: selectedClient?.phone,
        waterType: WaterType.fromTabSwitcher(state),
        unitOfMeasurement: UnitOfMeasurement.fromTabSwitcher(stateUnit),
        quantity: double.tryParse(quantityController.text),
        paymentMethod: paymentMethod,
        amountPaid: double.tryParse(clientMoneyCtrl.text),
        changeAmount: totalRemaining,
      );

      _saleEntity = await salesApi.createSale(dto);

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<void> printTicket() async {
    ToastService toastService = locator();
    Printer? printer = printerService.selectedPrinter;
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
      total: total,
      amountPaid: _saleEntity!.amountPaid,
      changeAmount: _saleEntity!.changeAmount,
      dispatchCode: _saleEntity!.dispatchCode,
      createdAt: _saleEntity!.createdAt,
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

  @override
  void dispose() {
    quantityController.dispose();
    clientMoneyCtrl.dispose();
    super.dispose();
  }
  

}
