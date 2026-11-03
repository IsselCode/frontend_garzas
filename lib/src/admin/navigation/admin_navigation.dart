import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../views/cash_register_view.dart';
import '../views/client_management_view.dart';
import '../views/clients_view.dart';
import '../views/config_garzas_view.dart';
import '../views/credits_view.dart';
import '../views/business_settings_view.dart';
import '../views/system_settings_view.dart';
import '../views/home_admin_view.dart';
import '../views/liters_statistics_view.dart';
import '../views/sales_reports_view.dart';
import '../views/logs_view.dart';
import '../views/pending_payments_view.dart';
import '../views/user_management_view.dart';

class AdminDestination {
  const AdminDestination(this.id, this.label, this.icon, this.page);

  final String id;
  final String label;
  final IconData icon;
  final Widget page;

  IsselNavigationItem get item =>
      IsselNavigationItem(id: id, label: label, icon: icon);
  AppRouteInfo get routeInfo => AppRouteInfo(sectionId: id, title: label);
}

const adminDestinations = [
  AdminDestination('home', 'Inicio', Icons.home_outlined, HomeAdminView()),
  AdminDestination(
    'reports',
    'Reportes',
    Icons.assessment_outlined,
    SalesReportsView(),
  ),
  AdminDestination('logs', 'Logs', Icons.receipt_long_outlined, LogsView()),
  AdminDestination(
    'cuts',
    'Cortes de caja',
    Icons.point_of_sale_outlined,
    CashRegisterView(),
  ),
  AdminDestination(
    'credits',
    'Créditos',
    Icons.account_balance_wallet_outlined,
    CreditsView(),
  ),
  AdminDestination(
    'pending',
    'Pagos pendientes',
    Icons.pending_actions_outlined,
    PendingPaymentsView(),
  ),
  AdminDestination('clients', 'Clientes', Icons.people_outline, ClientsView()),
  AdminDestination(
    'users',
    'Usuarios',
    Icons.manage_accounts_outlined,
    UserManagementView(),
  ),
  AdminDestination(
    'garzas',
    'Garzas',
    Icons.local_drink_outlined,
    ConfigGarzasView(),
  ),
  AdminDestination(
    'config',
    'Config. del negocio',
    Icons.storefront_outlined,
    BusinessSettingsView(),
  ),
  AdminDestination(
    'system-settings',
    'Config. del sistema',
    Icons.settings_outlined,
    SystemSettingsView(),
  ),
];

final adminRoutes = <Type, AppRouteInfo>{
  for (final destination in adminDestinations)
    destination.page.runtimeType: destination.routeInfo,
  LitersStatisticsView: const AppRouteInfo(sectionId: 'home', title: 'Inicio'),
  ClientManagementView: const AppRouteInfo(
    sectionId: 'clients',
    title: 'Administrar cliente',
  ),
};
