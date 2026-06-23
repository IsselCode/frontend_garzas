import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_garzas/commons/app_top_bar.dart';
import 'package:frontend_garzas/commons/server_unavailable_view.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/config_garzas_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/credits_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/users_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/sales/views/home_sales_view.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final prefs = await SharedPreferences.getInstance();
  // await prefs.remove('cached_backend_ip');
  // await prefs.remove('cached_backend_port');

  await injectContainer();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1366, 768),
    minimumSize: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    windowButtonVisibility: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => locator<TitleBarController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<ServerStatusController>(),
        ),
        ChangeNotifierProvider(create: (context) => locator<AuthController>()),
        ChangeNotifierProvider(create: (context) => locator<UsersController>()),
        ChangeNotifierProvider(
          create: (context) => locator<ClientsController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<CashRegisterController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<ConfigGarzasController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<GeneralConfigController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<StatisticsController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<DispatchController>(),
        ),
        ChangeNotifierProvider(
          create: (context) => locator<CreditsController>(),
        ),
      ],
      child:
          Consumer4<
            TitleBarController,
            AuthController,
            DispatchController,
            ServerStatusController
          >(
            builder:
                (
                  context,
                  titleBarController,
                  authController,
                  dispatchController,
                  serverStatusController,
                  child,
                ) {
                  NavigationService navigationService = locator();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    dispatchController.syncRuntimeStream(
                      shouldRun:
                          authController.session?.role.canDispatch == true,
                    );
                  });

                  return GlobalLoaderOverlay(
                    child: ToastificationWrapper(
                      child: MaterialApp(
                        title: 'Flutter Demo',
                        debugShowCheckedModeBanner: false,
                        theme: titleBarController.currentTheme,
                        locale: const Locale('es', 'MX'),
                        supportedLocales: const [
                          Locale('es', 'MX'),
                          Locale('es'),
                          Locale('en'),
                        ],
                        localizationsDelegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        navigatorKey: navigationService.navigatorKey,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              child!,
                              if (serverStatusController.serverUnavailable)
                                const Positioned.fill(
                                  child: ServerUnavailableView(),
                                ),
                              const AppTopBar(),
                            ],
                          );
                        },
                        home: HomeSalesView(),
                      ),
                    ),
                  );
                },
          ),
    );
  }
}
