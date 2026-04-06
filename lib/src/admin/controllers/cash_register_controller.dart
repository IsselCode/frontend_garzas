import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/summary_entity.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/sales/clean/entities/active_cut_summary_entity.dart';

class CashRegisterController extends ChangeNotifier {

  CashRegisterApi cashRegisterApi;

  CashRegisterController({
    required this.cashRegisterApi,
  });

  List<CashRegisterEntity> cashRegisterCuts = [];
  List<CashRegisterEntity> showedCashRegisterCuts = [];
  List<SummaryEntity> summaries = [];
  CashRegisterEntity? selectedCut;

  Future<CtrlResponse> getCashRegisterCuts() async {

    try {

      if (cashRegisterCuts.isNotEmpty) {
        return CtrlResponse(success: true);
      }

      List<CashRegisterEntity> tempCuts = await cashRegisterApi.listCashRegisterCuts();
      cashRegisterCuts = tempCuts;
      showedCashRegisterCuts = tempCuts;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> loadCutSummary(CashRegisterEntity cut) async {

    if (cut == selectedCut) {
      return CtrlResponse(success: true);
    }
    selectedCut = cut;
    try {

      List<SummaryEntity> tempSummaries = await cashRegisterApi.getSummaryByCutId(cut.id);
      summaries = tempSummaries;
      notifyListeners();
      return CtrlResponse(success: true, message: "Datos cargados");
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getCutsByDateRange({required DateTime startDate, required DateTime endDate,}) async {
    try {
      List<CashRegisterEntity> tempCuts = await cashRegisterApi.listByDateRange(startDate, endDate);

      showedCashRegisterCuts = tempCuts;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  void clearSalesDateRange() {
    showedCashRegisterCuts = cashRegisterCuts;
    notifyListeners();
  }

  //* Sales

  bool openCash = false;

  Future<CtrlResponse> openCut(double quantity) async {

    try {
      await cashRegisterApi.openCut(quantity);
      openCash = true;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> closeCut(double cash, double card) async {

    try {
      await cashRegisterApi.closeCut(cash, card);
      openCash = true;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse<ActiveCutSummaryEntity>> getActiveCutSummary() async {

    try {
      ActiveCutSummaryEntity tempEntity = await cashRegisterApi.activeCutSummary();
      return CtrlResponse(success: true, element: tempEntity);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<bool> active() async {

    try {
      CashRegisterEntity? entity = await cashRegisterApi.active();

      if (entity != null) {
        openCash = true;
        notifyListeners();
        return true;
      } else {
        return false;
      }

    } on AppException {
      rethrow;
    }

  }

}