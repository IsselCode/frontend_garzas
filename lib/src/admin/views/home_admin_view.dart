import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/users_dialog.dart';
import 'package:frontend_garzas/src/admin/views/cash_register_view.dart';
import 'package:frontend_garzas/src/admin/views/client_management_view.dart';
import 'package:frontend_garzas/src/admin/views/clients_view.dart';
import 'package:frontend_garzas/src/admin/views/config_garzas_view.dart';
import 'package:frontend_garzas/src/admin/views/general_config_view.dart';
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

    // Services
    NavigationService navigationService = locator();


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("Administración", style: textTheme.displayLarge,),
            Text("¿Qué quieres hacer hoy?", style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),),

            const SizedBox(height: 40,),

            // Elementos
            Row(
              spacing: 30,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IsselActionBox(
                  title: "Reportes y Logs",
                  asset: AppAssets.statistics,
                  onTap: () => navigationService.navigateTo(ReportsAndLogsView()),
                  height: 230,
                  width: 200,
                ),

                IsselActionBox(
                  title: "Cortes",
                  asset: AppAssets.cashRegister,
                  onTap: () => navigationService.navigateTo(CashRegisterView()),
                  height: 230,
                  width: 200,
                ),

                IsselActionBox(
                  title: "Clientes y Usuarios",
                  asset: AppAssets.customers,
                  onTap: () => openUsersDialog(context),
                  height: 230,
                  width: 200,
                ),

                IsselActionBox(
                  title: "Configuración",
                  asset: AppAssets.configs,
                  onTap: () => openConfigDialog(context),
                  height: 230,
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
