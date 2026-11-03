import 'package:frontend_garzas/commons/widgets/paged_list_panel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'admin_table_viewport.dart';

class SalesReportPanel extends StatelessWidget {
  const SalesReportPanel({
    super.key,
    required this.loadSales,
    required this.searchNode,
    required this.dateFilters,
    required this.onSearch,
    required this.onSaleDetails,
  });
  final Future<CtrlResponse> loadSales;
  final FocusNode searchNode;
  final Widget dateFilters;
  final ValueChanged<String> onSearch;
  final ValueChanged<SaleEntity> onSaleDetails;

  @override
  Widget build(BuildContext context) {
    final statistics = context.watch<StatisticsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme.copyWith(
      labelMedium: theme.textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
    return FutureBuilder(
      future: loadSales,
      builder: (context, snapshot) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 18,
                              child: Text(
                                'Folio',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              child: IsselTextFormField(
                                focusNode: searchNode,
                                height: 40,
                                prefixIcon: Icons.search,
                                fillColor: colorScheme.surfaceContainer,
                                hintText: "Folio",
                                onSubmitted: onSearch,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: dateFilters),
                    ],
                  ),
                ],
              ),
              // Table
              Expanded(
                child: PagedListPanel(
                  state: statistics.salesPaging,
                  onPageChanged: (page) => statistics.getSales(page: page),
                  child: AdminTableViewport(
                    child: IsselTableWidget(
                      onTapRow: (index) =>
                          onSaleDetails(statistics.showedSales[index]),
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
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
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
                                    message:
                                        sell.commercialName ??
                                        "Público General",
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        sell.commercialName ??
                                            "Público General",
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
                                  widget: AutoSizeText(
                                    "${sell.quantity} ${sell.unitOfMeasurement.abbr}",
                                    style: textTheme.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                                // Total
                                IsselPill(
                                  color: colorScheme.surfaceContainer,
                                  widget: AutoSizeText(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sell.paymentMethod.label,
                                          style: textTheme.labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Image.asset(
                                        sell.paymentMethod.image,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                                // Fecha
                                IsselPill(
                                  color: colorScheme.surfaceContainer,
                                  padding: EdgeInsets.zero,
                                  widget: Tooltip(
                                    message: DateFormat(
                                      "dd/MM/yy hh:mm:ss a",
                                    ).format(sell.createdAt),
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: AutoSizeText(
                                        DateFormat(
                                          "dd/MM/yy hh:mm:ss a",
                                        ).format(sell.createdAt),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
