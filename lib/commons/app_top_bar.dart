import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_garzas/commons/dialogs/exit_to_app_dialog.dart';
import 'package:frontend_garzas/commons/issel_snap_layouts_caption.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/close_cut_dialog.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/config_printer_dialog.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/credit_payment_dialog/credit_payment_dialog.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const _topBarIconScale = 1.35;

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = locator<NavigationService>();
    final titleBarController = context.watch<TitleBarController>();
    final authController = context.watch<AuthController>();
    final cashRegisterController = context.watch<CashRegisterController>();

    return SizedBox(
      height: Size.fromHeight(kWindowCaptionHeight).height,
      child: IsselSnapLayoutsCaption(
        icon: null,
        title: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleBarController.title.isNotEmpty
                    ? "¡Hola, ${titleBarController.title}!"
                    : "",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IsselToggle(
                onChanged: (value) => titleBarController.toggleTheme(),
                value: titleBarController.isDarkMode,
                height: 45,
                width: 50,
                backColor: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
        ),
        actions: [
          if (authController.session != null &&
              authController.session!.role != AppRole.dispatch)
            IsselWindowCaptionAction(
              icon: Transform.scale(
                scale: _topBarIconScale,
                child: const Icon(Icons.print_outlined),
              ),
              onPressed: () {
                final dialogContext =
                    navigationService.navigatorKey.currentContext;
                if (dialogContext == null) return;
                showDialog(
                  context: dialogContext,
                  builder: (context) => ConfigPrinterDialog(),
                );
              },
            ),
          if (authController.session != null &&
              authController.session!.role.canSell)
            IsselWindowCaptionAction(
              icon: Transform.scale(
                scale: _topBarIconScale,
                child: const Icon(Icons.payment, color: Colors.blue),
              ),
              onPressed: () {
                final dialogContext =
                    navigationService.navigatorKey.currentContext;
                if (dialogContext == null) return;
                showDialog(
                  context: dialogContext,
                  builder: (context) => CreditPaymentDialog.init(context),
                );
              },
            ),
          if (authController.session != null &&
              authController.session!.role.canSell &&
              cashRegisterController.openCash)
            IsselWindowCaptionAction(
              icon: Transform.scale(
                scale: _topBarIconScale,
                child: const FaIcon(
                  FontAwesomeIcons.cashRegister,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
              onPressed: () {
                final dialogContext =
                    navigationService.navigatorKey.currentContext;
                if (dialogContext == null) return;
                showDialog(
                  context: dialogContext,
                  builder: (context) => CloseCutDialog(),
                );
              },
            ),
          if (authController.session != null)
            IsselWindowCaptionAction(
              icon: Transform.scale(
                scale: _topBarIconScale,
                child: const Icon(Icons.exit_to_app, color: Colors.red),
              ),
              onPressed: () {
                final dialogContext =
                    navigationService.navigatorKey.currentContext;
                if (dialogContext == null) return;
                showDialog(
                  context: dialogContext,
                  builder: (context) => ExitToAppDialog(),
                );
              },
            ),
        ],
      ),
    );
  }
}
