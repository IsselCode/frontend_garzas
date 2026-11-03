import 'package:flutter/material.dart';

/// Logs scroll independently from the prices and PLC panel.
class BusinessGeneralSettings extends StatelessWidget {
  const BusinessGeneralSettings({
    super.key,
    required this.logs,
    required this.prices,
    required this.plc,
  });

  final Widget logs;
  final Widget prices;
  final Widget plc;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final heading = Theme.of(context).textTheme.titleMedium;
    Widget panel(Widget child) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
    final logsPanel = panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Logs', style: heading),
          const SizedBox(height: 14),
          Expanded(child: logs),
        ],
      ),
    );
    final operationalSettings = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Precios', style: heading),
        const SizedBox(height: 14),
        prices,
        const SizedBox(height: 16),
        Text('PLC', style: heading),
        const SizedBox(height: 14),
        plc,
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return SingleChildScrollView(
            primary: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 360, child: logsPanel),
                const SizedBox(height: 20),
                panel(operationalSettings),
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: logsPanel),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: panel(
                SingleChildScrollView(
                  primary: false,
                  child: operationalSettings,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
