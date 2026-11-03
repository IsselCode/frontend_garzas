import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../commons/text_back_button.dart';
import '../../../commons/widgets/paged_list_panel.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../../sales/clean/entities/credit_entity.dart';
import '../clean/enums/credit_status.dart';
import '../controllers/credits_controller.dart';
import '../widgets/admin_table_viewport.dart';
import '../widgets/credits_filters.dart';

class CreditsView extends StatefulWidget {
  const CreditsView({super.key});

  @override
  State<CreditsView> createState() => _CreditsViewState();
}

class _CreditsViewState extends State<CreditsView> {
  final _search = TextEditingController();
  final _searchKey = GlobalKey<FormFieldState<String>>();
  late final CreditsController _controller;
  DateTimeRange? _dateRange;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = context.read<CreditsController>();
    Future.microtask(() {
      if (mounted) _controller.resetFilters();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreditsController>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            if (Navigator.canPop(context)) const TextBackButton(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final list = _buildCredits(controller);
                  final details = _buildPayments(controller);
                  if (constraints.maxWidth < 1000) {
                    if (controller.selectedCredit == null) return list;
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          SizedBox(height: 500, child: list),
                          details,
                        ],
                      ),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      Expanded(child: list),
                      SizedBox(width: 260, child: details),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredits(CreditsController controller) {
    final colors = Theme.of(context).colorScheme;
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          CreditsFilters(
            search: _search,
            searchKey: _searchKey,
            status: controller.status,
            dateRange: _dateRange,
            loading: controller.paging.loading,
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: (_) => _applyFilters(),
            onClearSearch: () {
              _search.clear();
              setState(() {});
              _applyFilters();
            },
            onStatusChanged: (status) => _applyFilters(status: status),
            onDateRangeChanged: (range) =>
                _applyFilters(range: range, updateDates: true),
          ),
          Expanded(
            child: PagedListPanel(
              state: controller.paging,
              noun: 'créditos',
              onPageChanged: (page) => controller.getCredits(page: page),
              child: AdminTableViewport(
                minWidth: 680,
                child: IsselTableWidget(
                  color: colors.surfaceContainer,
                  header: IsselHeaderTable(
                    titleHeaders: const [
                      'Cliente',
                      'Estado',
                      'Total',
                      'Pago',
                      'Saldo',
                      'Fecha',
                    ],
                    colorPills: colors.surface,
                  ),
                  onTapRow: (index) =>
                      _loadCreditPayments(controller.showedCredits[index]),
                  rows: [
                    for (final credit in controller.showedCredits)
                      IsselRowTable(
                        cells: [
                          for (final value in [
                            credit.commercialName,
                            credit.salePendingAmount > 0
                                ? 'Pendiente'
                                : 'Pagado',
                            '\$${credit.total.toStringAsFixed(2)}',
                            '\$${credit.amountPaid.toStringAsFixed(2)}',
                            '\$${credit.salePendingAmount.toStringAsFixed(2)}',
                            DateFormat('dd/MM/yy').format(credit.createdAt),
                          ])
                            _cell(
                              value,
                              selected:
                                  controller.selectedCredit?.saleFolio ==
                                  credit.saleFolio,
                            ),
                        ],
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

  Widget _buildPayments(CreditsController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final credit = controller.selectedCredit;
    final paging = controller.paymentsPaging;
    final payment = controller.creditPayments.firstOrNull;
    return _surface(
      child: credit == null
          ? const Center(
              child: Text(
                'Selecciona un crédito para ver sus abonos',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pago del crédito',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar detalle',
                        onPressed: controller.clearSelectedCredit,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    credit.saleFolio,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  if (paging.loading)
                    Center(child: IsselCircularProgressIndicator())
                  else if (paging.error != null) ...[
                    Text(
                      paging.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.error,
                      ),
                    ),
                    IsselButton(
                      text: 'Reintentar',
                      height: 40,
                      onTap: () => _loadCreditPayments(credit),
                    ),
                  ] else if (payment == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Este crédito aún no tiene pagos registrados.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else ...[
                    _paymentField(
                      'Cantidad pagada',
                      '\$${payment.amount.toStringAsFixed(2)}',
                      emphasize: true,
                    ),
                    _paymentField('Cobrador', payment.receivedByUsername),
                    _paymentField(
                      'Método de pago',
                      payment.paymentMethod.label,
                    ),
                    _paymentField(
                      'Fecha de pago',
                      DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _paymentField(String label, String value, {bool emphasize = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
          ),
          Text(
            value,
            style: emphasize
                ? theme.textTheme.titleLarge?.copyWith(color: colors.primary)
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _surface({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );

  IsselPill _cell(String value, {bool selected = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return IsselPill(
      color: selected ? colors.primary : colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      widget: Tooltip(
        message: value,
        child: AutoSizeText(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? colors.onPrimary : colors.onSurface,
          ),
          minFontSize: 12,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _applyFilters();
    });
  }

  Future<bool> _applyFilters({
    CreditStatus? status,
    DateTimeRange? range,
    bool updateDates = false,
  }) async {
    _debounce?.cancel();
    if (_controller.paging.loading ||
        _searchKey.currentState?.validate() != true) {
      return false;
    }
    final response = await _controller.filterCredits(
      status: status,
      search: _search.text,
      startDate: range?.start,
      endDate: range?.end,
      updateDates: updateDates,
    );
    if (!mounted) return false;
    if (!response.success) {
      _search.text = _controller.search;
      setState(() {});
      locator<ToastService>().error(
        response.message ?? 'No se pudieron filtrar los créditos',
      );
      return false;
    }
    if (updateDates) setState(() => _dateRange = range);
    return true;
  }

  Future<void> _loadCreditPayments(CreditEntity credit) async {
    final response = await _controller.loadCreditPayments(credit);
    if (!mounted || response.success) return;
    locator<ToastService>().error(
      response.message ?? 'No se pudieron consultar los abonos',
    );
  }
}
