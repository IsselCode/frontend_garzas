import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/controllers/config_garzas_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class ConfigGarzasView extends StatefulWidget {
  const ConfigGarzasView({super.key});

  @override
  State<ConfigGarzasView> createState() => _ConfigGarzasViewState();
}

class _ConfigGarzasViewState extends State<ConfigGarzasView> {
  late Future<CtrlResponse> _loadConfigsGarzas;

  @override
  void initState() {
    super.initState();
    ConfigGarzasController configGarzasController = context.read();
    _loadConfigsGarzas = configGarzasController.loadConfigGarzas();
  }

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    ConfigGarzasController configGarzasController = context.watch();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: kWindowCaptionHeight + 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextBackButton(),
            const SizedBox(height: 10),
            // Body
            Expanded(
              child: FutureBuilder(
                future: _loadConfigsGarzas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LayoutBuilder(
                      builder: (context, gridConstraints) {
                        const columns = 3;
                        const rows = 2;
                        const spacing = 16.0;

                        final itemWidth = (gridConstraints.maxWidth - (spacing * (columns - 1))) / columns;
                        final itemHeight = (gridConstraints.maxHeight - (spacing * (rows - 1))) / rows;

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: columns * rows,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: itemWidth / itemHeight,
                          ),
                          itemBuilder: (context, index) {
                            return IsselShimmer(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        );
                      },
                    );
                  }

                  if (configGarzasController.configGarzas.isEmpty) {
                    return Center(child: Text("No hay garzas disponibles"));
                  }

                  List<ConfigGarzaEntity> configs = configGarzasController.configGarzas;

                  ConfigGarzaEntity config1 = configs[0];
                  ConfigGarzaEntity config2 = configs[1];
                  ConfigGarzaEntity config3 = configs[2];
                  ConfigGarzaEntity config4 = configs[3];

                  return SingleChildScrollView(
                    child: Column(
                      spacing: 20,
                      children: [
                        // 1,2,3,
                        Row(
                          spacing: 20,
                          children: [
                            ConfigGarzaContainer(
                              title: "Garza 1",
                              garzaType: config1.garzaType,
                              waterType: config1.waterType,
                              unitOfMeasurement: config1.unitOfMeasurement,
                              onGarzaTypeChanged: (newValue) => configGarzasController.updateGarza(config1.number, garzaType: newValue),
                              onWaterTypeChanged: (newValue) => configGarzasController.updateGarza(config1.number, waterType: newValue),
                              onUnitOfMeasurement: (newValue) => configGarzasController.updateGarza(config1.number, unitOfMeasurement: newValue),
                            ),
                            ConfigGarzaContainer(
                              title: "Garza 2",
                              garzaType: config2.garzaType,
                              waterType: config2.waterType,
                              unitOfMeasurement: config2.unitOfMeasurement,
                              onGarzaTypeChanged: (newValue) => configGarzasController.updateGarza(config2.number, garzaType: newValue),
                              onWaterTypeChanged: (newValue) => configGarzasController.updateGarza(config2.number, waterType: newValue),
                              onUnitOfMeasurement: (newValue) => configGarzasController.updateGarza(config2.number, unitOfMeasurement: newValue),
                            ),
                            ConfigGarzaContainer(
                              title: "Garza 3",
                              garzaType: config3.garzaType,
                              waterType: config3.waterType,
                              unitOfMeasurement: config3.unitOfMeasurement,
                              onGarzaTypeChanged: (newValue) => configGarzasController.updateGarza(config3.number, garzaType: newValue),
                              onWaterTypeChanged: (newValue) => configGarzasController.updateGarza(config3.number, waterType: newValue),
                              onUnitOfMeasurement: (newValue) => configGarzasController.updateGarza(config3.number, unitOfMeasurement: newValue),
                            ),
                          ],
                        ),
                        // 4
                        Row(
                          spacing: 20,
                          children: [
                            ConfigGarzaContainer(
                              title: "Garza 4",
                              garzaType: config4.garzaType,
                              waterType: config4.waterType,
                              unitOfMeasurement: config4.unitOfMeasurement,
                              onGarzaTypeChanged: (newValue) => configGarzasController.updateGarza(config4.number, garzaType: newValue),
                              onWaterTypeChanged: (newValue) => configGarzasController.updateGarza(config4.number, waterType: newValue),
                              onUnitOfMeasurement: (newValue) => configGarzasController.updateGarza(config4.number, unitOfMeasurement: newValue),
                            ),
                            Spacer(),
                            Spacer(),
                          ],
                        )
                      ]
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}
