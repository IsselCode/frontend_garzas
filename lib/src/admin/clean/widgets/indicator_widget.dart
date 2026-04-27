import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {

  final double potableLiters;
  final double potableTotal;
  final double pozoLiters;
  final double pozoTotal;

  const Indicator({
    super.key,
    required this.potableLiters,
    required this.potableTotal,
    required this.pozoLiters,
    required this.pozoTotal
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return Container(
      width: 400,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainer
      ),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              spacing: 10,
              children: [
                Text("Potable"),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Total: \$$potableTotal"),
                      Text("Litros: $potableLiters"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              spacing: 10,
              children: [
                Text("Pozo"),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Total: \$$pozoTotal"),
                      Text("Litros: $pozoLiters"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}