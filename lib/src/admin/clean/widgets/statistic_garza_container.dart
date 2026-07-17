import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class StatisticGarzaContainer extends StatelessWidget {
  final String asset;
  final String title;
  final double total;
  final double liters;

  const StatisticGarzaContainer({
    super.key,
    required this.asset,
    required this.title,
    required this.total,
    required this.liters,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 150.0;
        final compact = width < 280 || height < 220;
        final imageSize = compact
            ? (height * 0.26).clamp(30.0, 40.0)
            : (height * 0.36).clamp(58.0, 80.0);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 6 : 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: compact
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Image.asset(asset, fit: BoxFit.contain, width: 50),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 1,
                          children: [
                            _StatisticText(
                              text: title,
                              style: textTheme.titleSmall,
                            ),
                            _StatisticText(
                              text: "\$${total.toStringAsFixed(2)}",
                              style: textTheme.bodyMedium,
                            ),
                            _StatisticText(
                              text: "L: ${liters.toStringAsFixed(2)}",
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(asset, height: imageSize, width: imageSize),
                    const SizedBox(height: 10),
                    _StatisticText(
                      text: title,
                      style: textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    _StatisticText(
                      text: "\$${total.toStringAsFixed(2)}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _StatisticText(
                      text: "Litros: ${liters.toStringAsFixed(2)}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        );
      },
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
        minFontSize: 9,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
