import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';

class ConfirmDeleteClientDialog extends StatelessWidget {
  const ConfirmDeleteClientDialog({super.key, required this.client});
  final String client;

  @override
  Widget build(BuildContext context) => NotchedConfirmationDialog(
    icon: Icons.delete_outline,
    title: 'Eliminar cliente',
    message: '¿Estás seguro de que quieres eliminar al cliente $client?',
    confirmText: 'Eliminar',
    cancelText: 'Volver',
    destructive: true,
  );
}
