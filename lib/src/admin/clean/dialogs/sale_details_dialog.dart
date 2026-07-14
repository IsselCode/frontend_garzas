import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth - 96).clamp(650.0, 900.0);
    final commercialName = sale.commercialName?.trim().isNotEmpty == true
        ? sale.commercialName!
        : "Publico general";

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text("Detalle de venta", style: textTheme.titleLarge),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SaleDetailSection(
                title: "Ticket",
                fields: [
                  _SaleDetailItem("Folio", sale.folio),
                  _SaleDetailItem(
                    "Fecha",
                    DateFormat("dd/MM/yy hh:mm a").format(sale.createdAt),
                  ),
                  _SaleDetailItem("Codigo", sale.dispatchCode),
                  _SaleDetailItem("Empleado", sale.sellerUsername),
                ],
              ),
              _SaleDetailSection(
                title: "Cliente y producto",
                fields: [
                  _SaleDetailItem("Cliente", commercialName),
                  _SaleDetailItem(
                    "ID cliente",
                    sale.clientId?.toString() ?? "N/A",
                  ),
                  _SaleDetailItem("Tipo de agua", sale.waterType.dp),
                  _SaleDetailItem(
                    "Cantidad",
                    "${sale.quantity.toStringAsFixed(2)} ${sale.unitOfMeasurement.abbr}",
                  ),
                ],
              ),
              _SaleDetailSection(
                title: "Cobro",
                fields: [
                  _SaleDetailItem("Metodo", sale.paymentMethod.label),
                  _SaleDetailItem(
                    "Precio unitario",
                    "\$${sale.unitPrice.toStringAsFixed(2)}",
                  ),
                  _SaleDetailItem(
                    "Total",
                    "\$${sale.total.toStringAsFixed(2)}",
                  ),
                  _SaleDetailItem(
                    "Pago",
                    "\$${sale.amountPaid.toStringAsFixed(2)}",
                  ),
                  _SaleDetailItem(
                    "Cambio",
                    "\$${sale.changeAmount.toStringAsFixed(2)}",
                  ),
                  _SaleDetailItem(
                    "Estado",
                    // sale.isDispatched ? "Despachada" : "Pendiente",
                    sale.dispatchStatus.label
                  ),
                ],
              ),
              _SaleDetailSection(
                title: "Tiempo y empleado del cliente",
                fields: [
                  _SaleDetailItem(
                    "Segundos",
                    "${(sale.dispatchDurationMS / 1000).toStringAsFixed(3)} s",
                  ),
                  _SaleDetailItem(
                    "Empleado",
                    sale.customerEmployeeName ?? "",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!sale.isDispatched)
          IsselButton(
            width: 170,
            height: 50,
            text: "Eliminar",
            color: Colors.red,
            onTap: () => onDeleteSale(context, sale),
          ),
        IsselButton(
          text: "Cerrar",
          width: 120,
          height: 50,
          onTap: () => Navigator.of(context).pop(),
        ),
        IsselButton(
          width: 250,
          height: 50,
          text: "Reimprimir ticket",
          onTap: () => onReprintTicket(sale),
        ),
      ],
    );
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

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final field in fields)
                  SizedBox(
                    width: itemWidth,
                    child: _SaleDetailField(item: field),
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

  const _SaleDetailField({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final valueWidth = (availableWidth / 2) - 20;
        final maxValueCharacters = (valueWidth / 8).floor().clamp(4, 90);

        return Tooltip(
          message: item.value,
          waitDuration: const Duration(milliseconds: 350),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: IsselInfoField(
              height: 50,
              title: item.title,
              value: _truncateSingleLine(item.value, maxValueCharacters),
              backColor: colorScheme.surfaceContainer,
              valueBackColor: colorScheme.surface,
            ),
          ),
        );
      },
    );
  }

  String _truncateSingleLine(String value, int maxCharacters) {
    final normalizedValue = value.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalizedValue.length <= maxCharacters) {
      return normalizedValue;
    }

    if (maxCharacters <= 3) {
      return normalizedValue.substring(0, maxCharacters);
    }

    return "${normalizedValue.substring(0, maxCharacters - 3)}...";
  }
}

class _SaleDetailItem {
  final String title;
  final String value;

  const _SaleDetailItem(this.title, this.value);
}
