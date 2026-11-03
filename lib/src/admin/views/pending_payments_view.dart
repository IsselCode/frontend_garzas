import 'package:frontend_garzas/commons/widgets/paged_list_panel.dart';
import '../../../commons/entities/page_result.dart';
import '../../../commons/paged_list_state.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/inject_container.dart';
import '../widgets/admin_date_range_fields.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/pending_dispatch_entity.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class PendingPaymentsView extends StatefulWidget {
  const PendingPaymentsView({super.key});

  @override
  State<PendingPaymentsView> createState() => _PendingPaymentsViewState();
}

class _PendingPaymentsViewState extends State<PendingPaymentsView> {
  late Future<List<_PendingPaymentItem>> _getPendingPayments;
  late final PagedListState<_PendingPaymentItem> _paging;
  _PendingPaymentItem? _selectedPayment;
  DateTimeRange? _dateRange;
  _PaymentStatusFilter _statusFilter = _pendingPaymentStatusFilter;

  @override
  void initState() {
    super.initState();
    _paging = PagedListState(
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    _getPendingPayments = _loadPendingPayments();
  }

  @override
  void dispose() {
    _paging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            if (Navigator.canPop(context)) const TextBackButton(),
            Expanded(
              child: Row(
                spacing: 20,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.surface,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        spacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              _StatusFilterButton(
                                selectedStatus: _statusFilter,
                                onChanged: _setStatusFilter,
                              ),
                              AdminDateRangeFields(
                                initialRange: _dateRange,
                                onChanged: _applyDateRange,
                              ),
                            ],
                          ),
                          Expanded(
                            child: PagedListPanel(
                              state: _paging,
                              onPageChanged: (page) =>
                                  _loadPendingPayments(page: page),
                              child: FutureBuilder<List<_PendingPaymentItem>>(
                                future: _getPendingPayments,
                                builder: (context, snapshot) {
                                  final payments = _paging.items;

                                  if (payments.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No hay pagos pendientes",
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    itemCount: payments.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final payment = payments[index];
                                      final selected =
                                          payment == _selectedPayment;
                                      return _PendingPaymentTile(
                                        payment: payment,
                                        selected: selected,
                                        onTap: () {
                                          setState(() {
                                            _selectedPayment = payment;
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _PendingPaymentDetails(payment: _selectedPayment),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<_PendingPaymentItem>> _loadPendingPayments({int page = 1}) async {
    final api = locator<PendingDispatchesApi>();
    final status = _statusFilter.value;
    final range = _dateRange;
    await _paging.load((number) async {
      final result = await api.listPage(
        page: number,
        status: status,
        startDate: range?.start,
        endDate: range?.end,
      );
      return PageResult(
        items: result.items
            .map((item) => _PendingPaymentItem(pendingDispatch: item))
            .toList(),
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: result.totalPages,
      );
    }, page: page);
    return _paging.items;
  }

  void _setStatusFilter(_PaymentStatusFilter status) {
    setState(() {
      _statusFilter = status;
      _selectedPayment = null;
      _getPendingPayments = _loadPendingPayments();
    });
  }

  Future<bool> _applyDateRange(DateTimeRange? range) async {
    final previous = _dateRange;
    _dateRange = range;
    await _loadPendingPayments();
    if (!mounted) return false;
    if (_paging.error != null) {
      _dateRange = previous;
      return false;
    }
    setState(() => _selectedPayment = null);
    return true;
  }
}

const _pendingPaymentStatusFilter = _PaymentStatusFilter(
  value: 'pending_payment',
  label: 'Pendiente de pago',
);

const _paymentStatusFilters = [
  _PaymentStatusFilter(value: 'pending_dispatch', label: 'Pendiente'),
  _pendingPaymentStatusFilter,
  _PaymentStatusFilter(value: 'paid', label: 'Pagado'),
  _PaymentStatusFilter(value: 'cancelled', label: 'Cancelado'),
];

class _PaymentStatusFilter {
  final String value;
  final String label;

  const _PaymentStatusFilter({required this.value, required this.label});
}

class _PendingPaymentTile extends StatelessWidget {
  final _PendingPaymentItem payment;
  final bool selected;
  final VoidCallback onTap;

  const _PendingPaymentTile({
    required this.payment,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                payment.pendingDispatch.status.label,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: selected ? colorScheme.onPrimaryContainer : null,
                ),
              ),
              Text(
                DateFormat("dd/MM/yyyy hh:mm a").format(payment.paymentDate),
                style: textTheme.bodySmall?.copyWith(
                  color: selected
                      ? colorScheme.onPrimaryContainer.withValues(alpha: 0.72)
                      : colorScheme.outline,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 17,
                    color: selected
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.78)
                        : colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      payment.pendingDispatch.plateOrUnitReference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFilterButton extends StatelessWidget {
  final _PaymentStatusFilter selectedStatus;
  final ValueChanged<_PaymentStatusFilter> onChanged;

  const _StatusFilterButton({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 230,
      child: IsselDropdown<_PaymentStatusFilter>(
        value: selectedStatus,
        height: 40,
        hintText: 'Estado',
        color: colorScheme.surfaceContainer,
        items: [
          for (final status in _paymentStatusFilters)
            DropdownMenuItem(value: status, child: Text(status.label)),
        ],
        onChanged: (status) {
          if (status != null) onChanged(status);
        },
      ),
    );
  }
}

class _PendingPaymentDetails extends StatelessWidget {
  final _PendingPaymentItem? payment;

  const _PendingPaymentDetails({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = payment;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
        ),
        padding: const EdgeInsets.all(22),
        child: item == null
            ? Center(
                child: Text(
                  "Selecciona un pago pendiente para ver informacion",
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 18,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Pago pendiente",
                            style: textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    _DetailSection(
                      title: "Informacion general",
                      children: [
                        _InfoTile("Estado", item.pendingDispatch.status.label),
                        _InfoTile(
                          "Fecha pendiente",
                          DateFormat(
                            "dd/MM/yyyy hh:mm a",
                          ).format(item.paymentDate),
                        ),
                        _InfoTile(
                          "Creado",
                          _formatDate(item.pendingDispatch.createdAt),
                        ),
                        _InfoTile(
                          "Actualizado",
                          _formatDate(item.pendingDispatch.updatedAt),
                        ),
                        _InfoTile(
                          "Folio venta",
                          _emptyAsNotAvailable(item.pendingDispatch.saleFolio),
                        ),
                      ],
                    ),
                    _DetailSection(
                      title: "Despacho",
                      children: [
                        _InfoTile(
                          "Referencia",
                          item.pendingDispatch.plateOrUnitReference,
                        ),
                        _InfoTile(
                          "Empleado cliente",
                          _emptyAsNotAvailable(
                            item.pendingDispatch.customerEmployeeName,
                          ),
                        ),
                        _InfoTile(
                          "Garza",
                          item.pendingDispatch.garzaNumber.toString(),
                        ),
                        _InfoTile(
                          "Tipo de agua",
                          item.pendingDispatch.waterType.dp,
                        ),
                        _InfoTile(
                          "Unidad",
                          item.pendingDispatch.unitOfMeasurement.dp,
                        ),
                        _InfoTile(
                          "Despachado",
                          "${item.pendingDispatch.dispensedVolume.toStringAsFixed(2)} ${item.pendingDispatch.unitOfMeasurement.abbr}",
                        ),
                      ],
                    ),
                    _DetailSection(
                      title: "Operador",
                      children: [
                        _InfoTile(
                          "Usuario",
                          _emptyAsNotAvailable(
                            item.pendingDispatch.operatorUsername,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_InfoTile> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(title, style: textTheme.titleMedium),
        ..._buildRows(),
      ],
    );
  }

  List<Widget> _buildRows() {
    final rows = <Widget>[];

    for (var index = 0; index < children.length; index += 3) {
      final rowChildren = children.skip(index).take(3).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              var childIndex = 0;
              childIndex < rowChildren.length;
              childIndex++
            ) ...[
              if (childIndex > 0) const SizedBox(width: 12),
              Expanded(child: rowChildren[childIndex]),
            ],
          ],
        ),
      );
      if (index + 3 < children.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return rows;
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            title,
            style: textTheme.labelMedium?.copyWith(color: colorScheme.outline),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentItem {
  final PendingDispatchEntity pendingDispatch;

  const _PendingPaymentItem({required this.pendingDispatch});

  DateTime get paymentDate =>
      DateTime.tryParse(pendingDispatch.updatedAt)?.toLocal() ??
      DateTime.tryParse(pendingDispatch.createdAt)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value;
  return DateFormat("dd/MM/yyyy hh:mm a").format(date);
}

String _emptyAsNotAvailable(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return "N/A";
  return text;
}
