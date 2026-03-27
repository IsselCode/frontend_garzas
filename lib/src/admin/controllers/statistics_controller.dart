import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/garza_statistic_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/log_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_info_entity.dart';
import 'package:frontend_garzas/src/admin/data/logs_api.dart';

import '../data/sales_api.dart';

class StatisticsController extends ChangeNotifier {

  LogsApi logsApi;
  SalesApi salesApi;

  StatisticsController({
    required this.logsApi,
    required this.salesApi
  });

  List<GarzaStatisticEntity> garzaStatistics = [];

  List<SaleEntity> sales = [];
  List<SaleEntity> showedSales = [];

  List<LogEntity> logs = [];
  List<LogEntity> showedLogs = [];

  Future<CtrlResponse> getGarzasStatistics() async {
    try {
      //Todo: Implementar con backend
      List<GarzaStatisticEntity> fakeStatistics = [
        GarzaStatisticEntity(
          numberGarza: 1,
          liters: 230,
          gallons: 1000,
          total: 45587,
        ),
        GarzaStatisticEntity(
          numberGarza: 2,
          liters: 43078,
          gallons: 446,
          total: 5456,
        ),
        GarzaStatisticEntity(
          numberGarza: 3,
          liters: 280,
          gallons: 2385,
          total: 364578,
        ),
        GarzaStatisticEntity(
          numberGarza: 4,
          liters: 790,
          gallons: 125,
          total: 1123589,
        ),
      ];

      List<GarzaStatisticEntity> tempStatistics = await Future.delayed(
        const Duration(seconds: 1),
        () => fakeStatistics,
      );

      garzaStatistics = tempStatistics;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getSales() async {
    try {

      if (sales.isNotEmpty) {
        return CtrlResponse(success: true);
      }

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

      if (logs.isNotEmpty){
        return CtrlResponse(success: true);
      }

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
