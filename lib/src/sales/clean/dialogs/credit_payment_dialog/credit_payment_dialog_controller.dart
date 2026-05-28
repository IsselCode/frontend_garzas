import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../admin/data/sales_api.dart';

class CreditPaymentDialogController extends ChangeNotifier {
  SalesApi salesApi;
  ClientsApi clientsApi;
  ToastService toastService;
  BuildContext context;

  CreditPaymentDialogController({
    required this.salesApi,
    required this.clientsApi,
    required this.toastService,
    required this.context,
  }) {
    pageController.addListener(() {
      indexPage = pageController.page!.toInt();
      if (indexPage == 0) {
        title = "Selecciona al cliente";
      } else if (indexPage == 1) {
        title = "Selecciona el credito";
      } else {
        title = "Termina el pago";
      }
      notifyListeners();
    });
  }

  PageController pageController = PageController();
  String title = "Selecciona al cliente";
  int indexPage = 0;

  List<CreditEntity> creditsClient = [];
  List<ClientEntity> clients = [];

  ClientEntity? _selectedClient;
  ClientEntity? get selectedClient => _selectedClient;
  set selectedClient(ClientEntity? value) {
    _selectedClient = value;
    notifyListeners();
  }

  CreditEntity? _selectedCredit;
  CreditEntity? get selectedCredit => _selectedCredit;
  set selectedCredit(CreditEntity? value) {
    _selectedCredit = value;
    pageController.jumpToPage(2);
  }

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  set selectedPaymentMethod(PaymentMethod value) {
    _selectedPaymentMethod = value;
    notifyListeners();
  }

  //
  GlobalKey<FormState> clientSearchKey = GlobalKey<FormState>();
  final TextEditingController commercialNameCtrl = TextEditingController();
  TextEditingController clientMoneyCtrl = TextEditingController();

  // Button
  Future<void> enter() async {
    if (pageController.page == 0) {
      await findCreditsForSelectedClient();
    } else if (pageController.page == 2) {
      await payCredit();
    }

    notifyListeners();
  }

  Future<void> searchClients() async {
    if (!clientSearchKey.currentState!.validate()) return;
    context.loaderOverlay.show();
    try {
      clients = await clientsApi.listClients(
        limit: 10,
        search: commercialNameCtrl.text,
      );
      selectedClient = null;
    } on AppException catch (e) {
      toastService.error(e.message);
    }
    if (!context.mounted) return;
    context.loaderOverlay.hide();
    notifyListeners();
  }

  Future<void> findCreditsForSelectedClient() async {
    if (selectedClient == null) {
      toastService.error("Selecciona un cliente");
      return;
    }

    context.loaderOverlay.show();
    CtrlResponse<List<CreditEntity>> response = await _findCreditsByClientId(
      selectedClient!.id,
    );
    if (!context.mounted) return;
    context.loaderOverlay.hide();

    if (!response.success) {
      toastService.error(response.message!);
      return;
    }

    creditsClient = response.element ?? [];
    pageController.jumpToPage(1);
  }

  Future<void> payCredit() async {
    context.loaderOverlay.show();
    CtrlResponse response = await _payCredit(
      selectedCredit!.saleFolio,
      selectedPaymentMethod,
      selectedCredit!.salePendingAmount,
    );
    if (!context.mounted) return;
    context.loaderOverlay.hide();

    if (response.success) {
      pageController.jumpToPage(0);
    } else {
      toastService.error(response.message!);
    }
  }

  // API

  Future<CtrlResponse<List<CreditEntity>>> _findCreditsByClientId(
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

  Future<CtrlResponse> _payCredit(
    String folio,
    PaymentMethod method,
    double total,
  ) async {
    try {
      await salesApi.createCreditPayment(folio, method, total);
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    commercialNameCtrl.dispose();
    clientMoneyCtrl.dispose();
    super.dispose();
  }
}
