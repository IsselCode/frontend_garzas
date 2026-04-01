import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_garzas/commons/dialogs/exit_to_app_dialog.dart';
import 'package:frontend_garzas/commons/issel_snap_layouts_caption.dart';
import 'package:frontend_garzas/commons/title_bar_controller.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/controllers/cash_register_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/config_garzas_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/users_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/views/open_cash_register_cut_view.dart';
import 'package:frontend_garzas/src/auth/views/splash_view.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/close_cut_dialog.dart';
import 'package:frontend_garzas/src/sales/clean/dialogs/config_printer_dialog.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app/consts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (context) => locator<TitleBarController>(),),
        ChangeNotifierProvider(create: (context) => locator<AuthController>()),
        ChangeNotifierProvider(create: (context) => locator<UsersController>()),
        ChangeNotifierProvider(create: (context) => locator<ClientsController>()),
        ChangeNotifierProvider(create: (context) => locator<CashRegisterController>()),
        ChangeNotifierProvider(create: (context) => locator<ConfigGarzasController>(),),
        ChangeNotifierProvider(create: (context) => locator<GeneralConfigController>(),),
        ChangeNotifierProvider(create: (context) => locator<StatisticsController>(),),
        ChangeNotifierProvider(create: (context) => locator<DispatchController>(),),
      ],
      child: Consumer<TitleBarController>(
        builder: (context, controller, child) {
          NavigationService navigationService = locator();
          CashRegisterController cashRegisterController = locator();
          AuthController authController = context.read();

          return GlobalLoaderOverlay(
            child: ToastificationWrapper(
              child: MaterialApp(
                title: 'Flutter Demo',
                debugShowCheckedModeBanner: false,
                theme: controller.currentTheme,
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
                      SizedBox(
                        height: Size.fromHeight(kWindowCaptionHeight).height,
                        child: IsselSnapLayoutsCaption(
                          icon: Image.asset(AppAssets.logo),
                          title: Material(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.title.isNotEmpty
                                      ? "¡Hola, ${controller.title}!"
                                      : "",
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                IsselToggle(
                                  onChanged: (value) =>
                                      controller.toggleTheme(),
                                  value: controller.isDarkMode,
                                  height: 35,
                                  width: 45,
                                  backColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            if (authController.session != null && authController.session!.role != AppRole.admin)
                            IsselWindowCaptionAction(
                              icon: Icon(Icons.print_outlined),
                              onPressed: () {
                                final dialogContext = navigationService
                                    .navigatorKey
                                    .currentContext;
                                if (dialogContext == null) return;
                                showDialog(
                                  context: dialogContext,
                                  builder: (context) => ConfigPrinterDialog(),
                                );
                              },
                            ),
                            if (authController.session != null && authController.session!.role == AppRole.seller && cashRegisterController.openCash)
                            IsselWindowCaptionAction(
                                icon: Icon(Icons.money, color: Colors.blue,),
                                onPressed: () {
                                  authController.session!.role == AppRole.seller;
                                  final dialogContext = navigationService.navigatorKey.currentContext;
                                  if (dialogContext == null) return;
                                  showDialog(
                                    context: dialogContext,
                                    builder: (context) => CloseCutDialog(),
                                  );
                                },
                              ),
                            IsselWindowCaptionAction(
                              icon: Icon(Icons.exit_to_app, color: Colors.red,),
                              onPressed: () {
                                final dialogContext = navigationService.navigatorKey.currentContext;
                                if (dialogContext == null) return;
                                showDialog(
                                  context: dialogContext,
                                  builder: (context) => ExitToAppDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                home: SplashView(),
              ),
            ),
          );
        },
      ),
    );
  }
}
