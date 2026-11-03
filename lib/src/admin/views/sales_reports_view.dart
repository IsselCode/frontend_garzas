import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/tickets/sell_ticket.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/core/utils/print_timing.dart';
import '../widgets/admin_date_range_fields.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/sale_details_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../inject_container.dart';
import '../widgets/sales_report_panel.dart';

class SalesReportsView extends StatefulWidget {
  const SalesReportsView({super.key});

  @override
  State<SalesReportsView> createState() => _SalesReportsViewState();
}

class _SalesReportsViewState extends State<SalesReportsView> {
  late Future<CtrlResponse> _loadSells;
  DateTimeRange? _salesDateRange;
  int _dateFilterRevision = 0;
  FocusNode findByFolioNode = FocusNode();

  @override
  void initState() {
    super.initState();
    StatisticsController statisticsController = context.read();
    _loadSells = statisticsController.clearSalesDateRange();
  }

  @override
  void dispose() {
    findByFolioNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(10),
      child: SalesReportPanel(
        loadSales: _loadSells,
        searchNode: findByFolioNode,
        dateFilters: AdminDateRangeFields(
          key: ValueKey(_dateFilterRevision),
          initialRange: _salesDateRange,
          onChanged: _applySalesDateRange,
        ),
        onSearch: findClientByFolio,
        onSaleDetails: _showSaleDetails,
      ),
    ),
  );

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

    if (saleDetailsNavigator.canPop()) {
      saleDetailsNavigator.pop();
    }
  }

  Future<void> _reprintTicket(SaleEntity sale) async {
    final timing = PrintTiming('venta.reimpresion');
    timing.event('clic: Reimprimir ticket');
    final toastService = locator<ToastService>();
    final printerService = locator<PrinterService>();
    final configController = context.read<GeneralConfigController>();

    context.loaderOverlay.show();

    try {
      final printer = await timing.measure(
        'obtener impresora',
        () => printerService.getSelectedPrinter(),
      );
      if (printer == null) {
        timing.event('sin impresora seleccionada');
        toastService.error("No hay ninguna impresora seleccionada");
        return;
      }

      if (configController.generalConfigEntity == null) {
        final response = await timing.measure(
          'cargar configuración del ticket',
          () => configController.loadGeneralConfig(),
        );
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

      final pdfBytes = await timing.measure(
        'construcción del PDF',
        () => sellTicketPdf(config, ticket, pageFormat: sellTicketPageFormat),
      );

      final result = await timing.measure(
        'impresión: envío del PDF y respuesta del sistema',
        () => Future<bool>.sync(
          () => Printing.directPrintPdf(
            printer: printer,
            format: sellTicketPageFormat,
            dynamicLayout: false,
            usePrinterSettings: true,
            onLayout: (_) async => pdfBytes,
          ),
        ),
      );
      if (!result) timing.event('impresión no completada');

      toastService.success("Ticket reimpreso correctamente");
    } catch (error) {
      timing.event('error de reimpresión: ${error.runtimeType}');
      toastService.error("No se pudo reimprimir el ticket");
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
      }
      await timing.finish();
    }
  }

  void findClientByFolio(String folio) async {
    StatisticsController statisticsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await statisticsController.findSaleByFolio(folio);
    if (!mounted) return;
    context.loaderOverlay.hide();

    if (response.success) {
      setState(() {
        _salesDateRange = null;
        _dateFilterRevision++;
      });
      ToastService toastService = locator();
      toastService.success("Folio: $folio encontrado");
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }

    findByFolioNode.requestFocus();
  }

  Future<bool> _applySalesDateRange(DateTimeRange? range) async {
    final StatisticsController statisticsController = context.read();
    final ToastService toastService = locator();
    if (range == null) {
      final cleared = await statisticsController.clearSalesDateRange();
      if (!mounted || !cleared.success) return false;
      setState(() => _salesDateRange = null);
      return true;
    }
    final CtrlResponse response = await statisticsController
        .getSalesByDateRange(startDate: range.start, endDate: range.end);
    if (!mounted) return false;
    if (response.success) {
      toastService.success("Ventas filtradas correctamente");
    } else {
      toastService.error(
        response.message ?? "No se pudieron filtrar las ventas",
      );
      return false;
    }
    setState(() => _salesDateRange = range);
    return true;
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

    return NotchedConfirmationDialog(
      icon: Icons.delete_outline,
      title: 'Eliminar venta',
      message:
          'Esta acción eliminará permanentemente la venta con folio ${widget.folio}.',
      confirmText: _canConfirm ? 'Eliminar' : 'Eliminar ($_secondsRemaining)',
      canConfirm: _canConfirm,
      destructive: true,
      details: Text(
        _canConfirm
            ? "Confirma la eliminacion para continuar."
            : "Espera $_secondsRemaining segundos para confirmar.",
        style: textTheme.bodyMedium?.copyWith(
          color: _canConfirm ? colorScheme.error : colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
