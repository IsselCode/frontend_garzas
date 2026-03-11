
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> injectContainer() async {

  locator.registerLazySingleton(() => NavigationService(),);

}