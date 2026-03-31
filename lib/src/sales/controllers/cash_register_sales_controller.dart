import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';

class CashRegisterSalesController extends ChangeNotifier {

  CashRegisterApi cashRegisterApi;

  CashRegisterSalesController({
    required this.cashRegisterApi,
  });

  Future<CtrlResponse> openCut() async {

    try {



      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

}