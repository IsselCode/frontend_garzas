import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/scaled_text_style.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/dispatch_session_view.dart';
import 'package:frontend_garzas/src/dispatch/views/home_dispatch_view.dart';
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
    DispatchController dispatchController = context.watch();

    // Data
    WaterType wt = dispatchController.activeWaterType!;
    UnitOfMeasurement unit = dispatchController.activeUnitOfMeasurement!;
    final dispatchedQuantity = dispatchController.activeDispensedQuantity;
    final purchasedQuantity = dispatchController.activeQuantity;
    final pendingDispatch = dispatchController.selectedPendingDispatch;
    final quantityText =
        pendingDispatch != null && pendingDispatch.quantity == null
        ? 'Manual'
        : "${_formatQuantity(dispatchedQuantity)}/${_formatQuantity(purchasedQuantity)}";

    return Scaffold(
      body: Stack(
        children: [
          // Body
          LayoutBuilder(
            builder: (context, constraints) {
              final scaleFactor = (constraints.maxWidth / 1366).clamp(1.0, 1.7);
              final leftPanelWidth = 320 * scaleFactor;
              final rightPanelWidth = 360 * scaleFactor;
              final leftSpacing = 20 * scaleFactor;
              final rightSpacing = 30 * scaleFactor;
              final controlHeight = 60 * scaleFactor;

              return Row(
                children: [
                  //* Left
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: leftPanelWidth,
                        child: Column(
                          spacing: leftSpacing,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tipo de Agua",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            IsselTextFormField(
                              height: controlHeight,
                              hintText: "Nombre del cliente",
                              controller: TextEditingController(text: wt.dp),
                              readOnly: true,
                            ),
                            if (pendingDispatch != null) ...[
                              Text(
                                "Referencia",
                                style: scaledTextStyle(
                                  textTheme.titleMedium,
                                  scaleFactor,
                                ),
                              ),
                              IsselTextFormField(
                                height: controlHeight,
                                hintText: "Referencia",
                                controller: TextEditingController(
                                  text: pendingDispatch.plateOrUnitReference,
                                ),
                                readOnly: true,
                              ),
                            ],
                            Text(
                              "Cantidad en ${unit == UnitOfMeasurement.liters ? "Litros" : "Galones"}",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            IsselTextFormField(
                              height: controlHeight,
                              hintText: "Cantidad",
                              controller: TextEditingController(
                                text: quantityText,
                              ),
                              readOnly: true,
                            ),
                            Text(
                              "Garza",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            IsselTextFormField(
                              height: controlHeight,
                              hintText: "Garza",
                              controller: TextEditingController(
                                text: dispatchController.activeGarzaTitle,
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
                          width: rightPanelWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: rightSpacing,
                            children: [
                              Text(
                                "Continuar despacho",
                                textAlign: TextAlign.center,
                                style: scaledTextStyle(
                                  textTheme.displaySmall,
                                  scaleFactor,
                                  color: colorScheme.onPrimary,
                                ),
                              ),

                              IsselButton(
                                height: controlHeight,
                                text:
                                    dispatchController.isCreatingDispatchSession
                                    ? "Procesando..."
                                    : "Continuar",
                                focusNode: buttonFocus,
                                onTap:
                                    dispatchController.isCreatingDispatchSession
                                    ? null
                                    : () => dispatchWater(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // AppBar
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton(
              onTap: pendingDispatch == null ? null : _goToDispatchHome,
            ),
          ),
        ],
      ),
    );
  }

  void dispatchWater(BuildContext context) async {
    DispatchController dispatchController = context.read();
    if (dispatchController.isCreatingDispatchSession) return;

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

  void _goToDispatchHome() {
    locator<NavigationService>().pushAndRemoveUntil(const HomeDispatchView());
  }

  String _formatQuantity(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
