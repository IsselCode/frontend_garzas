import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';

class ClientsApi {
  final ApiClient apiClient;

  ClientsApi({required this.apiClient});

  final String _clientsPath = "/clients";

  Future<List<ClientEntity>> listClients({int? limit}) async {

    Map<String, dynamic>? queryParams;

    if (limit != null) queryParams = {"limit": limit};

    try {
      List response = await apiClient.get(
        _clientsPath,
        authRequired: true,
        queryParams:  queryParams
      );

      return response.map((e) => ClientEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<ClientEntity> getClientByPhone(String phone) async {

    Map<String, dynamic> response = await apiClient.get(
      "$_clientsPath/$phone",
      authRequired: true,
    );

    return ClientEntity.fromMap(response);

  }

  Future<ClientEntity> createClient(String name, String phone, double potableGalPricing, double potableM3Pricing, double pozoGalPricing, double pozoM3Pricing) async {

    Map<String, dynamic> body = {
      "name": name,
      "phone": phone,
      "potable_gal_pricing": potableGalPricing,
      "potable_m3_pricing": potableM3Pricing,
      "pozo_gal_pricing": pozoGalPricing,
      "pozo_m3_pricing": pozoM3Pricing,
    };

    Map<String, dynamic> response = await apiClient.post(
      _clientsPath,
      authRequired: true,
      body: body
    );

    return ClientEntity.fromMap(response);
  }

  Future<void> deleteClientByPhone(String phone) async {

    await apiClient.delete(
      "$_clientsPath/$phone",
      authRequired: true
    );

  }

  Future<ClientEntity> updateClientByPhone(String clientPhone, String name, String newPhone, double potableGalPricing, double potableM3Pricing, double pozoGalPricing, double pozoM3Pricing) async {

    Map<String, dynamic> body = {
      "name": name,
      "phone": newPhone,
      "potable_gal_pricing": potableGalPricing,
      "potable_m3_pricing": potableM3Pricing,
      "pozo_gal_pricing": pozoGalPricing,
      "pozo_m3_pricing": pozoM3Pricing,
    };

    body.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    Map<String, dynamic> response = await apiClient.patch(
      "$_clientsPath/$clientPhone",
      authRequired: true,
      body: body,
    );

    return ClientEntity.fromMap(response);

  }


}
