import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyPaymentCard extends StatelessWidget {
  const MonthlyPaymentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.total,
    required this.liters,
  });

  final IconData icon;
  final String title;
  final double total;
  final double liters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final number = NumberFormat('#,##0.00', 'es_MX');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 12,
            children: [
              Icon(icon, size: 22, color: colors.outline),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MonthlyStatisticText(
                text: '\$${number.format(total)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Row(
            spacing: 12,
            children: [
              Text(
                'Litros',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.outline,
                ),
              ),
              Expanded(
                child: _MonthlyStatisticText(
                  text: number.format(liters),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MonthlyGarzaCard extends StatelessWidget {
  const MonthlyGarzaCard({
    super.key,
    required this.title,
    required this.total,
    required this.expectedTotal,
    required this.liters,
    required this.expectedLiters,
  });

  final String title;
  final double total;
  final double expectedTotal;
  final double liters;
  final double expectedLiters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MonthlyStatisticText(
            text: title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Expanded(
                  child: _GarzaTotalsColumn(
                    title: 'Real',
                    amount: total,
                    liters: liters,
                    highlighted: true,
                  ),
                ),
                SizedBox(
                  width: 1,
                  child: ColoredBox(
                    color: colors.outline.withValues(alpha: .2),
                  ),
                ),
                Expanded(
                  child: _GarzaTotalsColumn(
                    title: 'Esperado',
                    amount: expectedTotal,
                    liters: expectedLiters,
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

class _GarzaTotalsColumn extends StatelessWidget {
  const _GarzaTotalsColumn({
    required this.title,
    required this.amount,
    required this.liters,
    this.highlighted = false,
  });

  final String title;
  final double amount;
  final double liters;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final number = NumberFormat('#,##0.00', 'es_MX');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _MonthlyStatisticText(
              text: title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.outline,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _MonthlyStatisticText(
              text: '\$${number.format(amount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: highlighted ? colors.primary : colors.onSurface,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _MonthlyStatisticText(
              text: '${number.format(liters)} L',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyStatisticText extends StatelessWidget {
  const _MonthlyStatisticText({required this.text, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: text,
    child: AutoSizeText(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: 1,
      minFontSize: 12,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
