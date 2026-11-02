import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/core/utils/print_timing.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/app/consts.dart';
import '../../../core/services/navigation_service.dart';
import '../../../inject_container.dart';
import 'home_sales_view.dart';

class GenerateTicketView extends StatefulWidget {
  final PrintTiming timing;

  const GenerateTicketView._({required this.timing});

  static Widget init(BuildContext context, {required PrintTiming timing}) {
    return ChangeNotifierProvider.value(
      value: context.read<OrderController>(),
      child: GenerateTicketView._(timing: timing),
    );
  }

  @override
  State<GenerateTicketView> createState() => _GenerateTicketViewState();
}

class _GenerateTicketViewState extends State<GenerateTicketView> {
  @override
  void initState() {
    super.initState();
    _printAndReturnHome();
  }

  Future<void> _printAndReturnHome() async {
    final orderController = context.read<OrderController>();
    try {
      await orderController.printTicket(timing: widget.timing);
    } catch (error) {
      widget.timing.event('error durante la impresión: ${error.runtimeType}');
      locator<ToastService>().error('No se pudo imprimir el ticket');
    } finally {
      try {
        NavigationService navigationService = locator();
        navigationService.pushAndRemoveUntil(HomeSalesView());
      } finally {
        await widget.timing.finish();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.primaryToSecondary),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, 100),
                child: Text(
                  "Generando Ticket",
                  style: textTheme.displayMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
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
