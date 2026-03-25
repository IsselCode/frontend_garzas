import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/data/auth_api.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../core/app/consts.dart';
import '../../../../inject_container.dart';

class ExitToAppDialog extends StatefulWidget {


  ExitToAppDialog({super.key});

  @override
  State<ExitToAppDialog> createState() => _ConfigPrinterDialogState();
}

class _ConfigPrinterDialogState extends State<ExitToAppDialog> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    AuthController authController = context.read();

    return Dialog(
      child: Container(
        width: 350,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            spacing: 15,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titulo
              Flex(
                direction: Axis.vertical,
                spacing: 10,
                children: [
                  //* Titulo
                  Text(
                    "Cerrar Sesión",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  //* Description
                  Text(
                    "¿Estas seguro que quieres cerrar sesión?",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Divisor
              Divider(color: colorScheme.outline,),
              //* Cerrar Sesión
              IsselButton(
                text: "Cerrar Sesión",
                color: Colors.red,
                onTap: () {
                  authController.logout();
                },
              ),
              //* Cancelar
              IsselButton(
                text: "Volver",
                onTap: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
