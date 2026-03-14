import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../../../../commons/ctrl_response.dart';
import '../../../../core/app/consts.dart';
import '../../../../core/services/toast_service.dart';
import '../../../../inject_container.dart';
import '../../../auth/controllers/main.dart';
import '../../clean/enums/enums.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  AppRole selectedRole = AppRole.admin;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 30,
          children: [
            //* Inputs
            Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                spacing: 10,
                children: [
                  IsselTextFormField(
                    controller: username,
                    hintText: "Nombre de usuario",
                    prefixIcon: Icons.person_outline,
                    fillColor: theme.scaffoldBackgroundColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Campo requerido";
                    },
                  ),
                  IsselTextFormField(
                    controller: password,
                    hintText: "Contraseña",
                    prefixIcon: Icons.password_outlined,
                    fillColor: theme.scaffoldBackgroundColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Campo requerido";
                    },
                  )
                ],
              ),
            ),
            //* Roles
            Row(
              spacing: 20,
              children: [
                IsselRadioCard(
                  value: AppRole.admin,
                  groupValue: selectedRole,
                  label: "Administrador",
                  asset: AppAssets.admin,
                  surfaceColor: theme.scaffoldBackgroundColor,
                  onChanged: (v) => setState(() => selectedRole = v)
                ),
                IsselRadioCard(
                  value: AppRole.dispatcher,
                  groupValue: selectedRole,
                  label: "Despachador",
                  asset: AppAssets.waterTank,
                  surfaceColor: theme.scaffoldBackgroundColor,
                  onChanged: (v) => setState(() => selectedRole = v)
                ),
                IsselRadioCard(
                  value: AppRole.seller,
                  groupValue: selectedRole,
                  label: "Vendedor",
                  asset: AppAssets.cashRegister,
                  surfaceColor: theme.scaffoldBackgroundColor,
                  onChanged: (v) => setState(() => selectedRole = v)
                )
              ],
            ),
            //* Botón de registrar
            IsselButton(
              text: "Registrar",
              onTap: () => cta(),
            )
          ],
        ),
      ),
    );
  }

  void cta() async {

    if (!formKey.currentState!.validate()){
      return ;
    }


    context.loaderOverlay.show();
    AuthController authController = context.read();
    CtrlResponse response = await authController.insertNormalUser(username.text, password.text, selectedRole);
    context.loaderOverlay.hide();

    ToastService toastService = locator();

    if (response.success) {
      toastService.success(response.message!);
      // Reiniciamos controladores
      username.text = "";
      password.text = "";
      selectedRole = AppRole.admin;
      setState(() {});
    } else {
      toastService.error(response.message!);
    }

  }

}
