import '../../../commons/paged_list_state.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/summary_entity.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/sales/clean/entities/active_cut_summary_entity.dart';
import 'package:frontend_garzas/src/sales/clean/entities/closed_cut_summary_entity.dart';

class CashRegisterController extends ChangeNotifier {
  CashRegisterApi cashRegisterApi;

  CashRegisterController({required this.cashRegisterApi}) {
    paging = PagedListState(
      onChanged: () {
        cashRegisterCuts = showedCashRegisterCuts = paging.items;
        notifyListeners();
      },
    );
    salesPaging = PagedListState(onChanged: notifyListeners);
  }
  late final PagedListState<CashRegisterEntity> paging;
  late final PagedListState<ClosedCutSaleEntity> salesPaging;
  DateTime? _start, _end;
  int _request = 0;

  List<CashRegisterEntity> cashRegisterCuts = [];
  List<CashRegisterEntity> showedCashRegisterCuts = [];
  List<SummaryEntity> summaries = [];
  CashRegisterEntity? selectedCut;

  Future<CtrlResponse> getCashRegisterCuts({int page = 1}) {
    _request++;
    final start = _start, end = _end;
    return paging.load(
      (number) => cashRegisterApi.listCutsPage(
        page: number,
        startDate: start,
        endDate: end,
      ),
      page: page,
    );
  }

  Future<CtrlResponse> loadCutSummary(CashRegisterEntity cut) async {
    if (cut == selectedCut) {
      return CtrlResponse(success: true);
    }
    selectedCut = cut;
    try {
      List<SummaryEntity> tempSummaries = await cashRegisterApi
          .getSummaryByCutId(cut.id);
      summaries = tempSummaries;
      notifyListeners();
      return CtrlResponse(success: true, message: "Datos cargados");
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<ClosedCutSummaryEntity>> getCutReceipt(int cutId) async {
    try {
      final receipt = await cashRegisterApi.getReceiptByCutId(cutId);
      return CtrlResponse(success: true, element: receipt);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<List<ClosedCutSaleEntity>>> getCutSales(
    int cutId, {
    int page = 1,
  }) async {
    final result = await salesPaging.load(
      (number) => cashRegisterApi.getSalesPageByCutId(cutId, page: number),
      page: page,
    );
    return CtrlResponse(
      success: result.success,
      message: result.message,
      element: salesPaging.items,
    );
  }

  Future<CtrlResponse> getCutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => _setRange(startDate, endDate);

  Future<CtrlResponse> clearSalesDateRange() => _setRange(null, null);

  Future<CtrlResponse> _setRange(DateTime? start, DateTime? end) async {
    final previous = (_start, _end);
    _start = start;
    _end = end;
    final pending = getCashRegisterCuts();
    final request = _request;
    final response = await pending;
    if (!response.success && request == _request) {
      _start = previous.$1;
      _end = previous.$2;
    }
    return response;
  }

  @override
  void dispose() {
    paging.dispose();
    salesPaging.dispose();
    super.dispose();
  }

  //* Sales

  bool openCash = false;

  Future<CtrlResponse> openCut(double quantity) async {
    try {
      await cashRegisterApi.openCut(quantity);
      openCash = true;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<ClosedCutSummaryEntity>> closeCut(
    double cash,
    double card,
  ) async {
    try {
      ClosedCutSummaryEntity closedCutSummary = await cashRegisterApi.closeCut(
        cash,
        card,
      );
      openCash = true;
      notifyListeners();
      return CtrlResponse(success: true, element: closedCutSummary);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<ActiveCutSummaryEntity>> getActiveCutSummary() async {
    try {
      ActiveCutSummaryEntity tempEntity = await cashRegisterApi
          .activeCutSummary();
      return CtrlResponse(success: true, element: tempEntity);
    } on AppException catch (e) {
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
