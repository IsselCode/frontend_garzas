import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
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

    return NotchedDialog(
      icon: Icons.assessment_outlined,
      maxWidth: 450,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 25,
        children: [
          Text("\u00BFQu\u00E9 har\u00E1s?", style: textTheme.headlineMedium),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 25,
            runSpacing: 16,
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
                  onTap: () =>
                      Navigator.pop(context, ReportsLogsType.litersStatistics),
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
    );
  }
}
