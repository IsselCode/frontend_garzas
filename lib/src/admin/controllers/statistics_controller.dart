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

  StatisticsController({
    required this.logsApi,
    required this.salesApi
  });

  StatisticsEntity? statistics;
  MonthlyGarzaTotalEntity? monthlyGarzaTotalEntity;

  List<SaleEntity> sales = [];
  List<SaleEntity> showedSales = [];

  List<LogEntity> logs = [];
  List<LogEntity> showedLogs = [];

  Future<CtrlResponse> getMonthlyPaymentTotals() async {
    try {

      StatisticsEntity tempStatistics = await salesApi.getMonthlyPaymentTotals();
      statistics = tempStatistics;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getMonthlyGarzaTotals() async {
    try {

      MonthlyGarzaTotalEntity tempMonthlyGarzaTotal = await salesApi.getMonthlyGarzaTotals();
      monthlyGarzaTotalEntity = tempMonthlyGarzaTotal;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getSales() async {
    try {

      List<SaleEntity> tempSells = await salesApi.listSales();

      sales = tempSells;
      showedSales = tempSells;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> findSaleByFolio(String folio) async {
    try {

      if (folio.isEmpty) {
        clearSalesDateRange();
        return CtrlResponse(success: true);
      }

      SaleEntity tempSale = await salesApi.findSaleByPhone(folio);
      showedSales = [tempSale];
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getLogs() async {
    try {

      List<LogEntity> tempLogs = await logsApi.listLogs();
      logs = tempLogs;
      showedLogs = tempLogs;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getSalesByDateRange({required DateTime startDate, required DateTime endDate,}) async {
    try {
      List<SaleEntity> tempSells = await salesApi.listByDateRange(startDate, endDate);

      showedSales = tempSells;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  void clearSalesDateRange() {
    showedSales = sales;
    notifyListeners();
  }

  Future<CtrlResponse> getLogsByDateRange({required DateTime startDate, required DateTime endDate,}) async {
    try {
      List<LogEntity> tempLogs = await logsApi.listByDateRange(startDate, endDate);

      showedLogs = tempLogs;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  void clearLogsDateRange() {
    showedLogs = logs;
    notifyListeners();
  }
}
