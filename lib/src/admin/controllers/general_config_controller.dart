import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/general_config_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/data/general_api.dart';

class GeneralConfigController extends ChangeNotifier {

  GeneralApi generalApi;

  GeneralConfigController({
    required this.generalApi,
  });

  GeneralConfigEntity? generalConfigEntity;

  Future<CtrlResponse> loadGeneralConfig() async {

    try {
      if (generalConfigEntity != null) {
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
          notifyListeners();
        },);
        return CtrlResponse(success: true);
      }

      GeneralConfigEntity tempConfig = await generalApi.getConfig();

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
      GeneralConfigLogField.waterSupply => previousConfig.copyWith(waterSupply: value),
      GeneralConfigLogField.userCreated => previousConfig.copyWith(userCreated: value),
      GeneralConfigLogField.userDeleted => previousConfig.copyWith(userDeleted: value),
      GeneralConfigLogField.userModified => previousConfig.copyWith(userModified: value),
      GeneralConfigLogField.login => previousConfig.copyWith(login: value),
      GeneralConfigLogField.logout => previousConfig.copyWith(logout: value),
      GeneralConfigLogField.clientCreated => previousConfig.copyWith(clientCreated: value),
      GeneralConfigLogField.clientDeleted => previousConfig.copyWith(clientDeleted: value),
      GeneralConfigLogField.clientModified => previousConfig.copyWith(clientModified: value),
      GeneralConfigLogField.cashRegisterOpening => previousConfig.copyWith(cashRegisterOpening: value),
      GeneralConfigLogField.cashRegisterClosing => previousConfig.copyWith(cashRegisterClosing: value),
      GeneralConfigLogField.saleCreated => previousConfig.copyWith(saleCreated: value),
      GeneralConfigLogField.dispatchCompleted => previousConfig.copyWith(dispatchCompleted: value),
    };

    if (newConfig == previousConfig) {
      return CtrlResponse(success: true);
    }

    generalConfigEntity = newConfig;
    notifyListeners();

    try {
      await generalApi.updateConfig(newConfig);

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

      await generalApi.updateConfig(newConfig);

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      generalConfigEntity = previousConfig;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> updatePrices(double potableGalPricing, double potableM3Pricing, double pozoGalPricing, double pozoM3Pricing) async {

    GeneralConfigEntity previousConfig = generalConfigEntity!;

    GeneralConfigEntity newConfig = generalConfigEntity!.copyWith(
      potableGalPricing: potableGalPricing,
      potableM3Pricing: potableM3Pricing,
      pozoGalPricing: pozoGalPricing,
      pozoM3Pricing: pozoM3Pricing
    );

    if (newConfig == previousConfig) {
      return CtrlResponse(success: true);
    }

    generalConfigEntity = newConfig;
    notifyListeners();

    try {
      await generalApi.updateConfig(newConfig);
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      generalConfigEntity = previousConfig;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    }
  }



}
