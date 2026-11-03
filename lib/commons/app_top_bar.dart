import 'package:flutter/material.dart';
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

import 'desktop_window_controls.dart';
import 'session_actions.dart';
import 'title_bar_controller.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.section,
    this.canGoBack = false,
    this.onMenuPressed,
    this.backgroundColor,
    this.onPrimaryBackground = false,
    this.actionsEnabled = true,
  });

  final AppRouteInfo? section;
  final bool canGoBack;
  final VoidCallback? onMenuPressed;
  final Color? backgroundColor;
  final bool onPrimaryBackground;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) {
    final title = context.watch<TitleBarController>();
    final role = context.select<AuthController, AppRole?>((auth) => auth.role);
    final openCash = context.select<CashRegisterController, bool>(
      (cash) => cash.openCash,
    );
    final navigation = locator<NavigationService>();
    final colors = Theme.of(context).colorScheme;
    final iconColor = onPrimaryBackground ? colors.onPrimary : colors.onSurface;
    final isAuthenticated = role != null;

    final breadcrumbs = section == null
        ? [
            IsselBreadcrumbItem(
              label: isAuthenticated && title.title.isNotEmpty
                  ? '¡Hola, ${title.title}!'
                  : '',
            ),
          ]
        : [
            const IsselBreadcrumbItem(label: 'Administración'),
            IsselBreadcrumbItem(label: section!.title),
          ];

    return Theme(
      data: Theme.of(context).copyWith(
        iconButtonTheme: IconButtonThemeData(
          style:
              Theme.of(context).iconButtonTheme.style?.copyWith(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? iconColor.withValues(alpha: 0.38)
                      : null,
                ),
              ) ??
              IconButton.styleFrom(
                disabledForegroundColor: iconColor.withValues(alpha: 0.38),
              ),
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
          titleSmall: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontSize: 16),
        ),
      ),
      child: IsselDesktopCaption(
        height: 32,
        backgroundColor: backgroundColor,
        leading: onMenuPressed == null && !canGoBack
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onMenuPressed != null)
                    IsselCaptionButton(
                      size: 32,
                      iconSize: 22,
                      tooltip: 'Abrir o cerrar menú',
                      icon: const Icon(Icons.menu),
                      color: iconColor,
                      onPressed: actionsEnabled ? onMenuPressed : null,
                    ),
                  if (canGoBack)
                    IsselCaptionButton(
                      size: 32,
                      iconSize: 22,
                      tooltip: 'Volver',
                      icon: const Icon(Icons.arrow_back),
                      color: iconColor,
                      onPressed: actionsEnabled ? navigation.goBack : null,
                    ),
                ],
              ),
        title: IsselBreadcrumbs(items: breadcrumbs),
        dragAreaBuilder: (_, child) => DragToMoveArea(child: child),
        trailing: IsselCaptionButton(
          size: 32,
          iconSize: 22,
          tooltip: title.isDarkMode ? 'Usar tema claro' : 'Usar tema oscuro',
          color: iconColor,
          icon: Icon(
            title.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          onPressed: actionsEnabled ? title.toggleTheme : null,
        ),
        actions: [
          if (isAuthenticated && role != AppRole.dispatch)
            IsselCaptionButton(
              size: 32,
              iconSize: 22,
              tooltip: 'Configurar impresora',
              icon: const Icon(Icons.print_outlined),
              color: iconColor,
              onPressed: actionsEnabled
                  ? () => _showDialog(ConfigPrinterDialog())
                  : null,
            ),
          if (role?.canSell == true)
            IsselCaptionButton(
              size: 32,
              iconSize: 22,
              tooltip: 'Registrar pago de crédito',
              icon: const Icon(Icons.payment),
              color: iconColor,
              onPressed: !actionsEnabled
                  ? null
                  : () {
                      final dialogContext =
                          navigation.navigatorKey.currentContext;
                      if (dialogContext == null) return;
                      _showDialog(CreditPaymentDialog.init(dialogContext));
                    },
            ),
          if (role?.canSell == true && openCash)
            IsselCaptionButton(
              size: 32,
              iconSize: 22,
              tooltip: 'Cerrar corte de caja',
              icon: const Icon(Icons.point_of_sale_outlined),
              color: iconColor,
              onPressed: actionsEnabled
                  ? () => _showDialog(CloseCutDialog())
                  : null,
            ),
          if (isAuthenticated)
            IsselCaptionButton(
              size: 32,
              iconSize: 22,
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              color: onPrimaryBackground ? colors.onPrimary : colors.error,
              onPressed: actionsEnabled
                  ? () {
                      final dialogContext =
                          navigation.navigatorKey.currentContext;
                      if (dialogContext != null) requestLogout(dialogContext);
                    }
                  : null,
            ),
        ],
        windowControls: DesktopWindowControls(
          brightness: onPrimaryBackground ? Brightness.dark : null,
        ),
      ),
    );
  }

  void _showDialog(Widget dialog) {
    final dialogContext =
        locator<NavigationService>().navigatorKey.currentContext;
    if (dialogContext == null) return;
    showDialog<void>(context: dialogContext, builder: (_) => dialog);
  }
}
