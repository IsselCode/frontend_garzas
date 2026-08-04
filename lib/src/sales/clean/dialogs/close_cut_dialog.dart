import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/tickets/cash_cut_ticket.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/sales/clean/entities/closed_cut_summary_entity.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../core/app/consts.dart';
import '../../../../core/services/regex_service.dart';
import '../../../../inject_container.dart';
import '../entities/active_cut_summary_entity.dart';

class CloseCutDialog extends StatefulWidget {
  const CloseCutDialog({super.key});

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
  void dispose() {
    cashCtrl.dispose();
    cardCtrl.dispose();
    super.dispose();
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
        width: 650,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return IsselShimmer(width: double.infinity, height: 250);
                  }

                  if (!snapshot.data!.success) {
                    return SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Center(child: Text(snapshot.data!.message!)),
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
                                  flex: 2,
                                  child: _CutAmountPill(
                                    asset: AppAssets.cash,
                                    amount: cut.openingAmount,
                                  ),
                                ),
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
                                  child: _CutAmountPill(
                                    asset: AppAssets.cash,
                                    amount: cut.expectedCashTotal,
                                    highlight: true,
                                  ),
                                ),
                                Expanded(
                                  child: _CutAmountPill(
                                    asset: AppAssets.card,
                                    amount: cut.cardTotal,
                                    highlight: true,
                                  ),
                                ),
                                Expanded(
                                  child: _CutAmountPill(
                                    asset: AppAssets.credit,
                                    amount: cut.creditTotal,
                                    highlight: true,
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
                                      inputFormatters: [
                                        RegexService.positiveNumberFormatter,
                                      ],
                                      validator: (value) =>
                                          RegexService.positiveNumberValidator(
                                            value,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: IsselTextFormField(
                                      fillColor: colorScheme.surfaceContainer,
                                      controller: cardCtrl,
                                      hintText: "Tarjeta",
                                      height: 50,
                                      inputFormatters: [
                                        RegexService.positiveNumberFormatter,
                                      ],
                                      validator: (value) =>
                                          RegexService.positiveNumberValidator(
                                            value,
                                          ),
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
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
              Divider(color: colorScheme.outline),

              //* Realizar corte
              IsselButton(
                text: "Realizar Corte",
                textColor: colorScheme.onPrimary,
                color: colorScheme.primary,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final toastService = locator<ToastService>();
                  final printerService = locator<PrinterService>();
                  final loaderOverlay = context.loaderOverlay;
                  final printer = await printerService.getSelectedPrinter();

                  if (printer == null) {
                    toastService.error("No hay ninguna impresora seleccionada");
                    return;
                  }

                  final declaredCashTotal = double.parse(cashCtrl.text);
                  final declaredCardTotal = double.parse(cardCtrl.text);

                  loaderOverlay.show();

                  CtrlResponse<ClosedCutSummaryEntity> response =
                      await cashRegisterController.closeCut(
                        declaredCashTotal,
                        declaredCardTotal,
                      );

                  loaderOverlay.hide();

                  if (response.success) {
                    try {
                      final ticket = CashCutTicketEntity(
                        summary: response.element!,
                        user: authController.session!,
                        declaredCashTotal: declaredCashTotal,
                        declaredCardTotal: declaredCardTotal,
                        closedAt: DateTime.now(),
                      );

                      await Printing.directPrintPdf(
                        printer: printer,
                        format: cashCutTicketPageFormat,
                        dynamicLayout: false,
                        usePrinterSettings: true,
                        onLayout: (format) =>
                            cashCutTicketPdf(ticket, pageFormat: format),
                      );

                      await authController.logout();
                    } catch (_) {
                      toastService.error(
                        "El corte se realizo, pero no se pudo imprimir el ticket",
                      );
                      await authController.logout();
                    }
                  } else {
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

class _CutAmountPill extends StatelessWidget {
  const _CutAmountPill({
    required this.asset,
    required this.amount,
    this.highlight = false,
  });

  final String asset;
  final double? amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return IsselPill(
      color: highlight
          ? colorScheme.primary.withValues(alpha: 0.12)
          : colorScheme.surfaceContainer,
      widget: Row(
        spacing: 10,
        children: [
          if (amount != null) Image.asset(asset, width: 24, height: 24),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                amount == null
                    ? ""
                    : amount == 0
                    ? "-"
                    : "\$${amount!.toStringAsFixed(2)}",
                maxLines: 1,
                style: textTheme.titleSmall?.copyWith(
                  color: highlight
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
