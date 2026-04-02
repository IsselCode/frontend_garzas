import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/finish_dispatch_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../inject_container.dart';

class SelectGarzaView extends StatefulWidget {
  const SelectGarzaView({super.key});

  @override
  State<SelectGarzaView> createState() => _SelectGarzaViewState();
}

class _SelectGarzaViewState extends State<SelectGarzaView> {

  late Future<CtrlResponse> _getAvailableGarzas;

  @override
  void initState() {
    super.initState();
    DispatchController dispatchController = context.read();
    _getAvailableGarzas = dispatchController.getAvailableGarzas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Controllers
    DispatchController dispatchController = context.watch();

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Garzas con Agua ${dispatchController.dispatchValidate!.waterType == WaterType.pozo ? "de" : ""} ${dispatchController.dispatchValidate!.waterType.dp}', style: textTheme.displayLarge),
                Text(
                  'Selecciona la garza',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20,),
                FutureBuilder(
                  future: _getAvailableGarzas,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return IsselShimmer(width: 600, height: 350);
                    }

                    if (!snapshot.data!.success) {
                      return Center(child: Text(snapshot.data!.message!),);
                    }

                    if (snapshot.data!.success && dispatchController.availableGarzas.isEmpty) {
                      return Center(child: Text("No hay garzas disponibles"),);
                    }

                    List<ConfigGarzaEntity> garzas = dispatchController.availableGarzas;

                    return ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: IsselCarousel(
                        onTap: (index) => selectGarza(garzas[index]),
                        height: 350,
                        itemCount: garzas.length,
                        selectedScale: 0.92,
                        unselectedScale: 0.92,
                        borderRadius: BorderRadius.circular(20),
                        itemBuilder: (context, index, isSelected) {
                          ConfigGarzaEntity garza = garzas[index];
                          return Ink(
                            width: 350,
                            color: colorScheme.surface,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AppAssets.waterTank, width: 128, height: 128),
                                const SizedBox(height: 20,),
                                Text(garza.title, style: textTheme.titleLarge,),
                                Text(garza.garzaType.dp, style: textTheme.bodyLarge,),
                              ],
                            ),
                          );
                        },
                      ),
                    );

                  },
                )
              ],
            ),
          ),
          Positioned(
              top: kWindowCaptionHeight + 10,
              left: 10,
              child: TextBackButton()
          ),
        ],
      ),
    );
  }

  void selectGarza(ConfigGarzaEntity garza) {
    DispatchController dispatchController = context.read();
    NavigationService navigationService = locator();
    dispatchController.selectedGarza = garza;
    navigationService.navigateTo(FinishDispatchView());
  }

}
