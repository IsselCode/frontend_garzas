import 'package:flutter/material.dart';

class TextBackButton extends StatelessWidget {
  const TextBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 5,
          children: [
            Icon(Icons.arrow_back_ios_new_outlined, color: colorScheme.primary,),
            Text("Ir atrás", style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
