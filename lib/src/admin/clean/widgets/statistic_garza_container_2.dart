import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

class StatisticGarzaContainer_2 extends StatelessWidget {
  final String asset;
  final String title;
  final double total;
  final double expectedTotal;
  final double liters;
  final double expectedLiters;

  const StatisticGarzaContainer_2({
    super.key,
    required this.asset,
    required this.title,
    required this.total,
    required this.expectedTotal,
    required this.liters,
    required this.expectedLiters,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 150.0;
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final compact = height < 112;
        final padding = compact ? 6.0 : 10.0;
        final contentWidth = (width - (padding * 2)).clamp(0.0, 300.0);
        final titleStyle = compact
            ? textTheme.labelMedium?.copyWith(height: 1)
            : textTheme.titleSmall;

        return Container(
          width: 300,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    asset,
                    height: compact ? 30 : 42,
                    width: compact ? 30 : 42,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: compact ? 2 : 6,
                        children: [
                          _StatisticText(
                            text: title,
                            style: titleStyle,
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            spacing: compact ? 6 : 8,
                            children: [
                              Expanded(
                                child: _GarzaTotalsColumn(
                                  title: "Real",
                                  amount: total,
                                  liters: liters,
                                  compact: compact,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: compact ? 34 : 42,
                                color: colorScheme.outlineVariant,
                              ),
                              Expanded(
                                child: _GarzaTotalsColumn(
                                  title: "Esperado",
                                  amount: expectedTotal,
                                  liters: expectedLiters,
                                  compact: compact,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GarzaTotalsColumn extends StatelessWidget {
  final String title;
  final double amount;
  final double liters;
  final bool compact;

  const _GarzaTotalsColumn({
    required this.title,
    required this.amount,
    required this.liters,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: compact ? 0 : 2,
      children: [
        _StatisticText(
          text: title,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: compact ? 1 : null,
          ),
          textAlign: TextAlign.center,
        ),
        _StatisticText(
          text: "\$${amount.toStringAsFixed(2)}",
          style: textTheme.bodySmall?.copyWith(height: compact ? 1 : null),
          textAlign: TextAlign.center,
        ),
        _StatisticText(
          text: "L: ${liters.toStringAsFixed(2)}",
          style: textTheme.bodySmall?.copyWith(height: compact ? 1 : null),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatisticText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const _StatisticText({required this.text, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      child: AutoSizeText(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: 1,
        minFontSize: 8,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
