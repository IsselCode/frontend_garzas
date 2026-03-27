import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_info_entity.dart';

class SalesApi {
  final ApiClient apiClient;

  SalesApi({required this.apiClient});

  final String _salesPath = "/sales";
  final String _salesByDateRangePath = "/sales/range";

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


// Future<ClientEntity> getClientByPhone(String phone) async {
  //
  //   Map<String, dynamic> response = await apiClient.get(
  //     "$_clientsPath/$phone",
  //     authRequired: true,
  //   );
  //
  //   return ClientEntity.fromMap(response);
  //
  // }
  //
  // Future<ClientEntity> createClient(String name, String phone, double potableGalPricing, double potableLiterPricing, double pozoGalPricing, double pozoLiterPricing) async {
  //
  //   Map<String, dynamic> body = {
  //     "name": name,
  //     "phone": phone,
  //     "potable_gal_pricing": potableGalPricing,
  //     "potable_liter_pricing": potableLiterPricing,
  //     "pozo_gal_pricing": pozoGalPricing,
  //     "pozo_liter_pricing": pozoLiterPricing,
  //   };
  //
  //   Map<String, dynamic> response = await apiClient.post(
  //     _clientsPath,
  //     authRequired: true,
  //     body: body
  //   );
  //
  //   return ClientEntity.fromMap(response);
  // }
  //
  // Future<void> deleteClientByPhone(String phone) async {
  //
  //   await apiClient.delete(
  //     "$_clientsPath/$phone",
  //     authRequired: true
  //   );
  //
  // }
  //
  // Future<ClientEntity> updateClientByPhone(String clientPhone, String name, String newPhone, double potableGalPricing, double potableLiterPricing, double pozoGalPricing, double pozoLiterPricing) async {
  //
  //   Map<String, dynamic> body = {
  //     "name": name,
  //     "phone": newPhone,
  //     "potable_gal_pricing": potableGalPricing,
  //     "potable_liter_pricing": potableLiterPricing,
  //     "pozo_gal_pricing": pozoGalPricing,
  //     "pozo_liter_pricing": pozoLiterPricing,
  //   };
  //
  //   body.removeWhere((key, value) => value == null || (value is String && value.isEmpty));
  //
  //   Map<String, dynamic> response = await apiClient.patch(
  //     "$_clientsPath/$clientPhone",
  //     authRequired: true,
  //     body: body,
  //   );
  //
  //   return ClientEntity.fromMap(response);
  //
  // }


}
