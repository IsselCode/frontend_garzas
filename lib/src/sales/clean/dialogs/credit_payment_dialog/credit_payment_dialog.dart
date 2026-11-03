import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/credit_payment_dialog/credit_payment_dialog_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app/consts.dart';
import '../../../../../inject_container.dart';
import '../../../../admin/clean/enums/enums.dart';
import '../../../../admin/widgets/admin_table_viewport.dart';
import '../../widgets/select_payment_method_sale_widget.dart';

class CreditPaymentDialog extends StatefulWidget {
  const CreditPaymentDialog._();

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreditPaymentDialogController(
        salesApi: locator(),
        clientsApi: locator(),
        context: context,
        toastService: locator(),
      ),
      child: const CreditPaymentDialog._(),
    );
  }

  @override
  State<CreditPaymentDialog> createState() => _ConfigPrinterDialogState();
}

class _ConfigPrinterDialogState extends State<CreditPaymentDialog> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    CreditPaymentDialogController controller = context.watch();

    return NotchedDialog(
      icon: Icons.payments_outlined,
      maxWidth: controller.pageController.positions.isEmpty
          ? 450
          : controller.pageController.page != 1
          ? 450
          : 1065,
      onClose: controller.isPayingCredits
          ? null
          : () => Navigator.of(context).pop(),
      child: Column(
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: controller.indexPage != 0
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (controller.indexPage != 0)
                IconButton(
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back),
                  color: colorScheme.primary,
                  onPressed: controller.isPayingCredits
                      ? null
                      : () {
                          if (controller.indexPage == 2) {
                            controller.pageController.jumpToPage(1);
                          } else {
                            controller.pageController.jumpToPage(0);
                          }
                        },
                ),
              Expanded(
                child: Text(
                  controller.title,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          SizedBox(
            height: controller.indexPage == 0
                ? 260
                : controller.indexPage == 2
                ? 230
                : 400,
            child: PageView(
              controller: controller.pageController,
              children: [
                const _SelectClient(),
                const _SelectCredit(),
                const _CreateCredit(),
              ],
            ),
          ),

          // Divisor
          Divider(color: colorScheme.outline),

          Row(
            spacing: 5,
            children: [
              //* Cancelar
              Expanded(
                child: IsselButton(
                  text: "Salir",
                  color: Colors.transparent,
                  textColor: colorScheme.onSurface,
                  onTap: controller.isPayingCredits
                      ? null
                      : () {
                          Navigator.pop(context, false);
                        },
                ),
              ),

              //* Continuar
              Expanded(
                child: IsselButton(
                  text: "Continuar",
                  textColor: colorScheme.onPrimary,
                  color: colorScheme.primary,
                  onTap:
                      controller.isPayingCredits ||
                          (controller.indexPage == 1 &&
                              controller.selectedCredits.isEmpty)
                      ? null
                      : () async => controller.enter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectClient extends StatelessWidget {
  const _SelectClient();

  @override
  Widget build(BuildContext context) {
    CreditPaymentDialogController controller = context.watch();
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: controller.clientSearchKey,
      child: Column(
        spacing: 10,
        children: [
          IsselTextFormField(
            controller: controller.commercialNameCtrl,
            hintText: "Nombre comercial",
            prefixIcon: Icons.search,
            fillColor: colors.surfaceContainer,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Campo requerido";
              }
              return null;
            },
            onSubmitted: (_) => controller.searchClients(),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: controller.clients.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                ClientEntity client = controller.clients[index];
                return IsselRadioTile<ClientEntity>(
                  value: client,
                  groupValue: controller.selectedClient,
                  label: client.commercialName,
                  alignment: Alignment.centerLeft,
                  surfaceColor: colors.surfaceContainer,
                  height: 45,
                  onChanged: (value) => controller.selectedClient = value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectCredit extends StatelessWidget {
  const _SelectCredit();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    CreditPaymentDialogController controller = context.watch();

    return Column(
      spacing: 10,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            Text("${controller.selectedCredits.length} seleccionados"),
            IsselButton(
              width: 230,
              height: 45,
              text: controller.allCreditsSelected
                  ? "Quitar selección"
                  : "Seleccionar todos",
              color: colorScheme.primary,
              onTap: controller.creditsClient.isEmpty
                  ? null
                  : controller.toggleSelectAllCredits,
            ),
          ],
        ),
        Expanded(
          child: controller.creditsClient.isEmpty
              ? const Center(child: Text("No hay creditos pendientes"))
              : AdminTableViewport(
                  minWidth: 1000,
                  child: IsselTableWidget(
                    color: colorScheme.surfaceContainer,
                    onTapRow: (index) => controller.toggleCreditSelection(
                      controller.creditsClient[index],
                    ),
                    header: IsselHeaderTable(
                      titleHeaders: ["Folio", "Total", "Pendiente", "Fecha"],
                      colorPills: colorScheme.surface,
                    ),
                    rows: controller.creditsClient.map((credit) {
                      final selected = controller.isCreditSelected(credit);
                      final rowColor = selected
                          ? colorScheme.primary
                          : colorScheme.surface;
                      final rowTextColor = selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface;

                      IsselPill cell(String value) => IsselPill(
                        color: rowColor,
                        widget: Tooltip(
                          message: value,
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: rowTextColor,
                            ),
                          ),
                        ),
                      );

                      return IsselRowTable(
                        cells: [
                          cell(credit.saleFolio),
                          cell(credit.total.toStringAsFixed(2)),
                          cell(credit.salePendingAmount.toStringAsFixed(2)),
                          cell(
                            DateFormat(
                              "dd-MM-yy hh:mm a",
                            ).format(credit.createdAt),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CreateCredit extends StatelessWidget {
  const _CreateCredit();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    // Controllers
    CreditPaymentDialogController controller = context.watch();
    PaymentMethod selectedPaymentMethod = controller.selectedPaymentMethod;

    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectPaymentMethodSaleWidget(
                image: AppAssets.cash,
                selected: selectedPaymentMethod == PaymentMethod.cash,
                onTap: () =>
                    controller.selectedPaymentMethod = PaymentMethod.cash,
              ),
              SelectPaymentMethodSaleWidget(
                image: AppAssets.card,
                selected: selectedPaymentMethod == PaymentMethod.card,
                onTap: () =>
                    controller.selectedPaymentMethod = PaymentMethod.card,
              ),
            ],
          ),
        ),
        Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              "Total a pagar (${controller.selectedCredits.length} creditos)",
              style: textTheme.titleSmall,
            ),
            IsselPill(
              text: controller.selectedCreditsTotal.toStringAsFixed(2),
              color: colors.surfaceContainer,
            ),
          ],
        ),
      ],
    );
  }
}
