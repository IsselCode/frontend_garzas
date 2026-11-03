import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/app_preferences.dart';
import '../src/auth/controllers/auth_controller.dart';
import 'dialogs/exit_to_app_dialog.dart';

Future<void> requestLogout(BuildContext context) async {
  if (!context.read<AppPreferences>().confirmBeforeLogout) {
    await context.read<AuthController>().logout();
    return;
  }
  await showDialog<void>(context: context, builder: (_) => ExitToAppDialog());
}
