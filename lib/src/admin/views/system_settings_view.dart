import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import '../../../commons/title_bar_controller.dart';
import '../../../core/services/app_preferences.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/theme_mode_selector.dart';

class SystemSettingsView extends StatefulWidget {
  const SystemSettingsView({super.key});

  @override
  State<SystemSettingsView> createState() => _SystemSettingsViewState();
}

class _SystemSettingsViewState extends State<SystemSettingsView> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppPreferences>();
    final titleBar = context.watch<TitleBarController>();
    final auth = context.read<AuthController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AbsorbPointer(
              absorbing: _saving,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSection(
                      title: 'Sesión',
                      children: [
                        IsselToggleField(
                          title: 'Recordar sesión',
                          value: preferences.rememberSession,
                          onChanged: (value) =>
                              _save(() => auth.setRememberSession(value)),
                          backColor: colors.surface,
                          valueBackColor: colors.surfaceContainer,
                        ),
                        IsselToggleField(
                          title: 'Confirmar antes de cerrar sesión',
                          value: preferences.confirmBeforeLogout,
                          onChanged: (value) => _save(
                            () => preferences.setConfirmBeforeLogout(value),
                          ),
                          backColor: colors.surface,
                          valueBackColor: colors.surfaceContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SettingsSection(
                      title: 'Ventana',
                      children: [
                        IsselToggleField(
                          title: 'Iniciar maximizada',
                          value: preferences.startMaximized,
                          onChanged: (value) =>
                              _save(() => preferences.setStartMaximized(value)),
                          backColor: colors.surface,
                          valueBackColor: colors.surfaceContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SettingsSection(
                      title: 'Apariencia',
                      children: [
                        ThemeModeSelector(
                          isDarkMode: titleBar.isDarkMode,
                          onChanged: (value) =>
                              _save(() => titleBar.setDarkMode(value)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(Future<bool> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = await action();
      if (mounted && !saved) {
        locator<ToastService>().error('No se pudo guardar la preferencia.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
