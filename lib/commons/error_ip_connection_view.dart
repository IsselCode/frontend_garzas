import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';

class ErrorIpConnectionView extends StatelessWidget {
  const ErrorIpConnectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryToSecondary
        ),
        child: Center(
          child: Text("Ocurrió un error con la conexión del servidor"),
        ),
      ),
    );
  }
}
