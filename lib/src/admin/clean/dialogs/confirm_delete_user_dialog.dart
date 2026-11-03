import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';

class ConfirmDeleteUserDialog extends StatelessWidget {
  const ConfirmDeleteUserDialog({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context) => NotchedConfirmationDialog(
    icon: Icons.delete_outline,
    title: 'Eliminar usuario',
    message: '¿Estás seguro de que quieres eliminar al usuario $username?',
    confirmText: 'Eliminar',
    cancelText: 'Volver',
    destructive: true,
  );
}
