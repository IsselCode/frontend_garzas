import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/generate_ticket_dispatch_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/ctrl_response.dart';
import '../../../commons/text_back_button.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../../admin/clean/entities/sale_entity.dart';

class FinishDispatchView extends StatelessWidget {

  FinishDispatchView();

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
    UnitOfMeasurement unit = dispatchController.dispatchValidate!.unitOfMeasurement;

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
                        Text("Tipo de Agua", style: textTheme.titleMedium,),
                        IsselTextFormField(
                          hintText: "Nombre del cliente",
                          controller: TextEditingController(text: unit.dp),
                          readOnly: true,
                        ),
                        Text("Cantidad en ${unit == UnitOfMeasurement.cubic_meters ? "Metros Cubicos" : "Galones"}", style: textTheme.titleMedium,),
                        IsselTextFormField(
                          hintText: "Nombre del cliente",
                          controller: TextEditingController(text: dispatchController.dispatchValidate!.quantity.toString()),
                          readOnly: true,
                        ),
                        Text("Garza", style: textTheme.titleMedium,),
                        IsselTextFormField(
                          hintText: "Garza",
                          controller: TextEditingController(text: dispatchController.selectedGarza!.title),
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
                      gradient: AppGradients.primaryToSecondary
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 30,
                          children: [
                            Text("Realizar llenado", style: textTheme.displaySmall?.copyWith(color: colorScheme.onPrimary),),

                            IsselButton(
                              text: "Llenar",
                              focusNode: buttonFocus,
                              onTap: () => dispatchWater(context),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              )

            ],
          ),
          // AppBar
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton()
          ),
        ],
      ),
    );
  }

  void dispatchWater(BuildContext context) async {
    DispatchController dispatchController = context.read();
    CtrlResponse<SaleEntity> response = await dispatchController.dispatch();

    if (response.success){
      NavigationService navigationService = locator();
      navigationService.pushAndRemoveUntil(GenerateTicketDispatchView());
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }

  }

}
