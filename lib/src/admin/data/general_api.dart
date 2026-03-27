import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/general_config_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class GeneralApi {
  final ApiClient apiClient;

  GeneralApi({required this.apiClient});

  final String _generalPath = "/settings/general";

  Future<GeneralConfigEntity> getConfig() async {

    try {
      Map<String, dynamic> response = await apiClient.get(
        _generalPath,
        authRequired: true,
      );

      return GeneralConfigEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<GeneralConfigEntity> updateConfig(GeneralConfigEntity newConfig) async {

    try {

      Map<String, dynamic> body = newConfig.toMap();

      body.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

      Map<String, dynamic> response = await apiClient.patch(
        _generalPath,
        authRequired: true,
        body: body,
      );

      return GeneralConfigEntity.fromMap(response);
    } on AppException catch(e) {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }


}
