import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:window_manager/window_manager.dart';

class ConfigGarzasView extends StatefulWidget {
  ConfigGarzasView({super.key});

  @override
  State<ConfigGarzasView> createState() => _ConfigGarzasViewState();
}

class _ConfigGarzasViewState extends State<ConfigGarzasView> {

  // TODO: Crear un loader para implementar valores iniciales
  // TODO: Analizar creación de entidad para configuración de garzas

  GarzaType garzaType1 = GarzaType.manual;
  WaterType waterType1 = WaterType.potable;
  UnitOfMeasurement unitOfMeasurement1 = UnitOfMeasurement.gallons;

  GarzaType garzaType2 = GarzaType.manual;
  WaterType waterType2 = WaterType.potable;
  UnitOfMeasurement unitOfMeasurement2 = UnitOfMeasurement.gallons;

  GarzaType garzaType3 = GarzaType.manual;
  WaterType waterType3 = WaterType.potable;
  UnitOfMeasurement unitOfMeasurement3 = UnitOfMeasurement.gallons;

  GarzaType garzaType4 = GarzaType.manual;
  WaterType waterType4 = WaterType.potable;
  UnitOfMeasurement unitOfMeasurement4 = UnitOfMeasurement.gallons;

  @override
  Widget build(BuildContext context) {
    // theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: kWindowCaptionHeight, left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextBackButton(),
            const SizedBox(height: 10,),
            // Body
            Column(
              spacing: 20,
              children: [

                // 1,2,3,
                Row(
                  spacing: 20,
                  children: [
                    ConfigGarzaContainer(
                      title: "Garza 1",
                      garzaType: garzaType1,
                      waterType: waterType1,
                      unitOfMeasurement: unitOfMeasurement1,
                      onGarzaTypeChanged: (newValue) {
                        garzaType1 = newValue;
                        setState(() {});
                      },
                      onUnitOfMeasurement: (newValue) {
                        unitOfMeasurement1 = newValue;
                        setState(() {});
                      },
                      onWaterTypeChanged: (newValue) {
                        waterType1 = newValue;
                        setState(() {});
                      },
                    ),
                    ConfigGarzaContainer(
                      title: "Garza 2",
                      garzaType: garzaType2,
                      waterType: waterType2,
                      unitOfMeasurement: unitOfMeasurement2,
                      onGarzaTypeChanged: (newValue) {
                        garzaType2 = newValue;
                        setState(() {});
                      },
                      onUnitOfMeasurement: (newValue) {
                        unitOfMeasurement2 = newValue;
                        setState(() {});
                      },
                      onWaterTypeChanged: (newValue) {
                        waterType2 = newValue;
                        setState(() {});
                      },
                    ),
                    ConfigGarzaContainer(
                      title: "Garza 3",
                      garzaType: garzaType3,
                      waterType: waterType3,
                      unitOfMeasurement: unitOfMeasurement3,
                      onGarzaTypeChanged: (newValue) {
                        garzaType3 = newValue;
                        setState(() {});
                      },
                      onUnitOfMeasurement: (newValue) {
                        unitOfMeasurement3 = newValue;
                        setState(() {});
                      },
                      onWaterTypeChanged: (newValue) {
                        waterType3 = newValue;
                        setState(() {});
                      },
                    ),
                  ],
                ),

                // 4
                Row(
                  spacing: 20,
                  children: [
                    ConfigGarzaContainer(
                      title: "Garza 4",
                      garzaType: garzaType4,
                      waterType: waterType4,
                      unitOfMeasurement: unitOfMeasurement4,
                      onGarzaTypeChanged: (newValue) {
                        garzaType4 = newValue;
                        setState(() {});
                      },
                      onUnitOfMeasurement: (newValue) {
                        unitOfMeasurement4 = newValue;
                        setState(() {});
                      },
                      onWaterTypeChanged: (newValue) {
                        waterType4 = newValue;
                        setState(() {});
                      },
                    ),
                    Spacer(),
                    Spacer()
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
