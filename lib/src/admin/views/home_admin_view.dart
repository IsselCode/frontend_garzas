import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/button_container.dart';
import 'package:frontend_garzas/src/admin/views/config_view.dart';
import 'package:frontend_garzas/src/admin/views/customers_view.dart';
import 'package:frontend_garzas/src/admin/views/reports_and_logs_view.dart';
import 'package:frontend_garzas/src/admin/views/user_management_view.dart';

import '../../../inject_container.dart';

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

                ButtonContainer(
                  title: "Reportes y Logs",
                  asset: AppAssets.statistics,
                  onTap: () => navigationService.navigateTo(ReportsAndLogsView()),
                ),

                ButtonContainer(
                  title: "Configuración",
                  asset: AppAssets.configs,
                  onTap: () => navigationService.navigateTo(ConfigView()),
                ),

                ButtonContainer(
                  title: "Gestionar usuarios",
                  asset: AppAssets.users,
                  onTap: () => navigationService.navigateTo(UserManagementView()),
                ),

                ButtonContainer(
                  title: "Clientes",
                  asset: AppAssets.customers,
                  onTap: () => navigationService.navigateTo(CustomersView()),
                )

              ],
            ),

          ],
        ),
      ),
    );
  }
}
