import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/statistics_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';

class SalesApi {
  final ApiClient apiClient;

  SalesApi({required this.apiClient});

  final String _salesPath = "/sales";
  final String _salesQuotePath = "/sales/quote";
  final String _salesByDateRangePath = "/sales/range";
  final String _getMonthlyPaymentTotalsPath = "/sales/monthly-payment-totals";

  Future<List<SaleEntity>> listSales() async {

    try {

      List response = await apiClient.get(
        _salesPath,
        authRequired: true,
      );

      return response.map((e) => SaleEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<StatisticsEntity> getMonthlyPaymentTotals() async {

    try {

      Map<String, dynamic> response = await apiClient.get(
        _getMonthlyPaymentTotalsPath,
        authRequired: true,
      );

      return StatisticsEntity.fromMap(response);
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

  Future<List<SaleEntity>> listByDateRange(DateTime startDate, DateTime endDate) async {

    String start = startDate.toIso8601String().split("T").first;
    String end = endDate.toIso8601String().split("T").first;

    try {
      List response = await apiClient.get(
        _salesByDateRangePath,
        authRequired: true,
        queryParams: {"start_date": start, "end_date": end}
      );

      return response.map((e) => SaleEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<double> quotSale(WaterType waterType, UnitOfMeasurement unitOfMeasurement, double quantity, String? clientPhone) async {

    Map<String, dynamic> body = {
      "water_type": waterType.name,
      "unit_of_measurement": unitOfMeasurement.name,
      "quantity": quantity,
    };

    if (clientPhone != null) body["client_phone"] = clientPhone;

    Map<String, dynamic> response = await apiClient.post(
      _salesQuotePath,
      authRequired: true,
      body: body
    );

    return response["total"];

  }

  Future<SaleEntity> createSale(SaleInfoDto dto) async {

    Map<String, dynamic> response = await apiClient.post(
      _salesPath,
      authRequired: true,
      body: dto.toJson()
    );

    return SaleEntity.fromMap(response);

  }


}
