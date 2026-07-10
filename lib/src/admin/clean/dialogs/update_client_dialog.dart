import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import '../../../../core/app/consts.dart';
import '../../../../inject_container.dart';

class UpdateClientDialog extends StatefulWidget {
  final ClientEntity clientEntity;

  const UpdateClientDialog({super.key, required this.clientEntity});

  @override
  State<UpdateClientDialog> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<UpdateClientDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController commercialName = TextEditingController();
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;
  double potableLiterPricing = 1;
  double potableGallonPricing = 1;
  double pozoLiterPricing = 1;
  double pozoGallonPricing = 1;
  double creditLimit = 1;
  double creditUsed = 0;
  bool creditEnabled = false;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    commercialName.text = widget.clientEntity.commercialName;
    potableGallonPricing = widget.clientEntity.potableGalPricing;
    potableLiterPricing = widget.clientEntity.potableLiterPricing;
    pozoGallonPricing = widget.clientEntity.pozoGalPricing;
    pozoLiterPricing = widget.clientEntity.pozoLiterPricing;
    creditLimit = widget.clientEntity.creditLimit;
    creditEnabled = widget.clientEntity.creditEnabled;
    creditUsed = widget.clientEntity.creditUsed;
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
            IsselButton(text: "Actualizar", onTap: updateClient),
          ],
        ),
      ),
    );
  }

  void updateClient() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ClientsController clientsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await clientsController.updateClientById(
      widget.clientEntity.id,
      commercialName.text,
      potableLiterPricing,
      potableGallonPricing,
      pozoLiterPricing,
      pozoGallonPricing,
      creditLimit,
      creditEnabled,
    );
    if (!mounted) return;
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    NavigationService navigationService = locator();
    if (response.success) {
      toastService.success("Cliente actualizado");
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
