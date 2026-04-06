import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/data/auth_api.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../core/app/consts.dart';
import '../../../../core/services/regex_service.dart';
import '../../../../inject_container.dart';
import '../entities/active_cut_summary_entity.dart';

class CloseCutDialog extends StatefulWidget {


  CloseCutDialog({super.key});

  @override
  State<CloseCutDialog> createState() => _ConfigPrinterDialogState();
}

class _ConfigPrinterDialogState extends State<CloseCutDialog> {

  late Future<CtrlResponse<ActiveCutSummaryEntity>> _getActiveCutSummary;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController cashCtrl = TextEditingController();
  final TextEditingController cardCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    CashRegisterController cashRegisterController = context.read();
    _getActiveCutSummary = cashRegisterController.getActiveCutSummary();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    CashRegisterController cashRegisterController = context.read();
    AuthController authController = context.read();

    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            spacing: 15,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titulo
              Flex(
                direction: Axis.vertical,
                spacing: 10,
                children: [
                  //* Titulo
                  Text(
                    "Finalizar Corte",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  //* Description
                  Text(
                    "Ingresa los datos",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              FutureBuilder(
                future: _getActiveCutSummary,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting){
                    return IsselShimmer(
                      width: double.infinity,
                      height: 250
                    );
                  }
                  
                  if (!snapshot.data!.success) {
                    return SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Center(child: Text(snapshot.data!.message!),),
                    );
                  }
                  
                  ActiveCutSummaryEntity cut = snapshot.data!.element!; 

                  return Flex(
                    direction: Axis.vertical,
                    spacing: 15,
                    children: [
                      // Cantidad Inicial
                      Flex(
                        spacing: 5,
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cantidad inicial",
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: IsselPill(
                                    widget: Row(
                                      spacing: 10,
                                      children: [
                                        Image.asset(AppAssets.cash, width: 24, height: 24,),
                                        Text(cut.openingAmount.toStringAsFixed(2))
                                      ],
                                    ),
                                    color: colorScheme.surfaceContainer,
                                  ),
                                ),
                                Spacer(),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Body
                      Flex(
                        spacing: 5,
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Totales",
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: IsselPill(
                                    widget: Row(
                                      spacing: 10,
                                      children: [
                                        Image.asset(AppAssets.cash, width: 24, height: 24,),
                                        Text(cut.expectedCashTotal.toStringAsFixed(2))
                                      ],
                                    ),
                                    color: colorScheme.surfaceContainer,
                                  ),
                                ),
                                Expanded(
                                  child: IsselPill(
                                    widget: Row(
                                      spacing: 10,
                                      children: [
                                        Image.asset(AppAssets.card, width: 24, height: 24,),
                                        Text(cut.cardTotal.toStringAsFixed(2))
                                      ],
                                    ),
                                    color: colorScheme.surfaceContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Cantidades a declarar
                      Form(
                        key: _formKey,
                        child: Flex(
                          spacing: 5,
                          direction: Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cantidades a declarar",
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                spacing: 10,
                                children: [
                                  Expanded(
                                    child: IsselTextFormField(
                                      controller: cashCtrl,
                                      fillColor: colorScheme.surfaceContainer,
                                      hintText: "Efectivo",
                                      height: 50,
                                      inputFormatters: [RegexService.positiveNumberFormatter],
                                      validator: (value) => RegexService.positiveNumberValidator(value),
                                    ),
                                  ),
                                  Expanded(
                                    child: IsselTextFormField(
                                      fillColor: colorScheme.surfaceContainer,
                                      controller: cardCtrl,
                                      hintText: "Tarjeta",
                                      height: 50,
                                      inputFormatters: [RegexService.positiveNumberFormatter],
                                      validator: (value) => RegexService.positiveNumberValidator(value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                },
              ),

              // Divisor
              Divider(color: colorScheme.outline,),

              //* Realizar corte
              IsselButton(
                text: "Realizar Corte",
                textColor: colorScheme.onPrimary,
                color: colorScheme.primary,
                onTap: () async {

                  if (!_formKey.currentState!.validate()){
                    return;
                  }

                  context.loaderOverlay.show();

                  CtrlResponse response = await cashRegisterController.closeCut(
                    double.parse(cashCtrl.text),
                    double.parse(cardCtrl.text)
                  );

                  context.loaderOverlay.hide();

                  if (response.success) {
                    authController.logout();
                  } else {
                    ToastService toastService = locator();
                    toastService.error(response.message!);
                  }

                },
              ),

              //* Cancelar
              IsselButton(
                text: "Volver",
                color: Colors.transparent,
                textColor: colorScheme.onSurface,
                onTap: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
