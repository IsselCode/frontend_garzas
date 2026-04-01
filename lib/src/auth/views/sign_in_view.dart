import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class SignInView extends StatelessWidget {
  SignInView({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Inicio de sesi\u00f3n", style: textTheme.titleLarge),
                    Form(
                      key: formKey,
                      child: Flex(
                        direction: Axis.vertical,
                        spacing: 20,
                        children: [
                          IsselTextFormField(
                            controller: email,
                            hintText: "Usuario",
                            height: 60,
                            inputFormatters: [RegexService.usernameFormatter],
                            validator: (value) => RegexService.usernameValidator(value),
                          ),
                          IsselTextFormField(
                            controller: password,
                            hintText: "Contrase\u00f1a",
                            obscureText: true,
                            validator: (value) {
                              if ((value ?? "").isEmpty) {
                                return 'La contrase\u00f1a es obligatoria';
                              }
                              return null;
                            },
                          ),
                          IsselButton(
                            text: "Ingresar",
                            onTap: () => signIn(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primaryToSecondary
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 30,
                children: [
                  Text(
                    "\u00a1Hola, Bienvenido!",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "Accede con tus credenciales asignadas para ingresar al sistema.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void signIn(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    context.loaderOverlay.show();

    AuthController authController = context.read();
    CtrlResponse response = await authController.signIn(
      email.text.trim(),
      password.text,
    );

    if (!context.mounted) {
      return;
    }

    context.loaderOverlay.hide();

    if (!response.success) {
      ToastService toastService = locator();
      toastService.error(
        response.message ?? "No fue posible iniciar sesi\u00f3n",
      );
      return;
    }

    await authController.navigateToHome();
  }
}
