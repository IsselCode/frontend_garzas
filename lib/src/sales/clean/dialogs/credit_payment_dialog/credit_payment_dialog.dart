import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/credit_payment_dialog/credit_payment_dialog_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import '../../../../../commons/text_back_button.dart';
import '../../../../../core/app/consts.dart';
import '../../../../../inject_container.dart';
import '../../../../admin/clean/enums/enums.dart';
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

    return Dialog(
      child: Container(
        width: controller.pageController.positions.isEmpty
            ? 450
            : controller.pageController.page != 1
            ? 450
            : 1065,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
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
                    TextBackButton(
                      onTap: () {
                        if (controller.indexPage == 2) {
                          controller.pageController.jumpToPage(1);
                        } else {
                          controller.pageController.jumpToPage(0);
                        }
                      },
                    ),
                  Text(controller.title, style: textTheme.titleMedium),
                ],
              ),

              SizedBox(
                height: controller.indexPage == 0
                    ? 260
                    : controller.indexPage == 2
                    ? 175
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
                      onTap: () {
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
        ),
      ),
    );
  }
}

class _SelectClient extends StatelessWidget {
  const _SelectClient();

  @override
  Widget build(BuildContext context) {
    CreditPaymentDialogController controller = context.watch();

    return Form(
      key: controller.clientSearchKey,
      child: Column(
        spacing: 10,
        children: [
          IsselTextFormField(
            controller: controller.commercialNameCtrl,
            hintText: "Nombre comercial",
            prefixIcon: Icons.search,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              : IsselTableWidget(
                  onTapRow: (index) => controller.toggleCreditSelection(
                    controller.creditsClient[index],
                  ),
                  header: IsselHeaderTable(
                    titleHeaders: ["Folio", "Total", "Pendiente", "Fecha"],
                  ),
                  rows: controller.creditsClient.map((credit) {
                    final selected = controller.isCreditSelected(credit);
                    final rowColor = selected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainer;
                    final rowTextColor = selected
                        ? colorScheme.onPrimaryContainer
                        : null;

                    return IsselRowTable(
                      cells: [
                        IsselPill(
                          text: credit.saleFolio,
                          color: rowColor,
                          textColor: rowTextColor,
                        ),
                        IsselPill(
                          text: credit.total.toStringAsFixed(2),
                          color: rowColor,
                          textColor: rowTextColor,
                        ),
                        IsselPill(
                          text: credit.salePendingAmount.toStringAsFixed(2),
                          color: rowColor,
                          textColor: rowTextColor,
                        ),
                        IsselPill(
                          text: DateFormat(
                            "dd-MM-yy hh:mm a",
                          ).format(credit.createdAt),
                          color: rowColor,
                          textColor: rowTextColor,
                        ),
                      ],
                    );
                  }).toList(),
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
    // Controllers
    CreditPaymentDialogController controller = context.watch();
    PaymentMethod selectedPaymentMethod = controller.selectedPaymentMethod;

    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
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
        Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              "Total a pagar (${controller.selectedCredits.length} creditos)",
              style: textTheme.titleSmall,
            ),
            IsselPill(text: controller.selectedCreditsTotal.toStringAsFixed(2)),
          ],
        ),
      ],
    );
  }
}
