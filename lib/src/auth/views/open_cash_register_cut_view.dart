import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/sales/views/home_sales_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class OpenCashRegisterCutView extends StatelessWidget {
  OpenCashRegisterCutView({super.key});

  final TextEditingController quantity = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ColoredBox(
              color: colorScheme.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 30,
                children: [
                  SizedBox(
                    width: 400,
                    child: Text(
                      "Ingresa la cantidad inicial para comenzar a vender",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Image.asset(AppAssets.cashRegister, width: 200, height: 200,)
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Apertura de corte", style: textTheme.titleLarge),
                    Form(
                      key: formKey,
                      child: Flex(
                        direction: Axis.vertical,
                        spacing: 20,
                        children: [
                          IsselTextFormField(
                            controller: quantity,
                            hintText: "Cantidad inicial",
                            height: 60,
                            inputFormatters: [RegexService.positiveNumberFormatter],
                            validator: (value) => RegexService.positiveNumberValidator(value),
                          ),
                          IsselButton(
                            text: "Abrir corte",
                            onTap: () => openCut(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void openCut(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    context.loaderOverlay.show();
    CashRegisterController cashRegisterController = context.read();

    CtrlResponse response = await cashRegisterController.openCut(double.parse(quantity.text));
    if (!context.mounted) {
      return;
    }

    context.loaderOverlay.hide();

    NavigationService navigationService = locator();
    ToastService toastService = locator();
    TitleBarController titleBarController = context.read();
    if (response.success) {
      navigationService.pushAndRemoveUntil(HomeSalesView());
      titleBarController.notifyListeners();
    }
    if (!response.success) {
      toastService.error(response.message ?? "No fue posible iniciar sesi\u00f3n",);
    }
  }
}
