import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/pie_widget.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/credits_controller.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../clean/dialogs/date_range_dialog.dart';

class CreditsView extends StatefulWidget {
  const CreditsView({super.key});

  @override
  State<CreditsView> createState() => _CashRegisterViewState();
}

class _CashRegisterViewState extends State<CreditsView> {

  late Future<CtrlResponse> _getCredits;
  DateTimeRange? _salesDateRange;

  @override
  void initState() {
    super.initState();
    CreditsController creditsController = context.read();
    _getCredits = creditsController.getCredits();
  }

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    // Controllers
    CreditsController creditsController = context.watch();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: kWindowCaptionHeight + 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            // App Bar
            Column(
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextBackButton(),
                  ],
                ),
              ],
            ),
            // Body
            Expanded(
              child: Row(
                spacing: 20,
                children: [
                  // Left - Cuts
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.surface
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Titulo
                              Text("Creditos", style: textTheme.titleLarge,),
                              // Rango de fecha
                              IsselPill(
                                text: _formatSalesDateRange(),
                                color: colorScheme.surfaceContainer,
                                onTap: () => _openSalesDateRangeDialog(),
                              ),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder(
                              future: _getCredits,
                              builder: (context, snapshot) {
                            
                                if (snapshot.connectionState == ConnectionState.waiting){
                                  return ListView.separated(
                                    itemCount: 5,
                                    separatorBuilder: (context, index) => const SizedBox(height: 10,),
                                    itemBuilder: (context, index) {
                                      return IsselShimmer(width: double.infinity, height: 50);
                                    },
                                  );
                                }
                            
                                if (!snapshot.data!.success) {
                                  return Center(child: Text(snapshot.data!.message!),);
                                }
                            
                                if (creditsController.showedCredits.isEmpty) {
                                  return Center(child: Text("No hay creditos disponibles"),);
                                }
                            
                                List<CreditEntity> credits = creditsController.showedCredits;
                            
                                return IsselTableWidget(
                                    color: colorScheme.surfaceContainer,
                                    onTapRow: (index) => loadCreditPayments(credits[index]),
                                    header: IsselHeaderTable(
                                      titleHeaders: ["Cliente", "Total", "Pagado", "Pendiente", "Fecha"],
                                      colorPills: colorScheme.surfaceContainer,
                                    ),
                                    rows: credits.map((credit) {
                                      return IsselRowTable(
                                        cells: [
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: credit.clientPhone
                                          ),
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: credit.total.toStringAsFixed(2)
                                          ),
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: credit.amountPaid.toStringAsFixed(2)
                                          ),
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: credit.salePendingAmount.toStringAsFixed(2)
                                          ),
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: DateFormat("dd-MM-yy").format(credit.createdAt)
                                          ),
                                        ]
                                      );
                                    },).toList()
                                );
                            
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right Summary
                  Expanded(
                    flex: 2,
                    child: creditsController.creditPayments.isEmpty || creditsController.selectedCredit == null
                      ? Container(
                        child: Center(
                          child: Text(creditsController.selectedCredit != null ? "No hay ningun pago" : "Selecciona un credito para ver información"),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorScheme.surface
                        ),
                      )
                      : IsselTableWidget(
                      color: colorScheme.surfaceContainer,
                      header: IsselHeaderTable(
                        titleHeaders: ["Recibido por", "Método", "Cantidad", "Fecha"],
                        colorPills: colorScheme.surfaceContainer,
                      ),
                      rows: creditsController.creditPayments.map((payment) {
                        return IsselRowTable(
                            cells: [
                              IsselPill(
                                color: colorScheme.surface,
                                text: payment.receivedByUsername
                              ),
                              IsselPill(
                                color: colorScheme.surface,
                                text: payment.paymentMethod.label
                              ),
                              IsselPill(
                                color: colorScheme.surface,
                                text: payment.amount.toStringAsFixed(2)
                              ),
                              IsselPill(
                                color: colorScheme.surface,
                                text: DateFormat("dd-MM-yy").format(payment.createdAt)
                              ),
                            ]
                        );
                      },).toList()
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatSalesDateRange() {
    if (_salesDateRange == null) {
      return "Fecha";
    }

    final formatter = DateFormat("dd/MM/yyyy");
    return "${formatter.format(_salesDateRange!.start)} - ${formatter.format(_salesDateRange!.end)}";
  }

  Future<void> _openSalesDateRangeDialog() async {
    final CreditsController creditsController = context.read();
    final ToastService toastService = locator();
    final DateRangeDialogResult? result =
    await showDialog<DateRangeDialogResult>(
      context: context,
      builder: (context) => DateRangeDialog(
        initialRange: _salesDateRange,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (result == null) return;

    if (result.cleared) {
      creditsController.clearSalesDateRange();
      setState(() {
        _salesDateRange = null;
      });
      return;
    }

    if (result.range == null) return;

    final CtrlResponse response = await creditsController.getCutsByDateRange(
      startDate: result.range!.start,
      endDate: result.range!.end,
    );

    if (response.success) {
      toastService.success("Creditos filtrados correctamente");
    } else {
      toastService.error(
        response.message ?? "No se pudieron filtrar las ventas",
      );
      return;
    }

    setState(() {
      _salesDateRange = result.range;
    });
  }

  Future<void> loadCreditPayments(CreditEntity credit) async {

    CreditsController creditsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await creditsController.loadCreditPayments(credit);
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    if (response.success) {
      if (response.message != null) {
        toastService.success(response.message!);
      }
    } else {
      toastService.error(response.message!);
    }

  }

}
