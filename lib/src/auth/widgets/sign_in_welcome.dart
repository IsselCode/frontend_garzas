import 'package:flutter/material.dart';

class SignInWelcome extends StatelessWidget {
  const SignInWelcome({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Bienvenido',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: compact ? 56 : 68,
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Inicia sesión para continuar',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
