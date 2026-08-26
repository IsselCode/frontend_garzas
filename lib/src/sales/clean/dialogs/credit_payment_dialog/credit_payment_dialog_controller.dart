import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

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
        title = "Selecciona los creditos";
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

  final List<CreditEntity> _selectedCredits = [];
  String? _bulkPaymentIdempotencyKey;
  bool _isPayingCredits = false;

  List<CreditEntity> get selectedCredits =>
      List<CreditEntity>.unmodifiable(_selectedCredits);

  double get selectedCreditsTotal => _selectedCredits.fold(
    0,
    (total, credit) => total + credit.salePendingAmount,
  );

  bool get allCreditsSelected =>
      creditsClient.isNotEmpty && creditsClient.every(isCreditSelected);

  bool get isPayingCredits => _isPayingCredits;

  ClientEntity? _selectedClient;
  ClientEntity? get selectedClient => _selectedClient;
  set selectedClient(ClientEntity? value) {
    _selectedClient = value;
    _selectedCredits.clear();
    _bulkPaymentIdempotencyKey = null;
    notifyListeners();
  }

  CreditEntity? get selectedCredit =>
      _selectedCredits.length == 1 ? _selectedCredits.first : null;

  set selectedCredit(CreditEntity? value) {
    _selectedCredits.clear();
    if (value != null) {
      _selectedCredits.add(value);
    }
    _bulkPaymentIdempotencyKey = null;
    notifyListeners();
  }

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  set selectedPaymentMethod(PaymentMethod value) {
    _selectedPaymentMethod = value;
    _bulkPaymentIdempotencyKey = null;
    notifyListeners();
  }

  bool isCreditSelected(CreditEntity credit) {
    return _selectedCredits.any(
      (selectedCredit) => selectedCredit.saleFolio == credit.saleFolio,
    );
  }

  void toggleCreditSelection(CreditEntity credit) {
    final selectedIndex = _selectedCredits.indexWhere(
      (selectedCredit) => selectedCredit.saleFolio == credit.saleFolio,
    );

    if (selectedIndex == -1) {
      if (_selectedCredits.length >= 100) {
        toastService.error("Solo puedes seleccionar hasta 100 creditos");
        return;
      }
      _selectedCredits.add(credit);
    } else {
      _selectedCredits.removeAt(selectedIndex);
    }

    _bulkPaymentIdempotencyKey = null;
    notifyListeners();
  }

  void toggleSelectAllCredits() {
    if (allCreditsSelected) {
      _selectedCredits.clear();
    } else {
      if (creditsClient.length > 100) {
        toastService.error("No puedes seleccionar más de 100 creditos");
        return;
      }
      _selectedCredits
        ..clear()
        ..addAll(creditsClient);
    }

    _bulkPaymentIdempotencyKey = null;
    notifyListeners();
  }

  //
  GlobalKey<FormState> clientSearchKey = GlobalKey<FormState>();
  final TextEditingController commercialNameCtrl = TextEditingController();
  TextEditingController clientMoneyCtrl = TextEditingController();

  // Button
  Future<void> enter() async {
    if (indexPage == 0) {
      await findCreditsForSelectedClient();
    } else if (indexPage == 1) {
      await continueWithSelectedCredits();
    } else if (indexPage == 2) {
      await payCredits();
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
    _selectedCredits.clear();
    _bulkPaymentIdempotencyKey = null;
    pageController.jumpToPage(1);
  }

  Future<void> continueWithSelectedCredits() async {
    if (_selectedCredits.isEmpty) {
      toastService.error("Selecciona al menos un credito");
      return;
    }

    if (selectedCreditsTotal <= 0) {
      toastService.error("El total a pagar debe ser mayor que cero");
      return;
    }

    pageController.jumpToPage(2);
  }

  Future<void> payCredits() async {
    if (_selectedCredits.isEmpty) {
      toastService.error("Selecciona al menos un credito");
      return;
    }

    if (_isPayingCredits) return;

    final idempotencyKey = _bulkPaymentIdempotencyKey ??= const Uuid().v4();
    final folios = _selectedCredits.map((credit) => credit.saleFolio).toList();
    final total = selectedCreditsTotal;

    _isPayingCredits = true;
    notifyListeners();
    context.loaderOverlay.show();

    try {
      final response = await _payCredits(
        folios,
        selectedPaymentMethod,
        total,
        idempotencyKey,
      );

      if (!response.success) {
        toastService.error(
          response.message ?? "No se pudieron registrar los pagos",
        );
        await _reloadCreditsAfterBulkPayment();
        if (context.mounted) {
          pageController.jumpToPage(1);
        }
        return;
      }

      _selectedCredits.clear();
      _bulkPaymentIdempotencyKey = null;
      toastService.success("Pagos registrados correctamente");
      await _reloadCreditsAfterBulkPayment();
      if (context.mounted) {
        pageController.jumpToPage(1);
      }
    } finally {
      if (context.mounted) {
        context.loaderOverlay.hide();
      }
      _isPayingCredits = false;
      notifyListeners();
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

  Future<CtrlResponse> _payCredits(
    List<String> folios,
    PaymentMethod method,
    double total,
    String idempotencyKey,
  ) async {
    try {
      await salesApi.createBulkCreditPayment(
        folios: folios,
        method: method,
        total: total,
        idempotencyKey: idempotencyKey,
      );
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<void> _reloadCreditsAfterBulkPayment() async {
    final client = selectedClient;
    if (client == null) return;

    final response = await _findCreditsByClientId(client.id);
    _selectedCredits.clear();
    _bulkPaymentIdempotencyKey = null;

    if (response.success) {
      creditsClient = response.element ?? [];
    } else {
      toastService.error(
        response.message ?? "No se pudieron actualizar los creditos pendientes",
      );
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
