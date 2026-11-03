import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../../core/app/consts.dart';

enum CutsCreditsType { cuts, credits, pendingPayments }

class CutsCreditsDialog extends StatelessWidget {
  const CutsCreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return NotchedDialog(
      icon: Icons.account_balance_wallet_outlined,
      maxWidth: 650,
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
                  asset: AppAssets.cashRegister,
                  title: "Cortes",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () => Navigator.pop(context, CutsCreditsType.cuts),
                ),
              ),
              Material(
                child: IsselActionBox(
                  asset: AppAssets.credit,
                  title: "Creditos",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () => Navigator.pop(context, CutsCreditsType.credits),
                ),
              ),
              Material(
                child: IsselActionBox(
                  asset: AppAssets.cash,
                  title: "Pagos pendientes",
                  height: 150,
                  width: 150,
                  color: colorScheme.surfaceContainer,
                  onTap: () =>
                      Navigator.pop(context, CutsCreditsType.pendingPayments),
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
