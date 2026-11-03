import 'package:frontend_garzas/commons/entities/page_result.dart';
import 'package:frontend_garzas/core/services/paginated_api.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/credit_payment_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/statistics_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_validate_entity.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:frontend_garzas/core/utils/date_range_query.dart';

import '../clean/entities/monthly_garza_total_entity.dart';
import '../clean/enums/credit_status.dart';

class SalesApi {
  final ApiClient apiClient;

  SalesApi({required this.apiClient});

  final String _salesPath = "/sales";
  final String _salesQuotePath = "/sales/quote";
  String _deleteSaleByFolio(String folio) => "/sales/$folio";
  final String _salesByDateRangePath = "/sales/range";
  final String _getMonthlyPaymentTotalsPath = "/sales/monthly-payment-totals";
  final String _getMonthlyGarzaTotals = "/sales/monthly-garza-totals";

  String _dispatchValidatePath(String code) => "/sales/$code/dispatch/validate";
  String _dispatchPath(String code) => "/sales/$code/dispatch";

  String _listPendingCreditSalesByClientPath(int clientId) =>
      "/sales/credit/by-client/$clientId";
  String _createCreditPaymentPath(String folio) =>
      "/sales/$folio/credit-payments";
  String _listCreditPaymentsPath(String folio) =>
      "/sales/$folio/credit-payments";
  final String _getPendingCreditsPath = "/sales/credit/pending";
  final String _bulkCreditPaymentsPath = "/sales/credit-payments/bulk";

  Future<PageResult<SaleEntity>> listSalesPage({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final ranged = startDate != null && endDate != null;
    return PaginatedApi.get(
      apiClient,
      ranged ? _salesByDateRangePath : _salesPath,
      SaleEntity.fromMap,
      page: page,
      limit: limit,
      filters: ranged
          ? DateRangeQuery.fromDates(startDate: startDate, endDate: endDate)
          : {},
    );
  }

  Future<List<SaleEntity>> listSales() =>
      PaginatedApi.all((page) => listSalesPage(page: page, limit: 100));

  Future<StatisticsEntity> getMonthlyPaymentTotals({DateTime? month}) async {
    try {
      Map<String, dynamic> response = await apiClient.get(
        _getMonthlyPaymentTotalsPath,
        authRequired: true,
        queryParams: month == null
            ? null
            : {"month": month.toIso8601String().split("T").first},
      );

      return StatisticsEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<void> deleteSaleByFolio(String folio) async {
    try {
      await apiClient.delete(_deleteSaleByFolio(folio), authRequired: true);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<MonthlyGarzaTotalEntity> getMonthlyGarzaTotals({
    DateTime? month,
  }) async {
    try {
      Map<String, dynamic> response = await apiClient.get(
        _getMonthlyGarzaTotals,
        authRequired: true,
        queryParams: month == null
            ? null
            : {"month": month.toIso8601String().split("T").first},
      );

      return MonthlyGarzaTotalEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<SaleEntity> findSaleByPhone(String folio) async {
    try {
      Map<String, dynamic> response = await apiClient.get(
        "$_salesPath/$folio",
        authRequired: true,
      );

      return SaleEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<SaleEntity>> listByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) => PaginatedApi.all(
    (page) => listSalesPage(
      page: page,
      limit: 100,
      startDate: startDate,
      endDate: endDate,
    ),
  );

  Future<double> quotSale(
    WaterType waterType,
    UnitOfMeasurement unitOfMeasurement,
    double quantity,
    int? clientId,
  ) async {
    Map<String, dynamic> body = {
      "water_type": waterType.name,
      "unit_of_measurement": unitOfMeasurement.name,
      "quantity": quantity,
    };

    if (clientId != null) body["client_id"] = clientId;

    Map<String, dynamic> response = await apiClient.post(
      _salesQuotePath,
      authRequired: true,
      body: body,
    );

    return response["total"];
  }

  Future<SaleEntity> createSale(
    SaleInfoDto dto, {
    required String idempotencyKey,
  }) async {
    Map<String, dynamic> response = await apiClient.post(
      _salesPath,
      authRequired: true,
      body: dto.toJson(),
      headers: {'Idempotency-Key': idempotencyKey},
    );

    return SaleEntity.fromMap(response);
  }

  // Dispatch
  Future<DispatchValidateEntity> validateDispatch(String barcode) async {
    Map<String, dynamic> response = await apiClient.get(
      _dispatchValidatePath(barcode),
      authRequired: true,
    );

    return DispatchValidateEntity.fromMap(response);
  }

  Future<SaleEntity> dispatch(String barcode, int garzaNumber) async {
    Map<String, dynamic> response = await apiClient.post(
      _dispatchPath(barcode),
      authRequired: true,
      body: {"garza_number": garzaNumber},
    );

    return SaleEntity.fromMap(response);
  }

  // Credits
  Future<PageResult<CreditEntity>> getPendingCreditsPage({
    int page = 1,
    int limit = 20,
    CreditStatus status = CreditStatus.pending,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = search?.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (query != null && query.runes.length > 45) {
      throw AppException(
        message: 'El cliente debe tener como máximo 45 caracteres',
      );
    }
    return PaginatedApi.get(
      apiClient,
      _getPendingCreditsPath,
      CreditEntity.fromMap,
      page: page,
      limit: limit,
      filters: {
        'status': status.name,
        if (query != null && query.isNotEmpty) 'search': query,
        if (startDate != null && endDate != null)
          ...DateRangeQuery.fromDates(startDate: startDate, endDate: endDate),
      },
    );
  }

  Future<List<CreditEntity>> getPendingCredits({
    DateTime? startDate,
    DateTime? endDate,
  }) => PaginatedApi.all(
    (page) => getPendingCreditsPage(
      page: page,
      limit: 100,
      startDate: startDate,
      endDate: endDate,
    ),
  );

  Future<PageResult<CreditPaymentEntity>> getCreditPaymentsPage(
    String folio, {
    int page = 1,
    int limit = 20,
  }) => PaginatedApi.get(
    apiClient,
    _listCreditPaymentsPath(folio),
    CreditPaymentEntity.fromMap,
    page: page,
    limit: limit,
  );

  Future<List<CreditPaymentEntity>> getCreditPayments(String folio) =>
      PaginatedApi.all(
        (page) => getCreditPaymentsPage(folio, page: page, limit: 100),
      );

  Future<PageResult<CreditEntity>> listPendingCreditSalesByClientPage(
    int clientId, {
    int page = 1,
    int limit = 20,
  }) => PaginatedApi.get(
    apiClient,
    _listPendingCreditSalesByClientPath(clientId),
    CreditEntity.fromMap,
    page: page,
    limit: limit,
  );

  Future<List<CreditEntity>> listPendingCreditSalesByClient(int clientId) =>
      PaginatedApi.all(
        (page) => listPendingCreditSalesByClientPage(
          clientId,
          page: page,
          limit: 100,
        ),
      );

  Future<void> createCreditPayment(
    String folio,
    PaymentMethod method,
    double total,
  ) async {
    try {
      Map<String, dynamic> body = {
        "payment_method": method.name,
        "amount": total,
      };

      await apiClient.post(
        _createCreditPaymentPath(folio),
        authRequired: true,
        body: body,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<void> createBulkCreditPayment({
    required List<String> folios,
    required PaymentMethod method,
    required double total,
    required String idempotencyKey,
  }) async {
    try {
      await apiClient.post(
        _bulkCreditPaymentsPath,
        authRequired: true,
        headers: {"Idempotency-Key": idempotencyKey},
        body: {"payment_method": method.name, "folios": folios, "total": total},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
