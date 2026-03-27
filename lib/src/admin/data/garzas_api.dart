import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class GarzasApi {
  final ApiClient apiClient;

  GarzasApi({required this.apiClient});

  final String _garzasPath = "/settings/garzas";

  Future<List<ConfigGarzaEntity>> listGarzas() async {

    try {
      List response = await apiClient.get(
        _garzasPath,
        authRequired: true,
      );

      return response.map((e) => ConfigGarzaEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<ConfigGarzaEntity> updateGarzaByNumber(int number, GarzaType garzaType, WaterType waterType, UnitOfMeasurement unitOfMeasurement) async {

    try {
      Map<String, dynamic> body = {
        "garza_type": garzaType.name,
        "water_type": waterType.name,
        "unit_of_measurement": unitOfMeasurement.name,
      };

      body.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

      Map<String, dynamic> response = await apiClient.patch(
        "$_garzasPath/$number",
        authRequired: true,
        body: body,
      );

      return ConfigGarzaEntity.fromMap(response);
    } on AppException catch(e) {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }


}
