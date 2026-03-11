import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/theme.dart';
import 'package:frontend_garzas/src/auth/views/splash_view.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app/consts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1366, 768),
    minimumSize: Size(640, 480),
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

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              height: Size.fromHeight(kWindowCaptionHeight).height,
              child: SnapLayoutsCaption(
                icon: Image.asset(AppAssets.logo),
                title: null,
                backgroundColor: lightTheme.scaffoldBackgroundColor,
                actions: [
                  WindowCaptionAction(
                    icon: Icon(Icons.favorite_outline),
                    onPressed: () => print("Añadiendo a favorito"),
                  ),
                ],
              ),
            ),
            Expanded(child: child!)
          ],
        );
      },
      home: SplashView(),
    );
  }
}