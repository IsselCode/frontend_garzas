import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class ConfirmFinishDispatchDialog extends StatelessWidget {
  const ConfirmFinishDispatchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Terminar despacho',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              'Estas seguro que deseas terminar el despacho?',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Divider(color: colorScheme.outline),
            IsselButton(
              text: 'Terminar',
              color: Colors.red,
              onTap: () => Navigator.pop(context, true),
            ),
            IsselButton(
              text: 'Volver',
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
