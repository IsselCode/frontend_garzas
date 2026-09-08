import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

enum ReportsLogsType { reportsAndLogs, litersStatistics }

class ReportsLogsDialog extends StatelessWidget {
  const ReportsLogsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 25,
          children: [
            IsselAssetContainer(asset: AppAssets.logo, height: 84, width: 84),
            Text("\u00BFQu\u00E9 har\u00E1s?", style: textTheme.headlineMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 25,
              children: [
                Material(
                  child: IsselActionBox(
                    asset: AppAssets.statistics,
                    title: "Reportes y Logs",
                    height: 150,
                    width: 150,
                    color: colorScheme.surfaceContainer,
                    onTap: () =>
                        Navigator.pop(context, ReportsLogsType.reportsAndLogs),
                  ),
                ),
                Material(
                  child: IsselActionBox(
                    asset: AppAssets.waterTank,
                    title: "Estad\u00EDsticas de litros",
                    height: 150,
                    width: 150,
                    color: colorScheme.surfaceContainer,
                    onTap: () => Navigator.pop(
                      context,
                      ReportsLogsType.litersStatistics,
                    ),
                  ),
                ),
              ],
            ),
            IsselButton(
              color: Colors.transparent,
              textColor: AppColors.grey,
              text: "Cancelar",
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
