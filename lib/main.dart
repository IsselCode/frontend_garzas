import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/theme.dart';
import 'package:frontend_garzas/src/auth/views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      home: SplashView(),
    );
  }
}