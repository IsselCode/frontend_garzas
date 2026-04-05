import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import '../../../../core/app/consts.dart';
import '../../../../inject_container.dart';


class CreateClientDialog extends StatefulWidget {
  const CreateClientDialog({super.key});

  @override
  State<CreateClientDialog> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateClientDialog> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;
  double potableM3Pricing = 0;
  double potableGallonPricing = 0;
  double pozoM3Pricing = 0;
  double pozoGallonPricing = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 450,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            //* Imagen
            IsselAssetContainer(
              asset: AppAssets.logo,
              height: 84,
              width: 84,
            ),
            //* Separación
            const SizedBox(),
            //* Inputs
            Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                spacing: 10,
                children: [
                  IsselTextFormField(
                    controller: name,
                    hintText: "Nombre",
                    prefixIcon: Icons.person_outline,
                    fillColor: theme.scaffoldBackgroundColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Campo requerido";
                      if (value.length < 3) return "El nombre es demasiado corto";
                      if (value.length > 45) return "El nombre es demasiado largo";
                    },
                  ),
                  IsselTextFormField(
                    controller: phone,
                    hintText: "Teléfono",
                    prefixIcon: Icons.phone_outlined,
                    inputFormatters: [RegexService.phoneFormatter],
                    fillColor: theme.scaffoldBackgroundColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Campo requerido";
                      if (value.length < 7) return "El teléfono es demasiado corto";
                      if (value.length > 12) return "El teléfono es demasiado largo";
                    },
                  ),
                ],
              ),
            ),
            //* Prices
            IsselTabSwitcher(
              state: state,
              leftText: "Potable",
              rightText: "Pozo",
              onChanged: onChangeWaterType,
              color: colorScheme.surfaceContainer,
            ),
            SizedBox(
              height: 110,
              child: PageView(
                controller: pageController,
                children: [
                  Column(
                    spacing: 10,
                    children: [
                      IsselStepperField(
                        height: 50,
                        title: "M3",
                        onChanged: (value) => potableM3Pricing = value,
                        maxValue: 10000,
                        minValue: 0,
                        initValue: potableM3Pricing,
                        backColor: colorScheme.surfaceContainer,
                        counterColor: colorScheme.surface,
                      ),
                      IsselStepperField(
                        height: 50,
                        title: "Galón",
                        onChanged: (value) => potableGallonPricing = value,
                        maxValue: 10000,
                        minValue: 0,
                        initValue: potableGallonPricing,
                        backColor: colorScheme.surfaceContainer,
                        counterColor: colorScheme.surface,
                      ),
                    ],
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      IsselStepperField(
                        height: 50,
                        title: "M3",
                        onChanged: (value) => pozoM3Pricing = value,
                        maxValue: 10000,
                        minValue: 0,
                        initValue: pozoM3Pricing,
                        backColor: colorScheme.surfaceContainer,
                        counterColor: colorScheme.surface,
                      ),
                      IsselStepperField(
                        height: 50,
                        title: "Galón",
                        onChanged: (value) => pozoGallonPricing = value,
                        maxValue: 10000,
                        minValue: 0,
                        initValue: pozoGallonPricing,
                        backColor: colorScheme.surfaceContainer,
                        counterColor: colorScheme.surface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //* Botón de registrar
            IsselButton(
              text: "Crear",
              onTap: createClient,
            )
          ],
        ),
      ),
    );
  }

  void createClient() async {

    if (!formKey.currentState!.validate()){
      return;
    }

    ClientsController clientsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await clientsController.createClient(name.text, phone.text, potableM3Pricing, potableGallonPricing, pozoM3Pricing, pozoGallonPricing);
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    NavigationService navigationService = locator();
    if (response.success) {
      toastService.success("Usuario creado");
      navigationService.goBack();
    } else {
      toastService.error(response.message!);
    }

  }

  void onChangeWaterType(TabSwitcherAlignStates newState) {
    state = newState;
    if (state == TabSwitcherAlignStates.left) {
      pageController.animateToPage(0, duration: const Duration(milliseconds: 250), curve: Curves.linearToEaseOut);
    } else {
      pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.linearToEaseOut);
    }
    setState(() {});
  }

}
