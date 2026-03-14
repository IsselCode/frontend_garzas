import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../../core/app/consts.dart';

enum ConfigType {
  general,
  garzas
}

class ConfigDialog extends StatelessWidget {
  const ConfigDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 450,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Column(
          spacing: 25,
          mainAxisSize: MainAxisSize.min,
          children: [
            //* Imagen
            IsselAssetContainer(
              asset: AppAssets.logo,
              height: 84,
              width: 84,
            ),
            //* Titulo
            Text("¿Qué harás?", style: textTheme.headlineMedium,),
            //* Action Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 25,
              children: [
                Material(
                  child: IsselActionBox(
                    asset: AppAssets.configs,
                    title: "Configuración General",
                    height: 150,
                    width: 150,
                    color: colorScheme.surfaceContainer,
                    onTap: () => Navigator.pop(context, ConfigType.general,),
                  ),
                ),
                Material(
                  child: IsselActionBox(
                    asset: AppAssets.waterTank,
                    title: "Configurar Garzas",
                    height: 150,
                    width: 150,
                    color: colorScheme.surfaceContainer,
                    onTap: () => Navigator.pop(context, ConfigType.garzas,),
                  ),
                )
              ],
            ),
            //* Cancelar
            IsselButton(
              color: Colors.transparent,
              textColor: AppColors.grey,
              text: "Cancelar",
              onTap: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}
