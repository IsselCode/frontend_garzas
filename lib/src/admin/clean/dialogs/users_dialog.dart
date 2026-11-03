import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../../core/app/consts.dart';

enum UsersType { users, customers }

class UsersDialog extends StatelessWidget {
  const UsersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return NotchedDialog(
      icon: Icons.manage_accounts_outlined,
      maxWidth: 450,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        spacing: 25,
        mainAxisSize: MainAxisSize.min,
        children: [
          //* Titulo
          Text("¿Qué harás?", style: textTheme.headlineMedium),
          //* Action Boxes
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 25,
            runSpacing: 16,
            children: [
              Material(
                child: IsselActionBox(
                  asset: AppAssets.customers,
                  title: "Clientes",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () => Navigator.pop(context, UsersType.customers),
                ),
              ),
              Material(
                child: IsselActionBox(
                  asset: AppAssets.users,
                  title: "Usuarios",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () => Navigator.pop(context, UsersType.users),
                ),
              ),
            ],
          ),
          //* Cancelar
          IsselButton(
            color: Colors.transparent,
            textColor: AppColors.grey,
            text: "Cancelar",
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
