import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/general_config_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

class GeneralConfigController extends ChangeNotifier {

  GeneralConfigEntity? generalConfigEntity;

  Future<CtrlResponse> loadGeneralConfig() async {

    try {

      GeneralConfigEntity fakeConfig = GeneralConfigEntity(
        loadData: false,
        userCreated: false,
        userDeleted: false,
        login: false,
        logout: false,
        clientCreated: false,
        clientDeleted: false,
        clientModified: false,
        businessName: "PABN PURIFICADORA AGUAS Y BEBIDAS",
        businessAddress: "Monzón 8100 EL RUBI 220000",
        extraInfo1: "Gracias por su compra.",
        extraInfo2: "¡Vuelva Pronto!"
      );

      GeneralConfigEntity tempConfig = await Future.delayed(const Duration(seconds: 1), () => fakeConfig,);

      generalConfigEntity = tempConfig;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> updatedLogs({
    required GeneralConfigLogField field,
    required bool value,
  }) async {

    GeneralConfigEntity previousConfig = generalConfigEntity!;
    GeneralConfigEntity newConfig = switch (field) {
      GeneralConfigLogField.loadData => previousConfig.copyWith(loadData: value),
      GeneralConfigLogField.userCreated => previousConfig.copyWith(userCreated: value),
      GeneralConfigLogField.userDeleted => previousConfig.copyWith(userDeleted: value),
      GeneralConfigLogField.login => previousConfig.copyWith(login: value),
      GeneralConfigLogField.logout => previousConfig.copyWith(logout: value),
      GeneralConfigLogField.clientCreated => previousConfig.copyWith(clientCreated: value),
      GeneralConfigLogField.clientDeleted => previousConfig.copyWith(clientDeleted: value),
      GeneralConfigLogField.clientModified => previousConfig.copyWith(clientModified: value),
    };

    if (newConfig == previousConfig) {
      return CtrlResponse(success: true);
    }

    generalConfigEntity = newConfig;
    notifyListeners();

    try {

      // Todo: implementar método desde el backend
      await Future.delayed(const Duration(seconds: 1));

      throw AppException(message: "ERROR SIMULADO");

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      generalConfigEntity = previousConfig;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> updateTicketInfo(String businessName, String businessAddress, String extraInfo1, String extraInfo2) async {

    GeneralConfigEntity previousConfig = generalConfigEntity!;
    GeneralConfigEntity newConfig = generalConfigEntity!.copyWith(businessName: businessName, businessAddress: businessAddress, extraInfo1: extraInfo1, extraInfo2: extraInfo2);

    if (newConfig == previousConfig) {
      return CtrlResponse(success: true);
    }

    generalConfigEntity = newConfig;
    notifyListeners();

    try {

      // Todo: implementar método desde el backend
      await Future.delayed(const Duration(seconds: 1));

      throw AppException(message: "ERROR SIMULADO");

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      generalConfigEntity = previousConfig;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    }
  }

}
