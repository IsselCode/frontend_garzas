import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/dispatch_session_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/ctrl_response.dart';
import '../../../commons/text_back_button.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../entities/dispatch_session_entity.dart';

class FinishDispatchView extends StatelessWidget {
  FinishDispatchView({super.key});

  final FocusNode buttonFocus = FocusNode();
  final FocusNode clientMoneyFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;
    // Services

    // Controllers
    DispatchController dispatchController = context.read();

    // Data
    WaterType wt = dispatchController.dispatchValidate!.waterType;
    UnitOfMeasurement unit =
        dispatchController.dispatchValidate!.unitOfMeasurement;
    final dispatchedQuantity = _litersToUnit(
      dispatchController.dispatchValidate!.dispatchedLiters,
      unit,
    );
    final purchasedQuantity = dispatchController.dispatchValidate!.quantity;

    return Scaffold(
      body: Stack(
        children: [
          // Body
          Row(
            children: [
              //* Left
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Tipo de Agua", style: textTheme.titleMedium),
                        IsselTextFormField(
                          hintText: "Nombre del cliente",
                          controller: TextEditingController(text: wt.dp),
                          readOnly: true,
                        ),
                        Text(
                          "Cantidad en ${unit == UnitOfMeasurement.liters ? "Litros" : "Galones"}",
                          style: textTheme.titleMedium,
                        ),
                        IsselTextFormField(
                          hintText: "Nombre del cliente",
                          controller: TextEditingController(
                            text:
                                "${_formatQuantity(dispatchedQuantity)}/${_formatQuantity(purchasedQuantity)}",
                          ),
                          readOnly: true,
                        ),
                        Text("Garza", style: textTheme.titleMedium),
                        IsselTextFormField(
                          hintText: "Garza",
                          controller: TextEditingController(
                            text: dispatchController.selectedGarza!.title,
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //* Right
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryToSecondary,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 360,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 30,
                        children: [
                          Text(
                            "Continuar despacho",
                            textAlign: TextAlign.center,
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),

                          IsselButton(
                            text: "Continuar",
                            focusNode: buttonFocus,
                            onTap: () => dispatchWater(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // AppBar
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton(),
          ),
        ],
      ),
    );
  }

  void dispatchWater(BuildContext context) async {
    DispatchController dispatchController = context.read();
    CtrlResponse<DispatchSessionEntity> response = await dispatchController
        .createDispatchSession();

    if (response.success) {
      NavigationService navigationService = locator();
      navigationService.navigateTo(DispatchSessionView());
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }
  }

  double _litersToUnit(double liters, UnitOfMeasurement unit) {
    switch (unit) {
      case UnitOfMeasurement.liters:
        return liters / 1000;
      case UnitOfMeasurement.gallons:
        return liters / 3.785411784;
    }
  }

  String _formatQuantity(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
