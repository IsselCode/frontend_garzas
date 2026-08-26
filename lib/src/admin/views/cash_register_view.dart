import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/tickets/cash_cut_ticket.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/pie_widget.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/sales/clean/entities/closed_cut_summary_entity.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:printing/printing.dart';
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
  Future<CtrlResponse<List<ClosedCutSaleEntity>>>? _getCutSales;
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
                  children: [TextBackButton()],
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
                        color: colorScheme.surface,
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Titulo
                              Text("Cortes", style: textTheme.titleLarge),
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
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListView.separated(
                                    itemCount: 5,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      return IsselShimmer(
                                        width: double.infinity,
                                        height: 50,
                                      );
                                    },
                                  );
                                }

                                if (!snapshot.data!.success) {
                                  return Center(
                                    child: Text(snapshot.data!.message!),
                                  );
                                }

                                if (cashRegisterController
                                    .showedCashRegisterCuts
                                    .isEmpty) {
                                  return Center(
                                    child: Text("No hay cortes disponibles"),
                                  );
                                }

                                List<CashRegisterEntity> cuts =
                                    cashRegisterController
                                        .showedCashRegisterCuts;

                                return IsselTableWidget(
                                  color: colorScheme.surfaceContainer,
                                  onTapRow: (index) =>
                                      loadCutSummary(cuts[index]),
                                  header: IsselHeaderTable(
                                    titleHeaders: ["Fecha", "Usuario", "Total"],
                                    colorPills: colorScheme.surfaceContainer,
                                  ),
                                  rows: cuts.map((cut) {
                                    return IsselRowTable(
                                      cells: [
                                        IsselPill(
                                          color: colorScheme.surface,
                                          text: DateFormat(
                                            "dd-MM-yy",
                                          ).format(cut.openedAt),
                                        ),
                                        IsselPill(
                                          color: colorScheme.surface,
                                          text: cut.openedByUsername,
                                        ),
                                        IsselPill(
                                          color: colorScheme.surface,
                                          widget: AutoSizeText(
                                            "\$${(cut.cardTotal + cut.cashTotal).toStringAsFixed(1)}",
                                            style: textTheme.bodyMedium,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colorScheme.surface,
                            ),
                            child: Center(
                              child: Text(
                                "Selecciona un corte para ver información",
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colorScheme.surface,
                            ),
                            padding: EdgeInsets.all(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Column(
                                      spacing: 20,
                                      children: [
                                        // Summary
                                        PieChartSample2(
                                          cut: cashRegisterController
                                              .selectedCut!,
                                          summaries:
                                              cashRegisterController.summaries,
                                        ),
                                        // Información
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              "Información de apertura y cierre",
                                              style: textTheme.titleMedium,
                                            ),
                                            // Abierto y Cerrado
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Abierto por",
                                                    value:
                                                        cashRegisterController
                                                            .selectedCut!
                                                            .openedByUsername,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Cerrado por",
                                                    value:
                                                        cashRegisterController
                                                            .selectedCut!
                                                            .closedByUsername ??
                                                        "N/A",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Fecha de apertura
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Día de apertura",
                                                    value:
                                                        DateFormat(
                                                          "dd-MM-yy",
                                                        ).format(
                                                          cashRegisterController
                                                              .selectedCut!
                                                              .openedAt,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Hora de apertura",
                                                    value: DateFormat("hh:mm a")
                                                        .format(
                                                          cashRegisterController
                                                              .selectedCut!
                                                              .openedAt,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Fecha de Cierre
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Día de cierre",
                                                    value:
                                                        cashRegisterController
                                                                .selectedCut!
                                                                .closedAt !=
                                                            null
                                                        ? DateFormat(
                                                            "dd-MM-yy",
                                                          ).format(
                                                            cashRegisterController
                                                                .selectedCut!
                                                                .closedAt!,
                                                          )
                                                        : "N/A",
                                                  ),
                                                ),
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Hora de cierre",
                                                    value:
                                                        cashRegisterController
                                                                .selectedCut!
                                                                .closedAt !=
                                                            null
                                                        ? DateFormat(
                                                            "hh:mm a",
                                                          ).format(
                                                            cashRegisterController
                                                                .selectedCut!
                                                                .closedAt!,
                                                          )
                                                        : "N/A",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Cantidades",
                                              style: textTheme.titleMedium,
                                            ),
                                            IsselInfoField(
                                              title: "Cantidad inicial",
                                              value: cashRegisterController
                                                  .selectedCut!
                                                  .openingAmount
                                                  .toStringAsFixed(2),
                                            ),
                                            // Efectivo
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Efectivo",
                                                    value:
                                                        cashRegisterController
                                                            .selectedCut!
                                                            .cashTotal
                                                            .toStringAsFixed(2),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Declarado",
                                                    value:
                                                        cashRegisterController
                                                                .selectedCut!
                                                                .declaredCashTotal !=
                                                            null
                                                        ? cashRegisterController
                                                              .selectedCut!
                                                              .declaredCashTotal!
                                                              .toStringAsFixed(
                                                                2,
                                                              )
                                                        : "",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Tarjeta
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Tarjeta",
                                                    value:
                                                        cashRegisterController
                                                            .selectedCut!
                                                            .cardTotal
                                                            .toStringAsFixed(2),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Declarado",
                                                    value:
                                                        cashRegisterController
                                                                .selectedCut!
                                                                .declaredCardTotal !=
                                                            null
                                                        ? cashRegisterController
                                                              .selectedCut!
                                                              .declaredCardTotal!
                                                              .toStringAsFixed(
                                                                2,
                                                              )
                                                        : "",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Credito
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: IsselInfoField(
                                                    title: "Crédito",
                                                    value:
                                                    cashRegisterController
                                                        .selectedCut!
                                                        .creditTotal
                                                        .toStringAsFixed(2),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Ventas
                                            _buildCutSalesSection(textTheme),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    tooltip: "Reimprimir ticket del corte",
                                    onPressed:
                                        cashRegisterController
                                                .selectedCut!
                                                .closedAt ==
                                            null
                                        ? null
                                        : _reprintCutTicket,
                                    icon: const Icon(Icons.print_outlined),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
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

    final CtrlResponse response = await cashRegisterController
        .getCutsByDateRange(
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

  Future<void> _reprintCutTicket() async {
    final cashRegisterController = context.read<CashRegisterController>();
    final selectedCut = cashRegisterController.selectedCut;
    if (selectedCut == null) return;

    final authSession = context.read<AuthController>().session;
    final toastService = locator<ToastService>();
    final printerService = locator<PrinterService>();

    if (authSession == null) {
      toastService.error("No hay una sesión activa para reimprimir el ticket");
      return;
    }

    context.loaderOverlay.show();

    try {
      final printer = await printerService.getSelectedPrinter();
      if (printer == null) {
        toastService.error("No hay ninguna impresora seleccionada");
        return;
      }

      final response = await cashRegisterController.getCutReceipt(
        selectedCut.id,
      );
      if (!response.success || response.element == null) {
        toastService.error(
          response.message ?? "No se pudo cargar el ticket del corte",
        );
        return;
      }

      final receipt = response.element!;
      final declaredCashTotal =
          receipt.declaredCashTotal ?? selectedCut.declaredCashTotal;
      final declaredCardTotal =
          receipt.declaredCardTotal ?? selectedCut.declaredCardTotal;

      if (declaredCashTotal == null || declaredCardTotal == null) {
        toastService.error(
          "El corte no contiene las cantidades declaradas necesarias para imprimir el ticket",
        );
        return;
      }

      final ticket = CashCutTicketEntity(
        summary: receipt,
        user: authSession,
        userDisplayName:
            selectedCut.closedByUsername ?? authSession.displayName,
        declaredCashTotal: declaredCashTotal,
        declaredCardTotal: declaredCardTotal,
        closedAt: selectedCut.closedAt ?? DateTime.now(),
      );

      await Printing.directPrintPdf(
        printer: printer,
        format: cashCutTicketPageFormat,
        dynamicLayout: false,
        usePrinterSettings: true,
        onLayout: (format) => cashCutTicketPdf(ticket, pageFormat: format),
      );

      toastService.success("Ticket del corte reimpreso correctamente");
    } catch (_) {
      toastService.error("No se pudo reimprimir el ticket del corte");
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
      }
    }
  }

  Future<void> loadCutSummary(CashRegisterEntity cut) async {
    CashRegisterController cashRegisterController = context.read();
    final cutSalesFuture = cashRegisterController.getCutSales(cut.id);

    setState(() {
      _getCutSales = cutSalesFuture;
    });

    context.loaderOverlay.show();
    CtrlResponse response = await cashRegisterController.loadCutSummary(cut);
    if (!mounted) return;
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

  Widget _buildCutSalesSection(TextTheme textTheme) {
    final cutSalesFuture = _getCutSales;
    if (cutSalesFuture == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text("Ventas del corte", style: textTheme.titleMedium),
        FutureBuilder<CtrlResponse<List<ClosedCutSaleEntity>>>(
          future: cutSalesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                spacing: 10,
                children: [
                  IsselShimmer(width: double.infinity, height: 150),
                  IsselShimmer(width: double.infinity, height: 150),
                ],
              );
            }

            final response = snapshot.data;
            if (response == null || !response.success) {
              return IsselPill(
                text: response?.message ?? "No se pudieron cargar las ventas",
                color: Theme.of(context).colorScheme.surfaceContainer,
              );
            }

            final sales = response.element ?? const <ClosedCutSaleEntity>[];
            if (sales.isEmpty) {
              return IsselPill(
                text: "No hay ventas registradas en este corte",
                color: Theme.of(context).colorScheme.surfaceContainer,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _CutSaleTile(sale: sales[index]),
            );
          },
        ),
      ],
    );
  }
}

class _CutSaleTile extends StatelessWidget {
  final ClosedCutSaleEntity sale;

  const _CutSaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: IsselInfoField2(
                  icon: Icons.receipt_long_outlined,
                  label: sale.folio,
                  height: 45,
                  copy: true,
                ),
              ),
              IsselPill(
                text: "\$${sale.total.toStringAsFixed(2)}",
                height: 45,
                color: colorScheme.surface,
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: IsselInfoField2(
                  icon: Icons.water_drop_outlined,
                  label:
                      "${sale.waterType.dp} · ${sale.quantity.toStringAsFixed(2)} ${sale.unitOfMeasurement.abbr}",
                  height: 45,
                ),
              ),
              Expanded(
                child: IsselInfoField2(
                  icon: _paymentIcon(sale.paymentMethod),
                  label: sale.paymentMethod.label,
                  height: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _paymentIcon(PaymentMethod paymentMethod) {
    return switch (paymentMethod) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card_outlined,
      PaymentMethod.credit => Icons.account_balance_wallet_outlined,
    };
  }
}
