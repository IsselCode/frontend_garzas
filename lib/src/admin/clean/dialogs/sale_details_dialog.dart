import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class SaleDetailsDialog extends StatelessWidget {
  final SaleEntity sale;
  final Future<void> Function(BuildContext dialogContext, SaleEntity sale)
  onDeleteSale;
  final Future<void> Function(SaleEntity sale) onReprintTicket;

  const SaleDetailsDialog({
    super.key,
    required this.sale,
    required this.onDeleteSale,
    required this.onReprintTicket,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final commercialName = sale.commercialName?.trim().isNotEmpty == true
        ? sale.commercialName!
        : "Público general";
    final paidAt = _formatNullableDate(sale.paidAt);
    final dispatchDurationSeconds = sale.dispatchDurationMS / 1000;

    return NotchedDialog(
      icon: Icons.receipt_long_outlined,
      maxWidth: 980,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Detalle de venta',
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          _SaleDetailSection(
            title: "Identificación",
            fields: [
              _SaleDetailItem("ID de venta", sale.id.toString()),
              _SaleDetailItem("Folio", sale.folio),
              _SaleDetailItem("Código", sale.dispatchCode),
              _SaleDetailItem(
                "Creada",
                DateFormat("dd/MM/yyyy hh:mm a").format(sale.createdAt),
              ),
            ],
          ),
          _SaleDetailSection(
            title: "Vendedor y cliente",
            fields: [
              _SaleDetailItem("Vendedor", sale.sellerUsername),
              _SaleDetailItem("Cliente", commercialName),
              _SaleDetailItem(
                "Empleado del cliente",
                _emptyAsNotAvailable(sale.customerEmployeeName),
              ),
            ],
          ),
          _SaleDetailSection(
            title: "Producto",
            fields: [
              _SaleDetailItem("Tipo de agua", sale.waterType.dp),
              _SaleDetailItem("Unidad", sale.unitOfMeasurement.dp),
              _SaleDetailItem(
                "Cantidad",
                "${sale.quantity.toStringAsFixed(2)} ${sale.unitOfMeasurement.abbr}",
              ),
              _SaleDetailItem(
                "Litros totales",
                "${sale.totalLiters.toStringAsFixed(2)} L",
              ),
              _SaleDetailItem(
                "Litros despachados",
                "${sale.dispatchedLiters.toStringAsFixed(2)} L",
              ),
              _SaleDetailItem(
                "Litros restantes",
                "${sale.remainingLiters.toStringAsFixed(2)} L",
              ),
            ],
          ),
          _SaleDetailSection(
            title: "Cobro",
            fields: [
              _SaleDetailItem("Método", sale.paymentMethod.label),
              _SaleDetailItem(
                "Precio unitario",
                "\$${sale.unitPrice.toStringAsFixed(2)}",
              ),
              _SaleDetailItem("Total", "\$${sale.total.toStringAsFixed(2)}"),
              _SaleDetailItem(
                "Pago",
                "\$${sale.amountPaid.toStringAsFixed(2)}",
              ),
              _SaleDetailItem(
                "Cambio",
                "\$${sale.changeAmount.toStringAsFixed(2)}",
              ),
              _SaleDetailItem("Pendiente", _money(sale.pendingAmount)),
            ],
          ),
          _SaleDetailSection(
            title: "Pago y despacho",
            fields: [
              _SaleDetailItem("Pagada", _yesNo(sale.isPaid)),
              _SaleDetailItem("Fecha de pago", paidAt),
              _SaleDetailItem(
                "Usuario de cobro",
                _emptyAsNotAvailable(sale.paidByUsername),
              ),
              _SaleDetailItem("Despachada", _yesNo(sale.isDispatched)),
              _SaleDetailItem("Estado del despacho", sale.dispatchStatus.label),
              _SaleDetailItem(
                "Duración",
                "${dispatchDurationSeconds.toStringAsFixed(3)} s",
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              if (!sale.isDispatched)
                IsselButton(
                  width: 170,
                  height: 50,
                  text: "Eliminar",
                  color: colorScheme.error,
                  textColor: colorScheme.onError,
                  onTap: () => onDeleteSale(context, sale),
                ),
              IsselButton(
                width: 250,
                height: 50,
                text: "Reimprimir ticket",
                onTap: () => onReprintTicket(sale),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _money(double value) => "\$${value.toStringAsFixed(2)}";

  String _yesNo(bool value) => value ? "Sí" : "No";

  String _emptyAsNotAvailable(String? value) {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) return "N/A";
    return normalizedValue;
  }

  String _formatNullableDate(String? value) {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) return "N/A";

    final parsed = DateTime.tryParse(normalizedValue);
    if (parsed == null) return normalizedValue;
    return DateFormat("dd/MM/yyyy hh:mm a").format(parsed.toLocal());
  }
}

class _SaleDetailSection extends StatelessWidget {
  final String title;
  final List<_SaleDetailItem> fields;

  const _SaleDetailSection({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Text(title, style: textTheme.titleMedium)),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 900.0;
            final useSingleColumn = availableWidth < 640;
            final itemWidth = useSingleColumn
                ? availableWidth
                : (availableWidth - 10) / 2;
            final fieldHeight = fields.fold<double>(50, (height, field) {
              final required = _SaleDetailField.heightFor(
                context,
                field,
                itemWidth,
              );
              return required > height ? required : height;
            });

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final field in fields)
                  SizedBox(
                    width: itemWidth,
                    child: _SaleDetailField(item: field, height: fieldHeight),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SaleDetailField extends StatelessWidget {
  final _SaleDetailItem item;
  final double height;

  const _SaleDetailField({required this.item, required this.height});

  static double heightFor(
    BuildContext context,
    _SaleDetailItem item,
    double width,
  ) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final title = TextPainter(
      text: TextSpan(text: item.title, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: (width - 20) / 2);
    final value = TextPainter(
      text: TextSpan(
        text: item.value,
        style: style?.copyWith(fontWeight: FontWeight.bold),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: (width - 20) / 2);
    final height =
        (title.height > value.height ? title.height : value.height) + 12;
    title.dispose();
    value.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: item.value,
      waitDuration: const Duration(milliseconds: 350),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IsselInfoField(
          height: height,
          title: item.title,
          value: item.value,
          backColor: colorScheme.surfaceContainer,
          valueBackColor: colorScheme.surface,
        ),
      ),
    );
  }
}

class _SaleDetailItem {
  final String title;
  final String value;

  const _SaleDetailItem(this.title, this.value);
}
