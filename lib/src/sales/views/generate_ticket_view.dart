import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/app/consts.dart';
import '../../../core/services/navigation_service.dart';
import '../../../inject_container.dart';
import 'home_sales_view.dart';

class GenerateTicketView extends StatefulWidget {

  const GenerateTicketView._();

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<OrderController>(),
      child: GenerateTicketView._(),
    );
  }



  @override
  State<GenerateTicketView> createState() => _GenerateTicketViewState();
}

class _GenerateTicketViewState extends State<GenerateTicketView> {

  @override
  void initState() {
    super.initState();
    OrderController orderController = context.read();
    orderController.printTicket().then((value) {
      NavigationService navigationService = locator();
      navigationService.pushAndRemoveUntil(HomeSalesView());
    },);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, 100),
              child: Text("Generando Ticket", style: textTheme.displayMedium?.copyWith(color: colorScheme.onPrimary),)
            ),
            Lottie.asset(
              AppLotties.scan,
              width: 500,
              height: 500,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
