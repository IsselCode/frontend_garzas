import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class ConfirmAlarmDispatchDialog extends StatelessWidget {
  final int garzaNumber;
  final List<String> alarms;

  const ConfirmAlarmDispatchDialog({
    super.key,
    required this.garzaNumber,
    required this.alarms,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final alarmText = alarms.isEmpty ? 'alarma activa' : alarms.join(', ');

    return Dialog(
      child: Container(
        width: 380,
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
              'Garza con alarma',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              'La garza $garzaNumber tiene una alarma activa: $alarmText. Deseas continuar de todos modos?',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Divider(color: colorScheme.outline),
            IsselButton(
              text: 'Continuar despacho',
              onTap: () => Navigator.pop(context, true),
            ),
            IsselButton(
              text: 'Cancelar',
              color: Colors.red,
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
