import '../../../commons/entities/page_result.dart';
import '../../../commons/paged_list_state.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/log_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/monthly_garza_total_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/statistics_entity.dart';
import 'package:frontend_garzas/src/admin/data/logs_api.dart';

import '../data/sales_api.dart';

class StatisticsController extends ChangeNotifier {
  LogsApi logsApi;
  SalesApi salesApi;

  StatisticsController({required this.logsApi, required this.salesApi}) {
    salesPaging = PagedListState(
      onChanged: () {
        sales = showedSales = salesPaging.items;
        notifyListeners();
      },
    );
    logsPaging = PagedListState(
      limit: 50,
      onChanged: () {
        logs = showedLogs = logsPaging.items;
        notifyListeners();
      },
    );
  }
  late final PagedListState<SaleEntity> salesPaging;
  late final PagedListState<LogEntity> logsPaging;
  DateTime? _salesStart, _salesEnd, _logsStart, _logsEnd;
  String? _saleFolio;
  int _salesRequest = 0, _logsRequest = 0;

  StatisticsEntity? statistics;
  MonthlyGarzaTotalEntity? monthlyGarzaTotalEntity;

  List<SaleEntity> sales = [];
  List<SaleEntity> showedSales = [];

  List<LogEntity> logs = [];
  List<LogEntity> showedLogs = [];

  Future<CtrlResponse> getMonthlyPaymentTotals({DateTime? month}) async {
    try {
      StatisticsEntity tempStatistics = await salesApi.getMonthlyPaymentTotals(
        month: month,
      );
      statistics = tempStatistics;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getMonthlyGarzaTotals({DateTime? month}) async {
    try {
      MonthlyGarzaTotalEntity tempMonthlyGarzaTotal = await salesApi
          .getMonthlyGarzaTotals(month: month);
      monthlyGarzaTotalEntity = tempMonthlyGarzaTotal;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getSales({int page = 1}) {
    _salesRequest++;
    final start = _salesStart, end = _salesEnd;
    _saleFolio = null;
    return salesPaging.load(
      (number) =>
          salesApi.listSalesPage(page: number, startDate: start, endDate: end),
      page: page,
    );
  }

  Future<CtrlResponse> deleteSaleByFolio(String folio) async {
    try {
      await salesApi.deleteSaleByFolio(folio);
      if (_saleFolio != null) {
        salesPaging.replace(const PageResult.empty());
      } else {
        await getSales(page: salesPaging.data.page);
      }
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> findSaleByFolio(String folio) {
    _salesRequest++;
    _salesStart = _salesEnd = null;
    if (folio.trim().isEmpty) return getSales();
    _saleFolio = folio;
    return salesPaging.load((_) async {
      final sale = await salesApi.findSaleByPhone(folio);
      return PageResult(
        items: [sale],
        page: 1,
        limit: 20,
        total: 1,
        totalPages: 1,
      );
    });
  }

  Future<CtrlResponse> getLogs({int page = 1}) {
    _logsRequest++;
    final start = _logsStart, end = _logsEnd;
    return logsPaging.load(
      (number) =>
          logsApi.listPage(page: number, startDate: start, endDate: end),
      page: page,
    );
  }

  Future<CtrlResponse> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => _setSalesRange(startDate, endDate);

  Future<CtrlResponse> clearSalesDateRange() => _setSalesRange(null, null);

  Future<CtrlResponse> _setSalesRange(DateTime? start, DateTime? end) async {
    final previous = (_salesStart, _salesEnd, _saleFolio);
    _salesStart = start;
    _salesEnd = end;
    final pending = getSales();
    final request = _salesRequest;
    final response = await pending;
    if (!response.success && request == _salesRequest) {
      _salesStart = previous.$1;
      _salesEnd = previous.$2;
      _saleFolio = previous.$3;
    }
    return response;
  }

  Future<CtrlResponse> getLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => _setLogsRange(startDate, endDate);

  Future<CtrlResponse> clearLogsDateRange() => _setLogsRange(null, null);

  Future<CtrlResponse> _setLogsRange(DateTime? start, DateTime? end) async {
    final previous = (_logsStart, _logsEnd);
    _logsStart = start;
    _logsEnd = end;
    final pending = getLogs();
    final request = _logsRequest;
    final response = await pending;
    if (!response.success && request == _logsRequest) {
      _logsStart = previous.$1;
      _logsEnd = previous.$2;
    }
    return response;
  }

  @override
  void dispose() {
    salesPaging.dispose();
    logsPaging.dispose();
    super.dispose();
  }
}
