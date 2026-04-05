import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/credit_payment_entity.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';

class CreditsController extends ChangeNotifier {

  SalesApi salesApi;

  CreditsController({
    required this.salesApi,
  });

  List<CreditEntity> allCredits = [];
  List<CreditEntity> showedCredits = [];

  CreditEntity? _selectedCredit;
  CreditEntity? get selectedCredit => _selectedCredit;
  set selectedCredit(CreditEntity? value) {
    _selectedCredit = value;
    notifyListeners();
  }

  List<CreditPaymentEntity> creditPayments = [];

  Future<CtrlResponse> getCredits() async {

    try {

      if (allCredits.isNotEmpty) {
        return CtrlResponse(success: true);
      }

      List<CreditEntity> tempCredits = await salesApi.getPendingCredits();
      allCredits = tempCredits;
      showedCredits = tempCredits;

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> getCutsByDateRange({required DateTime startDate, required DateTime endDate,}) async {
    try {
      List<CreditEntity> tempCredits = await salesApi.getPendingCredits(startDate: startDate, endDate: endDate);
      showedCredits = tempCredits;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  void clearSalesDateRange() {
    showedCredits = allCredits;
    notifyListeners();
  }

  Future<CtrlResponse> loadCreditPayments(CreditEntity credit) async {

    try {

      if (credit == selectedCredit) return CtrlResponse(success: true);

      selectedCredit = credit;

      List<CreditPaymentEntity> tempCreditPayments = await salesApi.getCreditPayments(selectedCredit!.saleFolio);
      creditPayments = tempCreditPayments;

      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

}