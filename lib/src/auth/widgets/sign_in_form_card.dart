import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class SignInFormCard extends StatelessWidget {
  const SignInFormCard({
    super.key,
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.onLogin,
    this.maxHeight,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      constraints: maxHeight == null
          ? null
          : BoxConstraints(maxHeight: maxHeight!),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IsselTextFormField(
                controller: userController,
                hintText: 'Usuario',
                prefixIcon: Icons.person_outline,
                fillColor: colorScheme.surfaceContainer,
                height: 52,
                inputFormatters: [RegexService.usernameFormatter],
                validator: (value) => RegexService.usernameValidator(value),
              ),
              const SizedBox(height: 16),
              IsselTextFormField(
                controller: passwordController,
                hintText: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                fillColor: colorScheme.surfaceContainer,
                height: 52,
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              IsselButton(
                text: 'Iniciar sesión',
                color: colorScheme.primary,
                height: 54,
                onTap: onLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
