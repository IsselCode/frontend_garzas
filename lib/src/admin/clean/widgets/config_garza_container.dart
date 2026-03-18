import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

enum GarzaType {
  manual(dp: "Manual"),
  valvula(dp: "Valvula");

  final String dp;
  const GarzaType({required this.dp});

  static GarzaType fromString(String type) {
    switch (type) {
      case "manual":
        return GarzaType.manual;
      case "valvula":
        return GarzaType.valvula;
      default:
        throw AppException(message: "Tipo de garza inexistente");
    }
  }

}

enum WaterType {
  potable(dp: "Potable"),
  pozo(dp: "Pozo");

  final String dp;
  const WaterType({required this.dp});

  static WaterType fromString(String type) {
    switch (type) {
      case "Potable":
        return WaterType.potable;
      case "Pozo":
        return WaterType.pozo;
      default:
        throw AppException(message: "Tipo de agua inexistente");
    }
  }

}

enum UnitOfMeasurement {
  gallons(dp: "Galones", abbr: "gal"),
  liters(dp: "Litros", abbr: "L");

  final String dp;
  final String abbr;
  const UnitOfMeasurement({required this.dp, required this.abbr});

  static UnitOfMeasurement fromString(String type) {
    switch (type) {
      case "Potable":
        return UnitOfMeasurement.gallons;
      case "Pozo":
        return UnitOfMeasurement.liters;
      default:
        throw AppException(message: "Tipo de medida inexistente");
    }
  }

}

class ConfigGarzaContainer extends StatelessWidget {

  final GarzaType garzaType;
  final Function(GarzaType newValue) onGarzaTypeChanged;
  final Function(WaterType newValue) onWaterTypeChanged;
  final Function(UnitOfMeasurement newValue) onUnitOfMeasurement;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;
  final String title;

  ConfigGarzaContainer({
    super.key,
    required this.garzaType,
    required this.onGarzaTypeChanged,
    required this.onWaterTypeChanged,
    required this.onUnitOfMeasurement,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // THEME
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium,),
            Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text("Tipo de garza"),
                Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: IsselPill(
                        text: "Manual",
                        textColor: garzaType == GarzaType.manual ? colorScheme.onPrimary : colorScheme.onSurface,
                        color: garzaType == GarzaType.manual ? colorScheme.primary : colorScheme.surfaceContainer,
                        onTap: () => onGarzaTypeChanged(GarzaType.manual),
                      ),
                    ),
                    Expanded(
                      child: IsselPill(
                        text: "Válvula",
                        textColor: garzaType == GarzaType.valvula ? colorScheme.onPrimary : colorScheme.onSurface,
                        color: garzaType == GarzaType.valvula ? colorScheme.primary : colorScheme.surfaceContainer,
                        onTap: () => onGarzaTypeChanged(GarzaType.valvula),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                Text("Tipo de agua"),
                Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: IsselPill(
                        text: "Potable",
                        textColor: waterType == WaterType.potable ? colorScheme.onPrimary : colorScheme.onSurface,
                        color: waterType == WaterType.potable ? colorScheme.primary : colorScheme.surfaceContainer,
                        onTap: () => onWaterTypeChanged(WaterType.potable),
                      ),
                    ),
                    Expanded(
                      child: IsselPill(
                        text: "Pozo",
                        textColor: waterType == WaterType.pozo ? colorScheme.onPrimary : colorScheme.onSurface,
                        color: waterType == WaterType.pozo ? colorScheme.primary : colorScheme.surfaceContainer,
                        onTap: () => onWaterTypeChanged(WaterType.pozo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                Text("Unidad de medida"),
                Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: IsselPill(
                        text: "Galones",
                        textColor: unitOfMeasurement == UnitOfMeasurement.gallons ? colorScheme.onPrimary : colorScheme.onSurface,
                        color: unitOfMeasurement == UnitOfMeasurement.gallons ? colorScheme.primary : colorScheme.surfaceContainer,
                        onTap: () => onUnitOfMeasurement(UnitOfMeasurement.gallons),
                      ),
                    ),
                    Expanded(
                      child: IsselPill(
                        text: "Litros",
                        textColor: unitOfMeasurement == UnitOfMeasurement.liters ? colorScheme.onPrimary : colorScheme.onSurface,
                        color: unitOfMeasurement == UnitOfMeasurement.liters ? colorScheme.primary : colorScheme.surfaceContainer,
                        onTap: () => onUnitOfMeasurement(UnitOfMeasurement.liters),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
