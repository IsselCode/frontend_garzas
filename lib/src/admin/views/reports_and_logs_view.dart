import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/date_range_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/statistic_garza_container.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
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
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;
  late Future<CtrlResponse> _loadStatistics;
  late Future<CtrlResponse> _loadSells;
  late Future<CtrlResponse> _loadLogs;
  DateTimeRange? _salesDateRange;
  DateTimeRange? _logsDateRange;
  FocusNode findByFolioNode = FocusNode();

  @override
  void initState() {
    super.initState();
    StatisticsController statisticsController = context.read();
    _loadStatistics = statisticsController.getGarzasStatistics();
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
                  child: Center(
                    child: Text(
                      "Ventas Mensuales",
                      style: textTheme.titleMedium,
                    ),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                fillColor: colorScheme.surfaceContainer,
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
                                        )
                                      ],
                                    ),
                                    // Table
                                    Expanded(
                                      child: IsselTableWidget(
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
                                                    color: colorScheme.surfaceContainer,
                                                    padding: EdgeInsets.zero,
                                                    widget: Tooltip(
                                                      message: sell.sellerUsername,
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: EdgeInsets.symmetric(horizontal: 20,),
                                                        child: Text(
                                                          sell.sellerUsername,
                                                          style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  // Cliente
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    padding: EdgeInsets.zero,
                                                    widget: Tooltip(
                                                      message: sell.clientName != null ? "${sell.clientName}: ${sell.clientPhone}" : null,
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: EdgeInsets.symmetric(horizontal: 20,),
                                                        child: Text(
                                                          sell.clientName ?? "",
                                                          style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  // Cantidades
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    widget: Text(
                                                      "${sell.quantity} ${sell.unitOfMeasurement.abbr}",
                                                      style: textTheme.labelMedium,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                  // Total
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    widget: Text(
                                                      "\$${sell.total.toStringAsFixed(2)}",
                                                      style: textTheme.labelMedium,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  // Forma de pago
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    widget: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          sell.paymentMethod.label,
                                                          style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Image.asset(
                                                          sell.paymentMethod.image,
                                                          width: 24,
                                                          height: 24,
                                                        )
                                                      ],
                                                    ),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  // Fecha
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    padding: EdgeInsets.zero,
                                                    widget: Tooltip(
                                                      message: DateFormat("dd/MM/yy hh:mm:ss a",).format(sell.createdAt),
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: EdgeInsets.symmetric(horizontal: 20,),
                                                        child: Text(
                                                          DateFormat("dd/MM/yy hh:mm:ss a",).format(sell.createdAt),
                                                          style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
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
                                        Text(
                                          "Logs",
                                          style: textTheme.titleLarge,
                                        ),
                                        // Rango de fecha
                                        IsselPill(
                                          text: _formatLogsDateRange(),
                                          color: colorScheme.surfaceContainer,
                                          onTap: () =>
                                              _openLogsDateRangeDialog(),
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
                                                    color: colorScheme.surfaceContainer,
                                                    padding: EdgeInsets.zero,
                                                    widget: Tooltip(
                                                      message: log.tipo,
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: EdgeInsets.symmetric(horizontal: 20,),
                                                        child: Text(
                                                          log.tipo,
                                                          style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  // Cantidades
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    widget: Text(
                                                      log.username,
                                                      style: textTheme.labelMedium, maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  // Información
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    padding: EdgeInsets.zero,
                                                    widget: Tooltip(
                                                      message: log.info,
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: EdgeInsets.symmetric(horizontal: 20,),
                                                        child: Text(
                                                          log.info,
                                                          style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.centerLeft,
                                                  ),
                                                  IsselPill(
                                                    color: colorScheme.surfaceContainer,
                                                    padding: EdgeInsets.zero,
                                                    widget: Tooltip(
                                                      message: DateFormat("dd/MM/yy hh:mm:ss a",).format(log.createdAt),
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: EdgeInsets.symmetric(horizontal: 20,),
                                                        child: Text(
                                                          DateFormat("dd/MM/yy hh:mm:ss a",).format(log.createdAt), style: textTheme.labelMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
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

                  //* Estadisticas de garzas
                  FutureBuilder(
                    future: _loadStatistics,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: IsselShimmer(width: 300, height: 150),
                            ),
                            Expanded(
                              child: IsselShimmer(width: 300, height: 150),
                            ),
                            Expanded(
                              child: IsselShimmer(width: 300, height: 150),
                            ),
                          ],
                        );
                      }

                      if (!snapshot.data!.success) {
                        return Center(child: Text(snapshot.data!.message!));
                      }

                      return Column(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: StatisticGarzaContainer(
                              asset: AppAssets.cash,
                              title: "Efectivo",
                              total: statistics.statistics!.cashTotal,
                            ),
                          ),
                          Expanded(
                            child: StatisticGarzaContainer(
                              asset: AppAssets.card,
                              title: "Tarjeta",
                              total: statistics.statistics!.cardTotal,
                            ),
                          ),
                          Expanded(
                            child: StatisticGarzaContainer(
                              asset: AppAssets.check,
                              title: "Cheque",
                              total: statistics.statistics!.checkTotal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void findClientByFolio(String folio) async {
    StatisticsController statisticsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await statisticsController.findSaleByFolio(folio);
    context.loaderOverlay.hide();

    if (response.success) {
      _salesDateRange = null;
      ToastService toastService = locator();
      toastService.success("Folio: ${folio} encontrado");
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
    final DateRangeDialogResult? result = await showDialog<DateRangeDialogResult>(
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
