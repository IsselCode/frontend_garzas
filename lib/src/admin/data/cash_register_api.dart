import 'package:frontend_garzas/commons/entities/page_result.dart';
import 'package:frontend_garzas/core/services/paginated_api.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/summary_entity.dart';
import 'package:frontend_garzas/src/sales/clean/entities/active_cut_summary_entity.dart';
import 'package:frontend_garzas/src/sales/clean/entities/closed_cut_summary_entity.dart';
import 'package:frontend_garzas/core/utils/date_range_query.dart';

class CashRegisterApi {
  final ApiClient apiClient;

  CashRegisterApi({required this.apiClient});

  final String _cashRegisterPath = "/cash-register";
  final String _cashRegisterByDateRangePath = "/cash-register/range";
  final String _cashRegisterOpenPath = "/cash-register/open";
  final String _activeCashRegisterPath = "/cash-register/active";
  final String _activeCashRegisterSummaryPath = "/cash-register/summary";
  String _cashRegisterSummaryById(int id) => "/cash-register/$id/summary";
  String _cashRegisterSalesById(int id) => "/cash-register/$id/sales";
  String _cashRegisterReceiptById(int id) => "/cash-register/$id/receipt";
  final String _cashRegisterClosePath = "/cash-register/close";

  Future<PageResult<CashRegisterEntity>> listCutsPage({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final ranged = startDate != null && endDate != null;
    return PaginatedApi.get(
      apiClient,
      ranged ? _cashRegisterByDateRangePath : _cashRegisterPath,
      CashRegisterEntity.fromMap,
      page: page,
      limit: limit,
      filters: ranged
          ? DateRangeQuery.fromDates(startDate: startDate, endDate: endDate)
          : {},
    );
  }

  Future<List<CashRegisterEntity>> listCashRegisterCuts() =>
      PaginatedApi.all((page) => listCutsPage(page: page, limit: 100));

  Future<List<CashRegisterEntity>> listByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) => PaginatedApi.all(
    (page) => listCutsPage(
      page: page,
      limit: 100,
      startDate: startDate,
      endDate: endDate,
    ),
  );

  Future<List<SummaryEntity>> getSummaryByCutId(int id) async {
    try {
      List response = await apiClient.get(
        _cashRegisterSummaryById(id),
        authRequired: true,
      );

      return response.map((e) => SummaryEntity.fromMap(e)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<ClosedCutSummaryEntity> getReceiptByCutId(int id) async {
    try {
      Map<String, dynamic> response = await apiClient.get(
        _cashRegisterReceiptById(id),
        authRequired: true,
      );

      return ClosedCutSummaryEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<PageResult<ClosedCutSaleEntity>> getSalesPageByCutId(
    int id, {
    int page = 1,
    int limit = 20,
  }) => PaginatedApi.get(
    apiClient,
    _cashRegisterSalesById(id),
    ClosedCutSaleEntity.fromMap,
    page: page,
    limit: limit,
  );

  Future<List<ClosedCutSaleEntity>> getSalesByCutId(int id) => PaginatedApi.all(
    (page) => getSalesPageByCutId(id, page: page, limit: 100),
  );

  Future<CashRegisterEntity> openCut(double openingAmount) async {
    try {
      Map<String, dynamic> body = {"opening_amount": openingAmount};

      Map<String, dynamic> response = await apiClient.post(
        _cashRegisterOpenPath,
        authRequired: true,
        body: body,
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

  Future<ClosedCutSummaryEntity> closeCut(double cash, double card) async {
    try {
      Map<String, dynamic> body = {
        "declared_cash_total": cash,
        "declared_card_total": card,
      };

      Map<String, dynamic> response = await apiClient.post(
        _cashRegisterClosePath,
        authRequired: true,
        body: body,
      );

      return ClosedCutSummaryEntity.fromMap(response);
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
