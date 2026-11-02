import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/tickets/sell_ticket.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/core/utils/print_timing.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/pending_dispatch_entity.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../../commons/ctrl_response.dart';
import '../../../commons/entities/client_entity.dart';
import '../../../inject_container.dart';
import '../../admin/clean/enums/enums.dart';

class OrderController extends ChangeNotifier {
  ClientsApi clientsApi;
  SalesApi salesApi;
  PrinterService printerService;
  GeneralConfigController generalConfigController;
  AuthController authController;
  PendingDispatchesApi pendingDispatchesApi;

  OrderController({
    required this.clientsApi,
    required this.salesApi,
    required this.printerService,
    required this.generalConfigController,
    required this.authController,
    required this.pendingDispatchesApi,
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
  double? totalRemaining;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  PaymentMethod get paymentMethod => _paymentMethod;
  set paymentMethod(PaymentMethod value) {
    _paymentMethod = value;
    notifyListeners();
  }

  SaleEntity? _saleEntity;
  PendingDispatchEntity? pendingDispatchToSettle;
  final String _saleIdempotencyKey = const Uuid().v4();
  bool _isCreatingSale = false;

  bool get isPendingDispatchPayment => pendingDispatchToSettle != null;
  bool get isCreatingSale => _isCreatingSale;

  void preparePendingDispatchPayment({
    required PendingDispatchEntity pendingDispatch,
    ClientEntity? client,
  }) {
    pendingDispatchToSettle = pendingDispatch;
    _selectedClient = client;
    quantityController.text = _formatQuantity(_pendingDispatchQuantity());
    state = pendingDispatch.waterType == WaterType.potable
        ? TabSwitcherAlignStates.left
        : TabSwitcherAlignStates.right;
    stateUnit = pendingDispatch.unitOfMeasurement == UnitOfMeasurement.liters
        ? TabSwitcherAlignStates.left
        : TabSwitcherAlignStates.right;
    notifyListeners();
  }

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
        throw AppException(
          message: "La cantidad entregada no cubre el total de la venta",
        );
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
    } on AppException {
      rethrow;
    }
  }

  Future<CtrlResponse> getSearchClients(String commercialName) async {
    if (commercialName.trim().isEmpty) {
      showedClients = clients;
      notifyListeners();
      return CtrlResponse(success: true);
    }

    try {
      showedClients = await clientsApi.listClients(
        limit: 10,
        search: commercialName,
      );

      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<double>> calculateTotal() async {
    try {
      final pendingDispatch = pendingDispatchToSettle;
      WaterType waterType =
          pendingDispatch?.waterType ?? WaterType.fromTabSwitcher(state);
      UnitOfMeasurement unitOfMeasurement =
          pendingDispatch?.unitOfMeasurement ??
          UnitOfMeasurement.fromTabSwitcher(stateUnit);
      double quantity = pendingDispatch == null
          ? double.parse(quantityController.text)
          : _pendingDispatchQuantity();
      int? clientId = selectedClient?.id;

      double response = await salesApi.quotSale(
        waterType,
        unitOfMeasurement,
        quantity,
        clientId,
      );

      total = response;
      return CtrlResponse(success: true, element: response);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<SaleEntity>> createSell({PrintTiming? timing}) async {
    final operationTiming = timing ?? PrintTiming('venta.crear');
    final ownsTiming = timing == null;

    if (_isCreatingSale) {
      if (ownsTiming) await operationTiming.finish();
      return CtrlResponse(
        success: false,
        message: 'La venta ya se está procesando',
      );
    }

    _isCreatingSale = true;
    notifyListeners();

    try {
      if (paymentMethod == PaymentMethod.credit && selectedClient == null) {
        return CtrlResponse(
          success: false,
          message: "Selecciona un cliente para una venta a credito",
        );
      }

      if (paymentMethod == PaymentMethod.cash) {
        final remainingResponse = calculateTotalRemaining();
        if (!remainingResponse.success) {
          return CtrlResponse(
            success: false,
            message: remainingResponse.message,
          );
        }
      }

      Printer? printer = await operationTiming.measure(
        'validar impresora',
        () => printerService.getSelectedPrinter(),
      );
      if (printer == null) {
        operationTiming.event('sin impresora seleccionada');
        return CtrlResponse(
          success: false,
          message: "No hay ninguna impresora seleccionada",
        );
      }

      if (isPendingDispatchPayment) {
        _saleEntity = await operationTiming.measure(
          'liquidar despacho pendiente',
          () => pendingDispatchesApi.settlePendingDispatch(
            id: pendingDispatchToSettle!.id,
            clientId: selectedClient?.id,
            paymentMethod: paymentMethod,
            amountPaid: paymentMethod == PaymentMethod.cash
                ? double.tryParse(clientMoneyCtrl.text) ?? 0
                : 0,
            changeAmount: paymentMethod == PaymentMethod.cash
                ? totalRemaining ?? 0
                : 0,
          ),
        );
      } else {
        SaleInfoDto dto = SaleInfoDto(
          clientId: selectedClient?.id,
          waterType: WaterType.fromTabSwitcher(state),
          unitOfMeasurement: UnitOfMeasurement.fromTabSwitcher(stateUnit),
          quantity: double.tryParse(quantityController.text),
          paymentMethod: paymentMethod,
          amountPaid: double.tryParse(clientMoneyCtrl.text),
          changeAmount: totalRemaining,
        );

        _saleEntity = await operationTiming.measure(
          'crear venta en backend',
          () => salesApi.createSale(dto, idempotencyKey: _saleIdempotencyKey),
        );
      }

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      operationTiming.event('error de venta: ${e.runtimeType}');
      return CtrlResponse(success: false, message: e.message);
    } finally {
      if (ownsTiming) await operationTiming.finish();
      _isCreatingSale = false;
      notifyListeners();
    }
  }

  Future<void> printTicket({PrintTiming? timing}) async {
    final operationTiming = timing ?? PrintTiming('venta.imprimir');
    final ownsTiming = timing == null;
    try {
      ToastService toastService = locator();
      Printer? printer = await operationTiming.measure(
        'obtener impresora para imprimir',
        () => printerService.getSelectedPrinter(),
      );
      if (printer == null) {
        operationTiming.event('sin impresora seleccionada para imprimir');
        toastService.error("No hay ninguna impresora seleccionada");
        return;
      }

      if (generalConfigController.generalConfigEntity == null) {
        await operationTiming.measure(
          'cargar configuración del ticket',
          () => generalConfigController.loadGeneralConfig(),
        );
      }

      if (_saleEntity == null) {
        operationTiming.event('no hay venta para imprimir');
        toastService.error("Ocurrio un error con la venta");
        return;
      }

      final config = generalConfigController.generalConfigEntity!;

      for (int copy = 0; copy < config.printQnty; copy++) {
        final copyNumber = copy + 1;
        final ticket = SellTicketEntity(
          ticketNumber: _saleEntity!.id,
          copyNumber: copyNumber,
          folio: _saleEntity!.folio,
          commercialName: _saleEntity!.commercialName,
          waterType: _saleEntity!.waterType,
          unitOfMeasurement: _saleEntity!.unitOfMeasurement,
          quantity: _saleEntity!.quantity,
          total: total,
          paymentMethod: _saleEntity!.paymentMethod,
          amountPaid: _saleEntity!.amountPaid,
          changeAmount: _saleEntity!.changeAmount,
          dispatchCode: _saleEntity!.dispatchCode,
          createdAt: _saleEntity!.createdAt,
          sellerName: authController.session!.displayName,
          alreadyDispatched: isPendingDispatchPayment,
        );

        final pdfBytes = await operationTiming.measure(
          'construcción del PDF, copia $copyNumber',
          () => sellTicketPdf(
            config,
            ticket,
            pageFormat: sellTicketPageFormat,
          ),
        );

        final result = await operationTiming.measure(
          'impresión: envío del PDF y respuesta del sistema, copia $copyNumber',
          () => Future<bool>.sync(
            () => Printing.directPrintPdf(
              printer: printer,
              format: sellTicketPageFormat,
              dynamicLayout: false,
              usePrinterSettings: true,
              onLayout: (_) async => pdfBytes,
            ),
          ),
        );
        if (!result) {
          operationTiming.event('impresión no completada, copia $copyNumber');
        }
      }
    } finally {
      if (ownsTiming) await operationTiming.finish();
    }
  }

  // Credits

  Future<CtrlResponse<List<CreditEntity>>> findCreditClientById(
    int clientId,
  ) async {
    try {
      List<CreditEntity> tempCredits = await salesApi
          .listPendingCreditSalesByClient(clientId);
      return CtrlResponse(success: true, element: tempCredits);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    clientMoneyCtrl.dispose();
    super.dispose();
  }

  double _pendingDispatchQuantity() {
    final pendingDispatch = pendingDispatchToSettle;
    if (pendingDispatch == null) return 0;
    return pendingDispatch.quantity ?? pendingDispatch.dispensedVolume;
  }

  String _formatQuantity(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
