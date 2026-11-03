import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../../core/app/consts.dart';

enum ConfigType { general, garzas }

class ConfigDialog extends StatelessWidget {
  const ConfigDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return NotchedDialog(
      icon: Icons.settings_outlined,
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
                  asset: AppAssets.configs,
                  title: "Config. general",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () => Navigator.pop(context, ConfigType.general),
                ),
              ),
              Material(
                child: IsselActionBox(
                  asset: AppAssets.waterTank,
                  title: "Config. de garzas",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () => Navigator.pop(context, ConfigType.garzas),
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
