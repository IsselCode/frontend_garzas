import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'notched_dialog.dart';

class ExitToAppDialog extends StatelessWidget {
  const ExitToAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return NotchedDialog(
      icon: Icons.logout_outlined,
      iconBackgroundColor: colors.error,
      iconColor: colors.onError,
      maxWidth: 400,
      onClose: () => Navigator.of(context).pop(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            'Cerrar sesión',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          IsselButton(
            text: 'Cerrar sesión',
            height: 48,
            color: colors.error,
            textColor: colors.onError,
            onTap: () => context.read<AuthController>().logout(),
          ),
          IsselButton(
            text: 'Volver',
            height: 48,
            color: Colors.transparent,
            textColor: colors.primary,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
