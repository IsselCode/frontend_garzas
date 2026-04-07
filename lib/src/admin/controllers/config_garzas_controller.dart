import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';

import '../../../inject_container.dart';

class ConfigGarzasController extends ChangeNotifier {

  GarzasApi garzasApi;

  ConfigGarzasController({
    required this.garzasApi,
  });

  List<ConfigGarzaEntity> configGarzas = [];

  Future<CtrlResponse> loadConfigGarzas() async {
    try {

      List<ConfigGarzaEntity> tempConfigGarzas = await garzasApi.listGarzas();
      configGarzas = tempConfigGarzas;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> updateGarza(BuildContext context, int number, {GarzaType? garzaType, WaterType? waterType, UnitOfMeasurement? unitOfMeasurement,}) async {

    final indexConfig = configGarzas.indexWhere((element) => element.number == number,);

    if (indexConfig == -1) {
      return CtrlResponse(
        success: false,
        message: "Configuracion de garza inexistente",
      );
    }

    final previousConfig = configGarzas[indexConfig];
    final newConfig = previousConfig.updated(
      garzaType: garzaType,
      waterType: waterType,
      unitOfMeasurement: unitOfMeasurement,
    );

    if (newConfig == previousConfig) {
      return CtrlResponse(success: true);
    }

    configGarzas[indexConfig] = newConfig;
    notifyListeners();

    try {

      await garzasApi.updateGarzaByNumber(newConfig.number, newConfig.garzaType, newConfig.waterType, newConfig.unitOfMeasurement);

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      configGarzas[indexConfig] = previousConfig;
      notifyListeners();
      ToastService toastService = locator();
      toastService.error(e.message);
      return CtrlResponse(success: false, message: e.message);
    } catch (_) {
      configGarzas[indexConfig] = previousConfig;
      notifyListeners();
      return CtrlResponse(success: false, message: "No fue posible actualizar la configuracion de la garza",
      );
    }
  }

}
