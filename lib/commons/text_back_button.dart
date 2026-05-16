import 'package:flutter/material.dart';

class TextBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;

  const TextBackButton({super.key, this.onTap, this.text = "Ir atras"});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ?? () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 5,
          children: [
            Icon(Icons.arrow_back_ios_new_outlined, color: colorScheme.primary),
            Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
