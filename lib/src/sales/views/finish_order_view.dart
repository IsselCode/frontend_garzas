import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:frontend_garzas/src/sales/views/generate_ticket_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../core/services/regex_service.dart';
import '../../../inject_container.dart';

class FinishOrderView extends StatelessWidget {
  FinishOrderView({super.key});

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<OrderController>(),
      child: FinishOrderView(),
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

    return Scaffold(
      body: Stack(
        children: [
          // AppBara3
          Positioned(
            top: kWindowCaptionHeight,
            left: 10,
            child: TextBackButton()
          ),
          // Body
          Row(
            children: [

              //* Left
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Tipo de agua", style: textTheme.titleMedium,),
                        IsselTextFormField(
                          hintText: "Tipo de agua",
                          controller: orderController.quantityController,
                          readOnly: true,
                        ),
                        Text("Litros a vender", style: textTheme.titleMedium),
                        IsselTextFormField(
                          hintText: "Tipo de agua",
                          controller: orderController.quantityController,
                          readOnly: true,
                        ),
                        Text("Cantidad a cobrar", style: textTheme.titleMedium),
                        _TotalText()
                      ],
                    ),
                  ),
                ),
              ),

              //* Right
              Expanded(
                  child: ColoredBox(
                    color: colorScheme.primary,
                    child: Center(
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 30,
                          children: [
                            Text("Termina tu venta", style: textTheme.displaySmall?.copyWith(color: colorScheme.onPrimary),),
                            Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Text("Cliente paga con:", style: textTheme.titleSmall?.copyWith(color: colorScheme.onPrimary),),
                                IsselTextFormField(
                                  hintText: "\$500",
                                  textAlign: TextAlign.center,
                                  inputFormatters: [RegexService.positiveNumberFormatter],
                                  controller: orderController.clientMoneyCtrl,
                                  autofocus: true,
                                  focusNode: clientMoneyFocus,
                                  onSubmitted: (value) => calculateTotalRemaining(context),
                                ),
                                Text("Cantidad a devolver", style: textTheme.titleSmall?.copyWith(color: colorScheme.onPrimary),),
                                IsselPill(
                                  text: "\$${orderController.totalRemaining}",
                                  textColor: colorScheme.primary,
                                  height: 60,
                                ),
                              ],
                            ),
                            IsselButton(
                              text: "Generar Venta",
                              focusNode: buttonFocus,
                              onTap: () => createSell(context),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              )

            ],
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
    CtrlResponse response = await orderController.createSell();

    if (response.success){
      NavigationService navigationService = locator();
      navigationService.pushAndRemoveUntil(GenerateTicketView());
    } else {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }

  }

}


class _TotalText extends StatefulWidget {
  const _TotalText({super.key});

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

        if (snapshot.connectionState == ConnectionState.waiting){
          return IsselShimmer(
            delay: Duration(milliseconds: 0),
            width: double.infinity,
            height: 60
          );
        }

        double value = snapshot.data!.element!;

        return IsselTextFormField(
          hintText: "Total",
          style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
          textAlign: TextAlign.center,
          readOnly: true,
          controller: TextEditingController(text: "\$${value.toStringAsFixed(2)}"),
        );

      },
    );
  }
}
