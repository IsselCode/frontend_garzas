import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/scaled_text_style.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:frontend_garzas/src/sales/views/generate_ticket_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../core/app/consts.dart';
import '../../../core/services/regex_service.dart';
import '../../../inject_container.dart';
import '../../admin/clean/enums/enums.dart';
import '../../admin/clean/widgets/config_garza_container.dart';
import '../clean/widgets/select_payment_method_sale_widget.dart';

class FinishOrderView extends StatelessWidget {
  FinishOrderView._();

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<OrderController>(),
      child: FinishOrderView._(),
    );
  }

  static Widget initWithController(OrderController controller) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: FinishOrderView._(),
    );
  }

  final FocusNode buttonFocus = FocusNode();
  final FocusNode clientMoneyFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;
    // Services

    // Controllers
    OrderController orderController = context.watch();
    final pendingDispatch = orderController.pendingDispatchToSettle;
    final waterType =
        pendingDispatch?.waterType ??
        WaterType.fromTabSwitcher(orderController.state);
    final unitOfMeasurement =
        pendingDispatch?.unitOfMeasurement ??
        UnitOfMeasurement.fromTabSwitcher(orderController.stateUnit);
    final quantityText = pendingDispatch == null
        ? orderController.quantityController.text
        : _formatQuantity(
            pendingDispatch.quantity ?? pendingDispatch.dispensedVolume,
          );

    return Scaffold(
      body: Stack(
        children: [
          // Body
          LayoutBuilder(
            builder: (context, constraints) {
              final scaleFactor = (constraints.maxWidth / 1366).clamp(1.0, 1.7);
              final panelWidth = 320 * scaleFactor;
              final leftSpacing = 20 * scaleFactor;
              final rightSpacing = 30 * scaleFactor;
              final sectionSpacing = 5 * scaleFactor;
              final controlHeight = 60 * scaleFactor;
              final paymentIconSize = 64 * scaleFactor;

              return Row(
                children: [
                  //* Left
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: panelWidth,
                        child: Column(
                          spacing: leftSpacing,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Cliente",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            IsselTextFormField(
                              height: controlHeight,
                              hintText: "Publico general",
                              controller: TextEditingController(
                                text: orderController
                                    .selectedClient
                                    ?.commercialName,
                              ),
                              readOnly: true,
                            ),
                            Text(
                              "Tipo de agua",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            IsselTextFormField(
                              height: controlHeight,
                              hintText: "Tipo de agua",
                              controller: TextEditingController(
                                text: waterType.dp,
                              ),
                              readOnly: true,
                            ),
                            Text(
                              "${unitOfMeasurement == UnitOfMeasurement.liters ? "Litros" : "Galones"} a vender",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            IsselTextFormField(
                              height: controlHeight,
                              hintText: "Tipo de agua",
                              controller: TextEditingController(
                                text: quantityText,
                              ),
                              readOnly: true,
                            ),
                            if (pendingDispatch != null) ...[
                              Text(
                                "Referencia",
                                style: scaledTextStyle(
                                  textTheme.titleMedium,
                                  scaleFactor,
                                ),
                              ),
                              IsselTextFormField(
                                height: controlHeight,
                                hintText: "Referencia",
                                controller: TextEditingController(
                                  text: pendingDispatch.plateOrUnitReference,
                                ),
                                readOnly: true,
                              ),
                            ],
                            Text(
                              "Cantidad a cobrar",
                              style: scaledTextStyle(
                                textTheme.titleMedium,
                                scaleFactor,
                              ),
                            ),
                            _TotalText(
                              height: controlHeight,
                              scaleFactor: scaleFactor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //* Right
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryToSecondary,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: panelWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: rightSpacing,
                            children: [
                              Text(
                                "Termina tu venta",
                                style: scaledTextStyle(
                                  textTheme.displaySmall,
                                  scaleFactor,
                                  color: colorScheme.onPrimary,
                                ),
                              ),

                              Row(
                                spacing: 10 * scaleFactor,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SelectPaymentMethodSaleWidget(
                                    image: AppAssets.cash,
                                    size: paymentIconSize,
                                    selected:
                                        orderController.paymentMethod ==
                                        PaymentMethod.cash,
                                    onTap: () => orderController.paymentMethod =
                                        PaymentMethod.cash,
                                  ),
                                  SelectPaymentMethodSaleWidget(
                                    image: AppAssets.card,
                                    size: paymentIconSize,
                                    selected:
                                        orderController.paymentMethod ==
                                        PaymentMethod.card,
                                    onTap: () => orderController.paymentMethod =
                                        PaymentMethod.card,
                                  ),
                                  SelectPaymentMethodSaleWidget(
                                    image: AppAssets.credit,
                                    size: paymentIconSize,
                                    selected:
                                        orderController.paymentMethod ==
                                        PaymentMethod.credit,
                                    onTap: () => orderController.paymentMethod =
                                        PaymentMethod.credit,
                                  ),
                                ],
                              ),

                              if (orderController.paymentMethod ==
                                  PaymentMethod.cash)
                                Flex(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: sectionSpacing,
                                  children: [
                                    Text(
                                      "Cliente paga con:",
                                      style: scaledTextStyle(
                                        textTheme.titleSmall,
                                        scaleFactor,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    IsselTextFormField(
                                      height: controlHeight,
                                      hintText: "\$500",
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        RegexService.positiveNumberFormatter,
                                      ],
                                      controller:
                                          orderController.clientMoneyCtrl,
                                      autofocus: true,
                                      focusNode: clientMoneyFocus,
                                      onSubmitted: (value) =>
                                          calculateTotalRemaining(context),
                                    ),
                                    Text(
                                      "Cantidad a devolver",
                                      style: scaledTextStyle(
                                        textTheme.titleSmall,
                                        scaleFactor,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    IsselPill(
                                      widget: Text(
                                        "\$${(orderController.totalRemaining ?? 0.0).toStringAsFixed(2)}",
                                        textAlign: TextAlign.center,
                                        style: textTheme.titleLarge?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      height: controlHeight,
                                    ),
                                  ],
                                ),
                              IsselButton(
                                height: controlHeight,
                                text: orderController.isPendingDispatchPayment
                                    ? "Cobrar despacho"
                                    : "Generar Venta",
                                focusNode: buttonFocus,
                                onTap: () => createSell(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // AppBar
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton(),
          ),
        ],
      ),
    );
  }

  void calculateTotalRemaining(BuildContext context) {
    OrderController orderController = context.read();
    CtrlResponse response = orderController.calculateTotalRemaining();

    if (response.success) {
      buttonFocus.requestFocus();
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
      clientMoneyFocus.requestFocus();
    }
  }

  void createSell(BuildContext context) async {
    OrderController orderController = context.read();
    CtrlResponse<SaleEntity> response = await orderController.createSell();
    if (!context.mounted) return;

    if (response.success) {
      NavigationService navigationService = locator();
      navigationService.pushAndRemoveUntil(GenerateTicketView.init(context));
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }
  }
}

String _formatQuantity(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

class _TotalText extends StatefulWidget {
  final double height;
  final double scaleFactor;

  const _TotalText({required this.height, required this.scaleFactor});

  @override
  State<_TotalText> createState() => _TotalTextState();
}

class _TotalTextState extends State<_TotalText> {
  late Future<CtrlResponse<double>> _future;

  @override
  void initState() {
    super.initState();
    OrderController orderController = context.read();
    _future = orderController.calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    //* Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IsselShimmer(
            delay: Duration(milliseconds: 0),
            width: double.infinity,
            height: widget.height,
          );
        }

        double value = snapshot.data!.element!;

        return IsselTextFormField(
          height: widget.height,
          hintText: "Total",
          style: scaledTextStyle(
            textTheme.titleLarge,
            widget.scaleFactor,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
          readOnly: true,
          controller: TextEditingController(
            text: "\$${value.toStringAsFixed(2)}",
          ),
        );
      },
    );
  }
}
