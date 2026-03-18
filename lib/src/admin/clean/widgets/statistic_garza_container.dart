import 'package:flutter/material.dart';

import '../../../../core/app/consts.dart';

class StatisticGarzaContainer extends StatelessWidget {
  final int number;
  final double litersSold;
  final double gallonsSold;
  final double total;

  const StatisticGarzaContainer({
    super.key,
    required this.number,
    required this.litersSold,
    required this.gallonsSold,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            alignment: Alignment.topLeft,
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(AppAssets.waterTank, height: 48, width: 48),
                      Text("Garza #$number", style: textTheme.titleSmall),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vendido en litros: ${litersSold.toStringAsFixed(1)} L",
                      ),
                      Text(
                        "Vendido en galones: ${gallonsSold.toStringAsFixed(1)} gal",
                      ),
                    ],
                  ),
                  Text("Vendido: \$${total.toStringAsFixed(2)}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
