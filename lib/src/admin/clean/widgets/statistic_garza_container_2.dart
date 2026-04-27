import 'package:flutter/material.dart';

import '../../../../core/app/consts.dart';

class StatisticGarzaContainer_2 extends StatelessWidget {
  final String asset;
  final String title;
  final double total;
  final double liters;

  const StatisticGarzaContainer_2({
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

    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Image.asset(asset, height: 80, width: 80),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10,),
              Text(title, style: textTheme.titleSmall),
              Text("\$${total.toStringAsFixed(2)}"),
              const SizedBox(height: 10,),
              Text("Litros: ${liters.toStringAsFixed(2)}"),
            ],
          )
        ],
      ),
    );
  }
}
