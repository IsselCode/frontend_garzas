import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/pie_widget.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../clean/dialogs/date_range_dialog.dart';

class CashRegisterView extends StatefulWidget {
  const CashRegisterView({super.key});

  @override
  State<CashRegisterView> createState() => _CashRegisterViewState();
}

class _CashRegisterViewState extends State<CashRegisterView> {

  late Future<CtrlResponse> _getCuts;
  DateTimeRange? _salesDateRange;

  @override
  void initState() {
    super.initState();
    CashRegisterController cashRegisterController = context.read();
    _getCuts = cashRegisterController.getCashRegisterCuts();
  }

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    // Controllers
    CashRegisterController cashRegisterController = context.watch();

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
                    flex: 2,
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
                              Text("Cortes", style: textTheme.titleLarge,),
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
                              future: _getCuts,
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
                            
                                if (cashRegisterController.showedCashRegisterCuts.isEmpty) {
                                  return Center(child: Text("No hay cortes disponibles"),);
                                }
                            
                                List<CashRegisterEntity> cuts = cashRegisterController.showedCashRegisterCuts;
                            
                                return IsselTableWidget(
                                    color: colorScheme.surfaceContainer,
                                    onTapRow: (index) => loadCutSummary(cuts[index]),
                                    header: IsselHeaderTable(
                                      titleHeaders: ["Fecha", "Usuario", "Total"],
                                      colorPills: colorScheme.surfaceContainer,
                                    ),
                                    rows: cuts.map((cut) {
                                      return IsselRowTable(
                                        cells: [
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: DateFormat("dd-MM-yy").format(cut.openedAt)
                                          ),
                                          IsselPill(
                                            color: colorScheme.surface,
                                            text: cut.openedByUsername
                                          ),
                                          IsselPill(
                                            color: colorScheme.surface,
                                            widget: AutoSizeText(
                                              "\$${cut.cardTotal + cut.cashTotal}",
                                              style: textTheme.bodyMedium,
                                              maxLines: 1,
                                            ),
                                          )
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
                    flex: 3,
                    child: cashRegisterController.selectedCut == null
                      ? Container(
                        child: Center(child: Text("Selecciona un corte para ver información"),),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorScheme.surface
                        ),
                      )
                      : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.surface
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        spacing: 20,
                        children: [
                          // Summary
                          PieChartSample2(
                            cut: cashRegisterController.selectedCut!,
                            summaries: cashRegisterController.summaries,
                          ),
                          // Información
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text("Información de apertura y cierre", style: textTheme.titleMedium,),
                                  Row(
                                    children: [
                                      Expanded(child: IsselInfoField(title: "Abierto por", value: cashRegisterController.selectedCut!.openedByUsername)),
                                      Expanded(child: IsselInfoField(title: "Fecha de apertura", value: DateFormat("dd-MM-yy hh:mm a").format(cashRegisterController.selectedCut!.openedAt)),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: IsselInfoField(title: "Cerrado por", value: cashRegisterController.selectedCut!.closedByUsername ?? "N/A")),
                                      Expanded(child: IsselInfoField(title: "Fecha de cierre", value: cashRegisterController.selectedCut!.closedAt != null ? DateFormat("dd-MM-yy hh:mm a").format(cashRegisterController.selectedCut!.closedAt!) : "N/A",)),
                                    ],
                                  ),
                                  Text("Cantidades", style: textTheme.titleMedium,),
                                  IsselInfoField(title: "Cantidad inicial", value: cashRegisterController.selectedCut!.openingAmount.toStringAsFixed(2)),
                                  Row(
                                    children: [
                                      Expanded(child: IsselInfoField(title: "Efectivo", value: cashRegisterController.selectedCut!.cashTotal.toStringAsFixed(2))),
                                      Expanded(child: IsselInfoField(title: "Declarado", value: cashRegisterController.selectedCut!.declaredCashTotal != null ? cashRegisterController.selectedCut!.declaredCashTotal!.toStringAsFixed(2) : "")),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: IsselInfoField(title: "Tarjeta", value: cashRegisterController.selectedCut!.cardTotal.toStringAsFixed(2))),
                                      Expanded(child: IsselInfoField(title: "Declarado", value: cashRegisterController.selectedCut!.declaredCardTotal != null ? cashRegisterController.selectedCut!.declaredCardTotal!.toStringAsFixed(2) : "")),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
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
    final CashRegisterController cashRegisterController = context.read();
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
      cashRegisterController.clearSalesDateRange();
      setState(() {
        _salesDateRange = null;
      });
      return;
    }

    if (result.range == null) return;

    final CtrlResponse response = await cashRegisterController.getCutsByDateRange(
      startDate: result.range!.start,
      endDate: result.range!.end,
    );

    if (response.success) {
      toastService.success("Ventas filtradas correctamente");
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

  Future<void> loadCutSummary(CashRegisterEntity cut) async {

    CashRegisterController cashRegisterController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await cashRegisterController.loadCutSummary(cut);
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
