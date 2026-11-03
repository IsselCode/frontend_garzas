import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';

class ConfirmFinishDispatchDialog extends StatelessWidget {
  const ConfirmFinishDispatchDialog({super.key});

  @override
  Widget build(BuildContext context) => const NotchedConfirmationDialog(
    icon: Icons.stop_circle_outlined,
    title: 'Terminar despacho',
    message: '¿Estás seguro de que deseas terminar el despacho?',
    confirmText: 'Terminar',
    cancelText: 'Volver',
    destructive: true,
  );
}
