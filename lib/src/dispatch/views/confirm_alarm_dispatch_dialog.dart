import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';

class ConfirmAlarmDispatchDialog extends StatelessWidget {
  const ConfirmAlarmDispatchDialog({
    super.key,
    required this.garzaNumber,
    required this.alarms,
  });
  final int garzaNumber;
  final List<String> alarms;

  @override
  Widget build(BuildContext context) {
    final alarmText = alarms.isEmpty ? 'alarma activa' : alarms.join(', ');
    return NotchedConfirmationDialog(
      icon: Icons.warning_amber_rounded,
      title: 'Garza con alarma',
      message:
          'La garza $garzaNumber tiene una alarma activa: $alarmText. '
          '¿Deseas continuar de todos modos?',
      confirmText: 'Continuar despacho',
    );
  }
}
