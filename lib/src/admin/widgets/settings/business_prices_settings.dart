import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class BusinessPricesSettings extends StatelessWidget {
  const BusinessPricesSettings({
    super.key,
    required this.potableLiter,
    required this.potableGallon,
    required this.pozoLiter,
    required this.pozoGallon,
    required this.onPotableLiterChanged,
    required this.onPotableGallonChanged,
    required this.onPozoLiterChanged,
    required this.onPozoGallonChanged,
  });

  final double potableLiter, potableGallon, pozoLiter, pozoGallon;
  final ValueChanged<double> onPotableLiterChanged,
      onPotableGallonChanged,
      onPozoLiterChanged,
      onPozoGallonChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodyMedium;
    Widget price(String title, double value, ValueChanged<double> onChanged) =>
        IsselStepperField(
          title: title,
          height: 44,
          initValue: value,
          minValue: 0,
          maxValue: 10000,
          onChanged: onChanged,
          backColor: colors.surfaceContainer,
          counterColor: colors.surface,
        );
    final potable = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Agua potable', style: labelStyle),
        const SizedBox(height: 8),
        price('Litro', potableLiter, onPotableLiterChanged),
        const SizedBox(height: 8),
        price('Galón', potableGallon, onPotableGallonChanged),
      ],
    );
    final pozo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Agua de pozo', style: labelStyle),
        const SizedBox(height: 8),
        price('Litro', pozoLiter, onPozoLiterChanged),
        const SizedBox(height: 8),
        price('Galón', pozoGallon, onPozoGallonChanged),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (constraints.maxWidth >= 680)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: potable),
                  const SizedBox(width: 16),
                  Expanded(child: pozo),
                ],
              ),
            )
          else ...[
            potable,
            const SizedBox(height: 16),
            pozo,
          ],
        ],
      ),
    );
  }
}
