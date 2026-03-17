import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';

class ConfigGarzasController extends ChangeNotifier {
  List<ConfigGarzaEntity> configGarzas = [];

  Future<CtrlResponse> loadConfigGarzas() async {
    try {
      // TODO: CONECTAR CON BACKEND
      List<ConfigGarzaEntity> fakeConfigGarzas = [
        ConfigGarzaEntity(
          title: "Garza 1",
          number: 1,
          garzaType: GarzaType.valvula,
          waterType: WaterType.pozo,
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        ConfigGarzaEntity(
          title: "Garza 2",
          number: 2,
          garzaType: GarzaType.valvula,
          waterType: WaterType.pozo,
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        ConfigGarzaEntity(
          title: "Garza 3",
          number: 3,
          garzaType: GarzaType.valvula,
          waterType: WaterType.pozo,
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
        ConfigGarzaEntity(
          title: "Garza 4",
          number: 4,
          garzaType: GarzaType.valvula,
          waterType: WaterType.pozo,
          unitOfMeasurement: UnitOfMeasurement.gallons,
        ),
      ];

      List<ConfigGarzaEntity> tempConfigGarzas = await Future.delayed(
        const Duration(seconds: 2),
        () => fakeConfigGarzas,
      );
      configGarzas = tempConfigGarzas;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> updateGarza(int number, {GarzaType? garzaType, WaterType? waterType, UnitOfMeasurement? unitOfMeasurement,}) async {
    final indexConfig = configGarzas.indexWhere(
      (element) => element.number == number,
    );

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
      // TODO: Conectar con backend pasando un DTO
      await Future.delayed(const Duration(seconds: 2));

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      configGarzas[indexConfig] = previousConfig;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    } catch (_) {
      configGarzas[indexConfig] = previousConfig;
      notifyListeners();
      return CtrlResponse(
        success: false,
        message: "No fue posible actualizar la configuracion de la garza",
      );
    }
  }

}
