import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:frontend_garzas/src/sales/views/finish_order_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../inject_container.dart';

class StartOrderView extends StatelessWidget {

  StartOrderView._();

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderController(),
      builder: (context, child) => StartOrderView._(),
    );
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //* Theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    //* Controllers
    OrderController orderController = context.watch();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: kWindowCaptionHeight),
          child: TextBackButton(),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Form(
            key: formKey,
            child: Column(
              spacing: 40,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Comenzar Orden", style: textTheme.displayLarge,),
                Text("Selecciona el tipo de agua", style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),),
                IsselTabSwitcher(
                  state: orderController.state,
                  leftText: "Potable",
                  rightText: "Pozo",
                  onChanged: (value) => orderController.state = value,
                ),
                Text("Ingresa la cantidad a vender en litros", style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),),
                IsselTextFormField(
                  hintText: "1000",
                  controller: orderController.quantityController,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                  inputFormatters: [RegexService.positiveNumberFormatter],
                  validator: (value) {
                    if (value == null) return "Ingresa la cantidad de litros a vender";
                    if (value.isEmpty) return "Ingresa la cantidad de litros a vender";
                    if (int.tryParse(value)! <= 0) return "Ingresa un valor positivo";
                    return null;
                  },
                  onSubmitted: (value) => finishOrder(context),
                )
              ],

            ),
          ),
        ),
      ),
    );
  }

  void finishOrder(BuildContext context) async {

    if(!formKey.currentState!.validate()) {
      return;
    }

    NavigationService navigationService = locator();
    navigationService.navigateTo(FinishOrderView());

  }

}


