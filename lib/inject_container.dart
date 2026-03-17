
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/controllers/config_garzas_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> injectContainer() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();

  locator.registerLazySingleton(() => NavigationService(),);
  locator.registerLazySingleton(() => ToastService(),);
  locator.registerLazySingleton(() => PrinterService(sharedPreferences: prefs),);

  // Global Controllers
  locator.registerLazySingleton(() => AuthController(),);
  locator.registerLazySingleton(() => ConfigGarzasController(),);

}