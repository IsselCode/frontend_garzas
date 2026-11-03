import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import '../../../../commons/ctrl_response.dart';
import '../../../../commons/entities/user_entity.dart';
import '../../clean/enums/enums.dart';

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.user, required this.onSubmit});
  final UserEntity? user;
  final Future<CtrlResponse> Function(
    String username,
    String displayName,
    String password,
    AppRole role,
  )
  onSubmit;
  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _username, _name;
  final _password = TextEditingController();
  late AppRole _role;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.user?.username);
    _name = TextEditingController(text: widget.user?.displayName);
    _role = widget.user?.role ?? AppRole.seller;
  }

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_saving,
      child: NotchedDialog(
        icon: widget.user == null ? Icons.person_add_alt : Icons.edit_outlined,
        maxWidth: 480,
        onClose: _saving ? null : () => Navigator.of(context).pop(false),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.user == null ? 'Nuevo usuario' : 'Editar usuario',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              IsselTextFormField(
                controller: _username,
                hintText: 'Usuario',
                prefixIcon: Icons.person_outline,
                height: 48,
                fillColor: colors.surfaceContainer,
                readOnly: _saving,
                validator: (value) => _length(value, 3, 50),
              ),
              const SizedBox(height: 12),
              IsselTextFormField(
                controller: _name,
                hintText: 'Nombre',
                prefixIcon: Icons.badge_outlined,
                height: 48,
                fillColor: colors.surfaceContainer,
                readOnly: _saving,
                validator: (value) => _length(value, 3, 100),
              ),
              const SizedBox(height: 12),
              IsselTextFormField(
                controller: _password,
                hintText: widget.user == null
                    ? 'Contraseña'
                    : 'Nueva contraseña (opcional)',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                height: 48,
                fillColor: colors.surfaceContainer,
                readOnly: _saving,
                validator: (value) =>
                    widget.user != null && (value?.isEmpty ?? true)
                    ? null
                    : _length(value, 6, 128, trim: false),
              ),
              const SizedBox(height: 12),
              AbsorbPointer(
                absorbing: _saving,
                child: IsselDropdown<AppRole>(
                  value: _role,
                  hintText: 'Rol',
                  height: 48,
                  color: colors.surfaceContainer,
                  items: AppRole.values
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.label),
                        ),
                      )
                      .toList(),
                  onChanged: (role) {
                    if (role != null) setState(() => _role = role);
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: IsselButton(
                      text: 'Cancelar',
                      height: 44,
                      color: colors.surfaceContainer,
                      textColor: colors.primary,
                      onTap: _saving ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IsselButton(
                      text: _saving ? 'Guardando…' : 'Guardar',
                      height: 44,
                      onTap: _saving ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _length(String? value, int min, int max, {bool trim = true}) {
    final length = (trim ? value?.trim() : value)?.length ?? 0;
    return length < min || length > max
        ? 'Ingresa entre $min y $max caracteres'
        : null;
  }

  Future<void> _submit() async {
    if (_saving || _form.currentState?.validate() != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final response = await widget.onSubmit(
      _username.text.trim(),
      _name.text.trim(),
      _password.text,
      _role,
    );
    if (!mounted) return;
    if (response.success) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _saving = false;
      _error = response.message ?? 'No se pudo guardar el usuario';
    });
  }
}
