import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/tickets/sell_ticket.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/date_range_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/sale_details_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/entities/monthly_garza_total_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/statistic_garza_container.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/statistic_garza_container_2.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../../inject_container.dart';
import '../../../commons/text_back_button.dart';

class ReportsAndLogsView extends StatefulWidget {
  const ReportsAndLogsView({super.key});

  @override
  State<ReportsAndLogsView> createState() => _ReportsAndLogsViewState();
}

class _ReportsAndLogsViewState extends State<ReportsAndLogsView> {
  PageController pageController = PageController(initialPage: 0);
  PageController pageTotalsController = PageController(initialPage: 0);
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;
  TabSwitcherAlignStates state2 = TabSwitcherAlignStates.left;
  late Future<CtrlResponse> _loadStatistics;
  late Future<CtrlResponse> _loadMonthlyGarzaTotals;
  late Future<CtrlResponse> _loadSells;
  late Future<CtrlResponse> _loadLogs;
  DateTimeRange? _salesDateRange;
  DateTimeRange? _logsDateRange;
  FocusNode findByFolioNode = FocusNode();
  late DateTime _selectedTotalsMonth;

  bool get _canViewPreviousMonth => DateTime.now().day <= 30;

  bool get _showingPreviousMonth {
    final now = DateTime.now();
    return _selectedTotalsMonth.year != now.year ||
        _selectedTotalsMonth.month != now.month;
  }

  DateTime _firstDayOfMonth(DateTime date) => DateTime(date.year, date.month);

  DateTime _previousMonth(DateTime date) => DateTime(date.year, date.month - 1);

  GarzaTotalEntity? _findGarzaTotal(
    StatisticsController statistics,
    int garzaNumber,
  ) {
    final totals =
        statistics.monthlyGarzaTotalEntity?.totals ??
        const <GarzaTotalEntity>[];

    for (final total in totals) {
      if (total.garzaNumber == garzaNumber) {
        return total;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    StatisticsController statisticsController = context.read();
    _selectedTotalsMonth = _firstDayOfMonth(DateTime.now());
    _loadStatistics = statisticsController.getMonthlyPaymentTotals(
      month: _selectedTotalsMonth,
    );
    _loadMonthlyGarzaTotals = statisticsController.getMonthlyGarzaTotals(
      month: _selectedTotalsMonth,
    );
    _loadSells = statisticsController.getSales();
    _loadLogs = statisticsController.getLogs();
  }

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    StatisticsController statistics = context.watch();

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
            //* AppBar
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextBackButton(),
                      IsselTabSwitcher(
                        width: 200,
                        state: state,
                        leftText: "Venta",
                        rightText: "Logs",
                        onChanged: (value) {
                          state = value;
                          if (state == TabSwitcherAlignStates.left) {
                            pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          } else {
                            pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: IsselTabSwitcher(
                          state: state2,
                          leftText: "Método",
                          rightText: "Garzas",
                          onChanged: (value) {
                            state2 = value;
                            if (state2 == TabSwitcherAlignStates.left) {
                              pageTotalsController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            } else {
                              pageTotalsController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      IsselPill(
                        text: DateFormat(
                          "MMMM",
                          "es",
                        ).format(_selectedTotalsMonth),
                        color: colorScheme.surfaceContainer,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //* Body
            Expanded(
              child: Row(
                spacing: 10,
                children: [
                  //* Ventas y Reportes
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      children: [
                        //* Ventas
                        FutureBuilder(
                          future: _loadSells,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return IsselShimmer(
                                width: double.infinity,
                                height: double.infinity,
                              );
                            }

                            if (!snapshot.data!.success) {
                              return Center(
                                child: Text(snapshot.data!.message!),
                              );
                            }

                            return Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.surface,
                              ),
                              child: Column(
                                spacing: 20,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and Actions
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Venta",
                                        style: textTheme.titleLarge,
                                      ),
                                      // Actions
                                      Flex(
                                        direction: Axis.horizontal,
                                        spacing: 10,
                                        children: [
                                          // Campo de busqueda
                                          SizedBox(
                                            width: 250,
                                            child: IsselTextFormField(
                                              focusNode: findByFolioNode,
                                              height: 50,
                                              prefixIcon: Icons.search,
                                              fillColor:
                                                  colorScheme.surfaceContainer,
                                              hintText: "Folio",
                                              onSubmitted: findClientByFolio,
                                            ),
                                          ),
                                          // Rango de fecha
                                          IsselPill(
                                            text: _formatSalesDateRange(),
                                            color: colorScheme.surfaceContainer,
                                            onTap: () =>
                                                _openSalesDateRangeDialog(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Table
                                  Expanded(
                                    child: IsselTableWidget(
                                      onTapRow: (index) => _showSaleDetails(
                                        statistics.showedSales[index],
                                      ),
                                      header: IsselHeaderTable(
                                        titleHeaders: [
                                          "Empleado",
                                          "Cliente",
                                          "Cantidad",
                                          "Total",
                                          "Método",
                                          "Fecha",
                                        ],
                                      ),
                                      rows: statistics.showedSales
                                          .map(
                                            (sell) => IsselRowTable(
                                              cells: [
                                                // Empleado
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  padding: EdgeInsets.zero,
                                                  widget: Tooltip(
                                                    message:
                                                        sell.sellerUsername,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: Text(
                                                        sell.sellerUsername,
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Cliente
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  padding: EdgeInsets.zero,
                                                  widget: Tooltip(
                                                    message:
                                                        sell.commercialName ??
                                                        "Público General",
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: Text(
                                                        sell.commercialName ??
                                                            "Público General",
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Cantidades
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  widget: AutoSizeText(
                                                    "${sell.quantity} ${sell.unitOfMeasurement.abbr}",
                                                    style:
                                                        textTheme.labelMedium,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Total
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  widget: AutoSizeText(
                                                    "\$${sell.total.toStringAsFixed(2)}",
                                                    style:
                                                        textTheme.labelMedium,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Forma de pago
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  widget: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        sell
                                                            .paymentMethod
                                                            .label,
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Image.asset(
                                                        sell
                                                            .paymentMethod
                                                            .image,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ],
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Fecha
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  padding: EdgeInsets.zero,
                                                  widget: Tooltip(
                                                    message: DateFormat(
                                                      "dd/MM/yy hh:mm:ss a",
                                                    ).format(sell.createdAt),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: AutoSizeText(
                                                        DateFormat(
                                                          "dd/MM/yy hh:mm:ss a",
                                                        ).format(
                                                          sell.createdAt,
                                                        ),
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                                // IsselPill(widget: IconButton(onPressed: () => print("Eliminando"), icon: Icon(Icons.delete, color: Colors.red,)),),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        //* LOGS
                        FutureBuilder(
                          future: _loadLogs,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return IsselShimmer(
                                width: double.infinity,
                                height: double.infinity,
                              );
                            }

                            if (!snapshot.data!.success) {
                              return Center(
                                child: Text(snapshot.data!.message!),
                              );
                            }

                            return Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.surface,
                              ),
                              child: Column(
                                spacing: 20,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Logs", style: textTheme.titleLarge),
                                      // Rango de fecha
                                      IsselPill(
                                        text: _formatLogsDateRange(),
                                        color: colorScheme.surfaceContainer,
                                        onTap: () => _openLogsDateRangeDialog(),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: IsselTableWidget(
                                      header: IsselHeaderTable(
                                        titleHeaders: [
                                          "Tipo",
                                          "Usuario",
                                          "Información",
                                          "Fecha",
                                        ],
                                      ),
                                      rows: statistics.showedLogs
                                          .map(
                                            (log) => IsselRowTable(
                                              cells: [
                                                // Empleado
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  padding: EdgeInsets.zero,
                                                  widget: Tooltip(
                                                    message: log.tipo,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: Text(
                                                        log.tipo,
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Cantidades
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  widget: Text(
                                                    log.username,
                                                    style:
                                                        textTheme.labelMedium,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                // Información
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  padding: EdgeInsets.zero,
                                                  widget: Tooltip(
                                                    message: log.info,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: AutoSizeText(
                                                        log.info,
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                                IsselPill(
                                                  color: colorScheme
                                                      .surfaceContainer,
                                                  padding: EdgeInsets.zero,
                                                  widget: Tooltip(
                                                    message: DateFormat(
                                                      "dd/MM/yy hh:mm:ss a",
                                                    ).format(log.createdAt),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: Text(
                                                        DateFormat(
                                                          "dd/MM/yy hh:mm:ss a",
                                                        ).format(log.createdAt),
                                                        style: textTheme
                                                            .labelMedium,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: 300,
                    child: Column(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: PageView(
                            controller: pageTotalsController,
                            children: [
                              //* Estadisticas por método
                              FutureBuilder(
                                future: _loadStatistics,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Column(
                                      spacing: 10,
                                      children: [
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  if (!snapshot.data!.success) {
                                    return Center(
                                      child: Text(snapshot.data!.message!),
                                    );
                                  }

                                  return Column(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: StatisticGarzaContainer(
                                          asset: AppAssets.cash,
                                          title: "Efectivo",
                                          total:
                                              statistics.statistics!.cashTotal,
                                          liters:
                                              statistics.statistics!.cashLiters,
                                        ),
                                      ),
                                      Expanded(
                                        child: StatisticGarzaContainer(
                                          asset: AppAssets.card,
                                          title: "Tarjeta",
                                          total:
                                              statistics.statistics!.cardTotal,
                                          liters:
                                              statistics.statistics!.cardLiters,
                                        ),
                                      ),
                                      Expanded(
                                        child: StatisticGarzaContainer(
                                          asset: AppAssets.credit,
                                          title: "Credito",
                                          total: statistics
                                              .statistics!
                                              .creditTotal,
                                          liters: statistics
                                              .statistics!
                                              .creditLiters,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              //* Estadisticas por garza
                              FutureBuilder(
                                future: _loadMonthlyGarzaTotals,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Column(
                                      spacing: 10,
                                      children: [
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                        Expanded(
                                          child: IsselShimmer(
                                            width: 300,
                                            height: 150,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  if (!snapshot.data!.success) {
                                    return Center(
                                      child: Text(snapshot.data!.message!),
                                    );
                                  }

                                  return Column(
                                    spacing: 10,
                                    children: [
                                      Text(
                                        "Solo apareceran las estadisticas de las garzas que despacharon agua.",
                                        style: textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      ...List.generate(4, (index) {
                                        final garzaNumber = index + 1;
                                        final garza = _findGarzaTotal(
                                          statistics,
                                          garzaNumber,
                                        );

                                        return Expanded(
                                          child: StatisticGarzaContainer_2(
                                            asset: AppAssets.waterTank,
                                            title:
                                                garza?.garzaTitle ??
                                                "Garza $garzaNumber",
                                            total: garza?.totalAmount ?? 0,
                                            expectedTotal:
                                                garza?.expectedAmount ?? 0,
                                            liters: garza?.totalLiters ?? 0,
                                            expectedLiters:
                                                garza?.expectedLiters ?? 0,
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_canViewPreviousMonth)
                          IsselButton(
                            height: 50,
                            text: _showingPreviousMonth
                                ? "Ver mes actual"
                                : "Ver mes anterior",
                            onTap: _toggleTotalsMonth,
                          ),
                      ],
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

  void _toggleTotalsMonth() {
    final now = DateTime.now();
    final currentMonth = _firstDayOfMonth(now);

    _selectedTotalsMonth = _showingPreviousMonth
        ? currentMonth
        : _previousMonth(currentMonth);

    final statisticsController = context.read<StatisticsController>();
    setState(() {
      _loadStatistics = statisticsController.getMonthlyPaymentTotals(
        month: _selectedTotalsMonth,
      );
      _loadMonthlyGarzaTotals = statisticsController.getMonthlyGarzaTotals(
        month: _selectedTotalsMonth,
      );
    });
  }

  Future<void> _showSaleDetails(SaleEntity sale) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SaleDetailsDialog(
        sale: sale,
        onDeleteSale: _requestSaleDeletion,
        onReprintTicket: _reprintTicket,
      ),
    );
  }

  Future<void> _requestSaleDeletion(
    BuildContext saleDetailsContext,
    SaleEntity sale,
  ) async {
    final saleDetailsNavigator = Navigator.of(saleDetailsContext);
    final bool? confirmed = await showDialog<bool>(
      context: saleDetailsContext,
      barrierDismissible: false,
      builder: (context) => _ConfirmDeleteSaleDialog(folio: sale.folio),
    );

    if (!mounted || confirmed != true) return;

    final statisticsController = context.read<StatisticsController>();
    final toastService = locator<ToastService>();

    context.loaderOverlay.show();
    final CtrlResponse response = await statisticsController.deleteSaleByFolio(
      sale.folio,
    );

    if (!mounted) return;

    context.loaderOverlay.hide();

    if (!response.success) {
      toastService.error(response.message ?? "No se pudo eliminar la venta");
      return;
    }

    toastService.success("Venta eliminada correctamente");

    setState(() {
      _loadStatistics = statisticsController.getMonthlyPaymentTotals(
        month: _selectedTotalsMonth,
      );
      _loadMonthlyGarzaTotals = statisticsController.getMonthlyGarzaTotals(
        month: _selectedTotalsMonth,
      );
    });

    if (saleDetailsNavigator.canPop()) {
      saleDetailsNavigator.pop();
    }
  }

  Future<void> _reprintTicket(SaleEntity sale) async {
    final toastService = locator<ToastService>();
    final printerService = locator<PrinterService>();
    final configController = context.read<GeneralConfigController>();

    context.loaderOverlay.show();

    try {
      final printer = await printerService.getSelectedPrinter();
      if (printer == null) {
        toastService.error("No hay ninguna impresora seleccionada");
        return;
      }

      if (configController.generalConfigEntity == null) {
        final response = await configController.loadGeneralConfig();
        if (!response.success || configController.generalConfigEntity == null) {
          toastService.error(
            response.message ?? "No se pudo cargar la configuración del ticket",
          );
          return;
        }
      }

      final config = configController.generalConfigEntity!;
      final ticket = SellTicketEntity(
        ticketNumber: sale.id,
        copyNumber: 1,
        folio: sale.folio,
        commercialName: sale.commercialName,
        waterType: sale.waterType,
        unitOfMeasurement: sale.unitOfMeasurement,
        quantity: sale.quantity,
        total: sale.total,
        paymentMethod: sale.paymentMethod,
        amountPaid: sale.amountPaid,
        changeAmount: sale.changeAmount,
        dispatchCode: sale.dispatchCode,
        createdAt: sale.createdAt,
        sellerName: sale.sellerUsername,
      );

      await Printing.directPrintPdf(
        printer: printer,
        format: sellTicketPageFormat,
        dynamicLayout: false,
        usePrinterSettings: true,
        onLayout: (format) => sellTicketPdf(config, ticket, pageFormat: format),
      );

      toastService.success("Ticket reimpreso correctamente");
    } catch (_) {
      toastService.error("No se pudo reimprimir el ticket");
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
      }
    }
  }

  void findClientByFolio(String folio) async {
    StatisticsController statisticsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await statisticsController.findSaleByFolio(folio);
    if (!mounted) return;
    context.loaderOverlay.hide();

    if (response.success) {
      _salesDateRange = null;
      ToastService toastService = locator();
      toastService.success("Folio: $folio encontrado");
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }

    findByFolioNode.requestFocus();
  }

  String _formatSalesDateRange() {
    if (_salesDateRange == null) {
      return "Fecha";
    }

    final formatter = DateFormat("dd/MM/yyyy");
    return "${formatter.format(_salesDateRange!.start)} - ${formatter.format(_salesDateRange!.end)}";
  }

  String _formatLogsDateRange() {
    if (_logsDateRange == null) {
      return "Fecha";
    }

    final formatter = DateFormat("dd/MM/yyyy");
    return "${formatter.format(_logsDateRange!.start)} - ${formatter.format(_logsDateRange!.end)}";
  }

  Future<void> _openSalesDateRangeDialog() async {
    final StatisticsController statisticsController = context.read();
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
      statisticsController.clearSalesDateRange();
      setState(() {
        _salesDateRange = null;
      });
      return;
    }

    if (result.range == null) return;

    final CtrlResponse response = await statisticsController
        .getSalesByDateRange(
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

  Future<void> _openLogsDateRangeDialog() async {
    final StatisticsController statisticsController = context.read();
    final ToastService toastService = locator();
    final DateRangeDialogResult? result =
        await showDialog<DateRangeDialogResult>(
          context: context,
          builder: (context) => DateRangeDialog(
            initialRange: _logsDateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          ),
        );

    if (result == null) return;

    if (result.cleared) {
      statisticsController.clearLogsDateRange();
      setState(() {
        _logsDateRange = null;
      });
      return;
    }

    if (result.range == null) return;

    final CtrlResponse response = await statisticsController.getLogsByDateRange(
      startDate: result.range!.start,
      endDate: result.range!.end,
    );

    if (response.success) {
      toastService.success("Logs filtrados correctamente");
    } else {
      toastService.error(response.message ?? "No se pudieron filtrar los logs");
      return;
    }

    setState(() {
      _logsDateRange = result.range;
    });
  }
}

class _ConfirmDeleteSaleDialog extends StatefulWidget {
  final String folio;

  const _ConfirmDeleteSaleDialog({required this.folio});

  @override
  State<_ConfirmDeleteSaleDialog> createState() =>
      _ConfirmDeleteSaleDialogState();
}

class _ConfirmDeleteSaleDialogState extends State<_ConfirmDeleteSaleDialog> {
  static const int _confirmationSeconds = 3;

  late int _secondsRemaining;
  Timer? _timer;

  bool get _canConfirm => _secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _confirmationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        return;
      }

      setState(() => _secondsRemaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text("Eliminar venta", style: textTheme.titleLarge),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Esta accion eliminara permanentemente la venta con folio ${widget.folio}.",
              style: textTheme.bodyMedium,
            ),
            Text(
              _canConfirm
                  ? "Confirma la eliminacion para continuar."
                  : "Espera $_secondsRemaining segundos para confirmar.",
              style: textTheme.bodyMedium?.copyWith(
                color: _canConfirm ? colorScheme.error : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IsselButton(
          text: "Cancelar",
          width: 120,
          height: 50,
          onTap: () => Navigator.of(context).pop(false),
        ),
        IsselButton(
          text: _canConfirm ? "Eliminar" : "Eliminar ($_secondsRemaining)",
          width: 150,
          height: 50,
          color: Colors.red,
          onTap: _canConfirm ? () => Navigator.of(context).pop(true) : null,
        ),
      ],
    );
  }
}
