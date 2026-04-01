import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/home_dispatch_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/app/consts.dart';
import '../../../core/services/navigation_service.dart';
import '../../../inject_container.dart';

class GenerateTicketDispatchView extends StatefulWidget {

  const GenerateTicketDispatchView();

  @override
  State<GenerateTicketDispatchView> createState() => _GenerateTicketDispatchViewState();
}

class _GenerateTicketDispatchViewState extends State<GenerateTicketDispatchView> {

  @override
  void initState() {
    super.initState();
    DispatchController dispatchController = context.read();
    dispatchController.printTicket().then((value) {
      NavigationService navigationService = locator();
      navigationService.pushAndRemoveUntil(HomeDispatchView());
    },);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryToSecondary
        ),
        child: Center(
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
      ),
    );
  }
}
