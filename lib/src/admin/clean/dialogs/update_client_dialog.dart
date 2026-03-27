import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import '../../../../core/app/consts.dart';
import '../../../../inject_container.dart';


class UpdateClientDialog extends StatefulWidget {

  final ClientEntity clientEntity;

  const UpdateClientDialog({
    super.key,
    required this.clientEntity,
  });

  @override
  State<UpdateClientDialog> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<UpdateClientDialog> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;
  double potableLiterPricing = 1;
  double potableGallonPricing = 1;
  double pozoLiterPricing = 1;
  double pozoGallonPricing = 1;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    name.text = widget.clientEntity.name;
    phone.text = widget.clientEntity.phone;
    potableGallonPricing = widget.clientEntity.potableGalPricing;
    potableLiterPricing = widget.clientEntity.potableLiterPricing;
    pozoGallonPricing = widget.clientEntity.pozoGalPricing;
    pozoLiterPricing = widget.clientEntity.pozoLiterPricing;
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
            IsselButton(
              text: "Actualizar",
              onTap: updateClient,
            )
          ],
        ),
      ),
    );
  }

  void updateClient() async {

    if (!formKey.currentState!.validate()){
      return;
    }

    ClientsController clientsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await clientsController.updateClientByPhone(widget.clientEntity.phone, name.text, phone.text, potableLiterPricing, potableGallonPricing, pozoLiterPricing, pozoGallonPricing);
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    NavigationService navigationService = locator();
    if (response.success) {
      toastService.success("Usuario actualizado");
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
