import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
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
  TextEditingController commercialName = TextEditingController();
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;
  double potableLiterPricing = 0;
  double potableGallonPricing = 0;
  double pozoLiterPricing = 0;
  double pozoGallonPricing = 0;
  double creditLimit = 1;
  bool creditEnabled = false;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 450,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            //* Imagen
            IsselAssetContainer(asset: AppAssets.logo, height: 84, width: 84),
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
                    controller: commercialName,
                    hintText: "Nombre comercial",
                    prefixIcon: Icons.storefront_outlined,
                    fillColor: theme.scaffoldBackgroundColor,
                    validator: (value) {
                      final text = value?.trim() ?? "";

                      if (text.isEmpty) return "Campo requerido";
                      if (text.length < 3) {
                        return "El nombre comercial es demasiado corto";
                      }
                      if (text.length > 45) {
                        return "El nombre comercial es demasiado largo";
                      }
                      if (!RegExp(r'^[A-Za-z0-9 .ñÑ]+$').hasMatch(text)) {
                        return "Solo letras sin acento, números, espacios, puntos y ñ";
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            IsselToggleField(
              title: "Credito",
              value: creditEnabled,
              onChanged: (value) => setState(() {creditEnabled = value;}),
              backColor: colorScheme.surfaceContainer,
              valueBackColor: colorScheme.surface,
            ),
            IsselStepperField(
              height: 50,
              title: "Limite de credito",
              onChanged: (value) => creditLimit = value,
              maxValue: 1000000,
              minValue: 1,
              initValue: creditLimit,
              backColor: colorScheme.surfaceContainer,
              counterColor: colorScheme.surface,
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
                        title: "Litro",
                        onChanged: (value) => potableLiterPricing = value,
                        maxValue: 10000,
                        minValue: 0,
                        initValue: potableLiterPricing,
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
                        title: "Litro",
                        onChanged: (value) => pozoLiterPricing = value,
                        maxValue: 10000,
                        minValue: 0,
                        initValue: pozoLiterPricing,
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
            IsselButton(text: "Crear", onTap: createClient),
          ],
        ),
      ),
    );
  }

  void createClient() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ClientsController clientsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await clientsController.createClient(
      commercialName.text,
      potableLiterPricing,
      potableGallonPricing,
      pozoLiterPricing,
      pozoGallonPricing,
      creditLimit,
      creditEnabled
    );
    if (!mounted) {
      return;
    }
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    NavigationService navigationService = locator();
    if (response.success) {
      toastService.success("Cliente creado");
      navigationService.goBack();
    } else {
      toastService.error(response.message!);
    }
  }

  void onChangeWaterType(TabSwitcherAlignStates newState) {
    state = newState;
    if (state == TabSwitcherAlignStates.left) {
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linearToEaseOut,
      );
    } else {
      pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linearToEaseOut,
      );
    }
    setState(() {});
  }
}
