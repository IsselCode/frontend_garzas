import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/summary_entity.dart';
import 'package:frontend_garzas/src/sales/clean/entities/active_cut_summary_entity.dart';

class CashRegisterApi {
  final ApiClient apiClient;

  CashRegisterApi({required this.apiClient});

  final String _cashRegisterPath = "/cash-register";
  final String _cashRegisterByDateRangePath = "/cash-register/range";
  final String _cashRegisterOpenPath = "/cash-register/open";
  final String _activeCashRegisterPath = "/cash-register/active";
  final String _activeCashRegisterSummaryPath = "/cash-register/summary";
  String _cashRegisterSummaryById(int id) => "/cash-register/$id/summary";
  final String _cashRegisterClosePath = "/cash-register/close";

  Future<List<CashRegisterEntity>> listCashRegisterCuts() async {

    try {

      List response = await apiClient.get(
        _cashRegisterPath,
        authRequired: true,
      );

      return response.map((e) => CashRegisterEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<List<CashRegisterEntity>> listByDateRange(DateTime startDate, DateTime endDate) async {

    String start = startDate.toIso8601String().split("T").first;
    String end = endDate.toIso8601String().split("T").first;

    try {
      List response = await apiClient.get(
        _cashRegisterByDateRangePath,
        authRequired: true,
        queryParams: {"start_date": start, "end_date": end}
      );

      return response.map((e) => CashRegisterEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<List<SummaryEntity>> getSummaryByCutId(int id) async {
    try {

      List response = await apiClient.get(
        _cashRegisterSummaryById(id),
        authRequired: true,
      );

      return response.map((e) => SummaryEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<CashRegisterEntity> openCut(double openingAmount) async {

    try {

      Map<String, dynamic> body = {
        "opening_amount": openingAmount,
      };

      Map<String, dynamic> response = await apiClient.post(
        _cashRegisterOpenPath,
        authRequired: true,
        body: body
      );

      return CashRegisterEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<CashRegisterEntity?> active() async {
    try {

      Map<String, dynamic> response = await apiClient.get(
        _activeCashRegisterPath,
        authRequired: true,
      );

      if (response.isEmpty) return null;

      return CashRegisterEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<ActiveCutSummaryEntity> activeCutSummary() async {
    try {

      Map<String, dynamic> response = await apiClient.get(
        _activeCashRegisterSummaryPath,
        authRequired: true,
      );

      return ActiveCutSummaryEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<CashRegisterEntity> closeCut(double cash, double card, double check) async {
    try {

      Map<String, dynamic> body = {
        "declared_cash_total": cash,
        "declared_card_total": card,
        "declared_check_total": check
      };

      Map<String, dynamic> response = await apiClient.post(
        _cashRegisterClosePath,
        authRequired: true,
        body: body
      );

      return CashRegisterEntity.fromMap(response["cut"]);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  // TODO: No utilizar: No es necesario en este momento
  // Future<List<SummaryEntity>> getSummaries() async {
  //   throw AppException(message: "Sin implementación");
  // }

}
