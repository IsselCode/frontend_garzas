import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../admin/data/sales_api.dart';

class CreditPaymentDialogController extends ChangeNotifier {

  SalesApi salesApi;
  ToastService toastService;
  BuildContext context;

  CreditPaymentDialogController({
    required this.salesApi,
    required this.toastService,
    required this.context,
  }) {
    pageController.addListener(() {
      indexPage = pageController.page!.toInt();
      if (indexPage == 0) {
        title = "Ingresa el número de teléfono";
      } else if (indexPage == 1) {
        title = "Selecciona el credito";
      } else {
        title = "Termina el pago";
      }
      notifyListeners();
    },);
  }

  PageController pageController = PageController();
  String title = "Ingresa el número de teléfono";
  int indexPage = 0;

  List<CreditEntity> creditsClient = [];

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
  GlobalKey<FormState> clientPhoneKey = GlobalKey<FormState>();
  final TextEditingController clientPhoneCtrl = TextEditingController();
  TextEditingController clientMoneyCtrl = TextEditingController();

  // Button
  Future<void> enter() async {

    if (pageController.page == 0) {
      await findCreditClientByPhoneNumber();
    } else if (pageController.page == 2) {
      await payCredit();
    }

    notifyListeners();

  }

  Future<void> findCreditClientByPhoneNumber() async {

    if (!clientPhoneKey.currentState!.validate()) {
      return ;
    }

    context.loaderOverlay.show();
    CtrlResponse response = await _findCreditClientByPhoneNumber(clientPhoneCtrl.text.trim());
    context.loaderOverlay.hide();

    if (response.success) {
      creditsClient = response.element;
      pageController.jumpToPage(1);
    } else {
      toastService.error(response.message!);
    }

  }

  Future<void> payCredit() async {

    context.loaderOverlay.show();
    CtrlResponse response = await _payCredit(selectedCredit!.saleFolio, selectedPaymentMethod, selectedCredit!.salePendingAmount);
    context.loaderOverlay.hide();

    if (response.success) {
      pageController.jumpToPage(0);
    } else {
      toastService.error(response.message!);
    }

  }


  // API

  Future<CtrlResponse<List<CreditEntity>>> _findCreditClientByPhoneNumber(String phoneNumber) async {

    try {

      List<CreditEntity> tempCredits = await salesApi.listPendingCreditSalesByClient(phoneNumber);
      return CtrlResponse(success: true, element: tempCredits);

    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> _payCredit(String folio, PaymentMethod method, double total) async {

    try {

      await salesApi.createCreditPayment(folio, method, total);
      return CtrlResponse(success: true);

    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }


}