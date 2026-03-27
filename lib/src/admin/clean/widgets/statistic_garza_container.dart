import 'package:flutter/material.dart';

import '../../../../core/app/consts.dart';

class StatisticGarzaContainer extends StatelessWidget {
  final String asset;
  final String title;
  final double total;

  const StatisticGarzaContainer({
    super.key,
    required this.asset,
    required this.title,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Image.asset(asset, height: 96, width: 96),
          Text(title, style: textTheme.titleSmall),
          Text("\$${total.toStringAsFixed(2)}"),
        ],
      ),
    );
  }
}
