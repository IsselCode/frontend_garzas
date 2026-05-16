import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

class ServerUnavailableView extends StatelessWidget {
  const ServerUnavailableView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      child: Container(
        decoration: BoxDecoration(gradient: AppGradients.primaryToSecondary),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 18,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 72,
                  color: colorScheme.onPrimary,
                ),
                Text(
                  'El servidor tuvo una complicacion',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                Text(
                  'No fue posible comunicarse con el backend. Verifica que el servidor este encendido y vuelve a cargar la sesion.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                IsselButton(
                  text: 'Cargar nuevamente la sesion',
                  onTap: () => _reloadSession(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reloadSession(BuildContext context) async {
    context.read<ServerStatusController>().clearUnavailable();
    await context.read<AuthController>().restoreSession();
  }
}
