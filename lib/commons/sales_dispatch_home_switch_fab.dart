import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/home_dispatch_view.dart';
import 'package:provider/provider.dart';

enum SalesDispatchHomeTarget { sales, dispatch }

class SalesDispatchHomeSwitchFab extends StatelessWidget {
  final SalesDispatchHomeTarget target;

  const SalesDispatchHomeSwitchFab({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (authController.role != AppRole.salesDispatch) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      heroTag: 'sales_dispatch_home_switch_${target.name}',
      onPressed: () => _switchHome(context),
      child: const Icon(Icons.swap_horiz),
    );
  }

  void _switchHome(BuildContext context) {
    switch (target) {
      case SalesDispatchHomeTarget.sales:
        context.read<AuthController>().navigateToOpenCashRegisterCut();
        return;
      case SalesDispatchHomeTarget.dispatch:
        locator<NavigationService>().pushAndRemoveUntil(
          const HomeDispatchView(),
        );
        return;
    }
  }
}
