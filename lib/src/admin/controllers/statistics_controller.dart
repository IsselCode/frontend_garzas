import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/garza_statistic_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/log_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sell_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/data/logs_api.dart';

class StatisticsController extends ChangeNotifier {

  LogsApi logsApi;

  StatisticsController({
    required this.logsApi
  });

  List<GarzaStatisticEntity> garzaStatistics = [];

  List<SellEntity> sells = [];
  List<SellEntity> showedSells = [];

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
      List<SellEntity> fakeSells = [
        SellEntity(
          id: 1,
          numberGarza: 1,
          employee: "Hugo Torres Jimenez",
          quantity: 50,
          waterType: WaterType.pozo,
          total: 58057,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        SellEntity(
          id: 2,
          numberGarza: 1,
          employee: "Carlos Felipe",
          quantity: 652,
          waterType: WaterType.potable,
          total: 15202,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.liters,
        ),
        SellEntity(
          id: 3,
          numberGarza: 3,
          employee: "Juan Enrique Gonzalez",
          quantity: 548,
          waterType: WaterType.potable,
          total: 11023,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        SellEntity(
          id: 4,
          numberGarza: 4,
          employee: "Sergio Adrian Fernandez Martínez",
          quantity: 50,
          waterType: WaterType.pozo,
          total: 1267,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        SellEntity(
          id: 5,
          numberGarza: 2,
          employee: "Luis Quintero",
          quantity: 123,
          waterType: WaterType.potable,
          total: 357,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.liters,
        ),
        SellEntity(
          id: 6,
          numberGarza: 1,
          employee: "Miguel Jose",
          quantity: 5987,
          waterType: WaterType.pozo,
          total: 6549,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        SellEntity(
          id: 7,
          numberGarza: 4,
          employee: "Osiel Francisco",
          quantity: 265,
          waterType: WaterType.pozo,
          total: 12679,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        SellEntity(
          id: 8,
          numberGarza: 2,
          employee: "Hugo Torres Jimenez",
          quantity: 127,
          waterType: WaterType.potable,
          total: 9875,
          date: DateTime.now(),
          unitOfMeasurement: UnitOfMeasurement.liters,
        ),
      ];

      List<SellEntity> tempSells = await Future.delayed(
        const Duration(seconds: 1),
        () => fakeSells,
      );

      sells = tempSells;
      showedSells = tempSells;
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

  Future<CtrlResponse> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // TODO: Reemplazar con la consulta al backend.
      List<SellEntity> tempSells = await Future.delayed(
        const Duration(milliseconds: 300),
        () => sells.where((sell) {
          return !sell.date.isBefore(startDate) && !sell.date.isAfter(endDate);
        }).toList(),
      );

      showedSells = tempSells;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  void clearSalesDateRange() {
    showedSells = sells;
    notifyListeners();
  }

  Future<CtrlResponse> getLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
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
