import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

class ConfirmDeleteClientDialog extends StatefulWidget {

  String client;

  ConfirmDeleteClientDialog({
    super.key,
    required this.client
  });

  @override
  State<ConfirmDeleteClientDialog> createState() => _ConfigPrinterDialogState();
}

class _ConfigPrinterDialogState extends State<ConfirmDeleteClientDialog> {

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
                    "Eliminar cliente",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  //* Description
                  Text(
                    "¿Estas seguro que quieres eliminar al cliente: ${widget.client}?",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Divisor
              Divider(color: colorScheme.outline,),
              //* Cerrar Sesión
              IsselButton(
                text: "Eliminar",
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context, true);
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
