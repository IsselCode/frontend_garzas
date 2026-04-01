import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/config_garzas_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/users_controller.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/general_api.dart';
import 'package:frontend_garzas/src/admin/data/logs_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/admin/data/users_api.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/data/auth_api.dart';
import 'package:frontend_garzas/src/auth/data/auth_storage.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> injectContainer() async {
  final prefs = await SharedPreferences.getInstance();

  locator.registerSingleton<SharedPreferences>(prefs);

  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => ToastService());
  locator.registerLazySingleton(() => TitleBarController());
  locator.registerLazySingleton(() => PrinterService(sharedPreferences: locator()),);

  locator.registerLazySingleton(() => AuthStorage(sharedPreferences: locator()),);
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => AuthApi(apiClient: locator()));
  locator.registerLazySingleton(() => UsersApi(apiClient: locator()),);
  locator.registerLazySingleton(() => ClientsApi(apiClient: locator()),);
  locator.registerLazySingleton(() => GarzasApi(apiClient: locator()),);
  locator.registerLazySingleton(() => GeneralApi(apiClient: locator()),);
  locator.registerLazySingleton(() => LogsApi(apiClient: locator()),);
  locator.registerLazySingleton(() => SalesApi(apiClient: locator()),);
  locator.registerLazySingleton(() => CashRegisterApi(apiClient: locator()),);

  // controllers
  locator.registerLazySingleton(() => CashRegisterController(cashRegisterApi: locator()));
  locator.registerLazySingleton(() => GeneralConfigController(generalApi: locator()));
  locator.registerLazySingleton(() => DispatchController(salesApi: locator(), garzasApi: locator(), generalConfigController: locator(), printerService: locator()));

  locator.registerLazySingleton(
    () => AuthController(
      cashRegisterController: locator(),
      generalConfigController: locator(),
      authApi: locator(),
      authStorage: locator(),
      apiClient: locator(),
      navigationService: locator(),
      titleBarController: locator(),
    ),
  );

  locator.registerLazySingleton(() => UsersController(usersApi: locator()),);
  locator.registerLazySingleton(() => ClientsController(clientsApi: locator()),);
  locator.registerLazySingleton(() => ConfigGarzasController(garzasApi: locator()));
  locator.registerLazySingleton(() => StatisticsController(logsApi: locator(), salesApi: locator()));
}
