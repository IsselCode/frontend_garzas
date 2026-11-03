import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import '../../../../core/app/theme.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _ThemeModeCard(
            label: 'Claro',
            dark: false,
            selected: !isDarkMode,
            onTap: () => onChanged(false),
            colors: colors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ThemeModeCard(
            label: 'Oscuro',
            dark: true,
            selected: isDarkMode,
            onTap: () => onChanged(true),
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.label,
    required this.dark,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool dark;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return IsselPill(
      height: 250,
      padding: const EdgeInsets.all(10),
      color: colors.surface,
      onTap: onTap,
      widget: Column(
        children: [
          Expanded(
            child: _ThemePreview(
              dark: dark,
              selected: selected,
              colors: colors,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 17,
                color: selected ? colors.primary : colors.outline,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? colors.primary : colors.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({
    required this.dark,
    required this.selected,
    required this.colors,
  });

  final bool dark;
  final bool selected;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final previewTheme = dark ? darkTheme : lightTheme;
    final background = previewTheme.scaffoldBackgroundColor;
    final panel = previewTheme.colorScheme.surface;
    final accent = selected ? colors.primary : colors.outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent, width: selected ? 1.5 : 1),
      ),
      child: Row(
        spacing: 5,
        children: [
          Container(
            width: 24,
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 5,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    Expanded(child: _ThemePreviewLine(color: panel)),
                    Expanded(child: _ThemePreviewLine(color: panel)),
                    Expanded(child: _ThemePreviewLine(color: panel)),
                  ],
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreviewLine extends StatelessWidget {
  const _ThemePreviewLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
