import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';

class ClientsApi {
  final ApiClient apiClient;

  ClientsApi({required this.apiClient});

  final String _clientsPath = "/clients";

  Future<List<ClientEntity>> listClients({int? limit, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams["limit"] = limit;
    if (search != null && search.trim().isNotEmpty) {
      queryParams["search"] = search.trim();
    }

    try {
      List response = await apiClient.get(
        _clientsPath,
        authRequired: true,
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      return response.map((e) => ClientEntity.fromMap(e)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<ClientEntity> createClient(
    String commercialName,
    double potableGalPricing,
    double potableLiterPricing,
    double pozoGalPricing,
    double pozoLiterPricing,
  ) async {
    Map<String, dynamic> body = {
      "commercial_name": commercialName,
      "potable_gal_pricing": potableGalPricing,
      "potable_liter_pricing": potableLiterPricing,
      "pozo_gal_pricing": pozoGalPricing,
      "pozo_liter_pricing": pozoLiterPricing,
    };

    Map<String, dynamic> response = await apiClient.post(
      _clientsPath,
      authRequired: true,
      body: body,
    );

    return ClientEntity.fromMap(response);
  }

  Future<void> deleteClientById(int id) async {
    await apiClient.delete("$_clientsPath/$id", authRequired: true);
  }

  Future<ClientEntity> updateClientById(
    int clientId,
    String commercialName,
    double potableGalPricing,
    double potableLiterPricing,
    double pozoGalPricing,
    double pozoLiterPricing,
  ) async {
    Map<String, dynamic> body = {
      "commercial_name": commercialName,
      "potable_gal_pricing": potableGalPricing,
      "potable_liter_pricing": potableLiterPricing,
      "pozo_gal_pricing": pozoGalPricing,
      "pozo_liter_pricing": pozoLiterPricing,
    };

    body.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    Map<String, dynamic> response = await apiClient.patch(
      "$_clientsPath/$clientId",
      authRequired: true,
      body: body,
    );

    return ClientEntity.fromMap(response);
  }
}
