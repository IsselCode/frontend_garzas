import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/credit_payment_dialog/credit_payment_dialog_controller.dart';
import 'package:frontend_garzas/src/sales/clean/entities/credit_entity.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import '../../../../../commons/text_back_button.dart';
import '../../../../../core/app/consts.dart';
import '../../../../../core/services/regex_service.dart';
import '../../../../../inject_container.dart';
import '../../../../admin/clean/enums/enums.dart';
import '../../widgets/select_payment_method_sale_widget.dart';

class CreditPaymentDialog extends StatefulWidget {

  CreditPaymentDialog._();

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreditPaymentDialogController(
        salesApi: locator(),
        context: context,
        toastService: locator()
      ),
      child: CreditPaymentDialog._(),
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
        width: controller.pageController.positions.isEmpty ? 350 : controller.pageController.page != 1 ? 350 : 900,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24)
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 15,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Row(
                mainAxisAlignment: controller.indexPage != 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
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
                  Text(
                    controller.title,
                    style: textTheme.titleMedium,
                  ),
                ],
              ),

              SizedBox(
                height: controller.indexPage == 0 ? 83 : controller.indexPage == 2 ? 165 : 400,
                child: PageView(
                  controller: controller.pageController,
                  children: [
                    _InsertClientPhone(),
                    _SelectCredit(),
                    _CreateCredit()
                  ],
                ),
              ),


              // Divisor
              Divider(color: colorScheme.outline,),

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
                  if (controller.indexPage != 1)
                  Expanded(
                    child: IsselButton(
                      text: "Continuar",
                      textColor: colorScheme.onPrimary,
                      color: colorScheme.primary,
                      onTap: () async => controller.enter(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}



class _InsertClientPhone extends StatelessWidget {

  _InsertClientPhone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    CreditPaymentDialogController controller = context.read();

    return Center(
      child: Form(
        key: controller.clientPhoneKey,
        child: IsselTextFormField(
          controller: controller.clientPhoneCtrl,
          hintText: "Número de teléfono",
          prefixIcon: Icons.phone_outlined,
          inputFormatters: [RegexService.phoneFormatter],
          validator: (value) {
            if (value == null || value.isEmpty) return "Campo requerido";
            if (value.length < 7) return "El teléfono es demasiado corto";
            if (value.length > 12) return "El teléfono es demasiado largo";
          },
        ),
      ),
    );
  }

}

class _SelectCredit extends StatelessWidget {

  _SelectCredit({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    CreditPaymentDialogController controller = context.read();

    return SizedBox(
      height: 360,
      child: IsselTableWidget(
        onTapRow: (index) {
          CreditEntity credit = controller.creditsClient[index];
          controller.selectedCredit = credit;
        },
        header: IsselHeaderTable(titleHeaders: ["Total", "Pagado", "Pendiente", "Fecha"]),
        rows: controller.creditsClient.map((e) {
          return IsselRowTable(
            cells: [
              IsselPill(text: e.total.toStringAsFixed(2), color: colorScheme.surfaceContainer,),
              IsselPill(text: e.amountPaid.toStringAsFixed(2), color: colorScheme.surfaceContainer),
              IsselPill(text: e.salePendingAmount.toStringAsFixed(2), color: colorScheme.surfaceContainer),
              IsselPill(text: DateFormat("dd-MM-yy hh:mm a").format(e.createdAt), color: colorScheme.surfaceContainer),
            ]
          );
        },).toList()
      ),
    );
  }

}

class _CreateCredit extends StatelessWidget {

  _CreateCredit({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    CreditPaymentDialogController controller = context.read();

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
              selected: controller.selectedPaymentMethod == PaymentMethod.cash,
              onTap: () => controller.selectedPaymentMethod = PaymentMethod.cash,
            ),
            SelectPaymentMethodSaleWidget(
              image: AppAssets.card,
              selected: controller.selectedPaymentMethod == PaymentMethod.card,
              onTap: () => controller.selectedPaymentMethod = PaymentMethod.card,
            ),
          ],
        ),
        Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Text("Total a pagar", style: textTheme.titleSmall,),
              IsselPill(
                text: controller.selectedCredit!.salePendingAmount.toStringAsFixed(2),
              )
            ],
          ),
      ],
    );
  }

}
