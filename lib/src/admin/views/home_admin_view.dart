import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/cuts_credits_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/reports_logs_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/users_dialog.dart';
import 'package:frontend_garzas/src/admin/views/cash_register_view.dart';
import 'package:frontend_garzas/src/admin/views/clients_view.dart';
import 'package:frontend_garzas/src/admin/views/config_garzas_view.dart';
import 'package:frontend_garzas/src/admin/views/credits_view.dart';
import 'package:frontend_garzas/src/admin/views/general_config_view.dart';
import 'package:frontend_garzas/src/admin/views/liters_statistics_view.dart';
import 'package:frontend_garzas/src/admin/views/pending_payments_view.dart';
import 'package:frontend_garzas/src/admin/views/reports_and_logs_view.dart';
import 'package:frontend_garzas/src/admin/views/user_management_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../inject_container.dart';
import '../clean/dialogs/config_dialog.dart';

class HomeAdminView extends StatelessWidget {
  const HomeAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Administración", style: textTheme.displayLarge),
            Text(
              "¿Qué quieres hacer hoy?",
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),

            const SizedBox(height: 40),

            // Elementos
            Row(
              spacing: 30,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IsselActionBox(
                  title: "Reportes y Logs",
                  asset: AppAssets.statistics,
                  onTap: () => openReportsLogsDialog(context),
                  height: 240,
                  width: 200,
                ),

                IsselActionBox(
                  title: "Finanzas",
                  asset: AppAssets.cashRegister,
                  onTap: () => openCutsCreditsDialog(context),
                  height: 240,
                  width: 200,
                ),

                IsselActionBox(
                  title: "Clientes y Usuarios",
                  asset: AppAssets.customers,
                  onTap: () => openUsersDialog(context),
                  height: 240,
                  width: 200,
                ),

                IsselActionBox(
                  title: "Configuración",
                  asset: AppAssets.configs,
                  onTap: () => openConfigDialog(context),
                  height: 240,
                  width: 200,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openUsersDialog(BuildContext context) async {
    UsersType? type = await showDialog<UsersType>(
      context: context,
      builder: (context) => UsersDialog(),
    );

    if (type == null) return;

    NavigationService navigationService = locator();
    if (type == UsersType.users) {
      navigationService.navigateTo(UserManagementView());
    } else {
      navigationService.navigateTo(ClientsView());
    }
  }

  void openCutsCreditsDialog(BuildContext context) async {
    CutsCreditsType? type = await showDialog<CutsCreditsType>(
      context: context,
      builder: (context) => CutsCreditsDialog(),
    );

    if (type == null) return;

    NavigationService navigationService = locator();
    if (type == CutsCreditsType.cuts) {
      navigationService.navigateTo(CashRegisterView());
    } else if (type == CutsCreditsType.credits) {
      navigationService.navigateTo(CreditsView());
    } else {
      navigationService.navigateTo(PendingPaymentsView());
    }
  }

  void openReportsLogsDialog(BuildContext context) async {
    ReportsLogsType? type = await showDialog<ReportsLogsType>(
      context: context,
      builder: (context) => const ReportsLogsDialog(),
    );

    if (type == null) return;

    NavigationService navigationService = locator();
    if (type == ReportsLogsType.reportsAndLogs) {
      navigationService.navigateTo(const ReportsAndLogsView());
    } else {
      navigationService.navigateTo(const LitersStatisticsView());
    }
  }

  void openConfigDialog(BuildContext context) async {
    ConfigType? type = await showDialog<ConfigType>(
      context: context,
      builder: (context) => ConfigDialog(),
    );

    if (type == null) return;

    NavigationService navigationService = locator();
    if (type == ConfigType.garzas) {
      navigationService.navigateTo(ConfigGarzasView());
    } else {
      navigationService.navigateTo(GeneralConfigView());
    }
  }
}
