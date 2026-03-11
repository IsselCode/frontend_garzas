import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class SignInView extends StatelessWidget {
  SignInView({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          //* Left
          Expanded(
            child: Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Inicio de sesión", style: textTheme.titleLarge,),
                    //* Form
                    Form(
                      key: formKey,
                      child: Flex(
                        direction: Axis.vertical,
                        spacing: 20,
                        children: [
                          IsselTextFormField(
                            hintText: "Usuario",
                            height: 60,
                            inputFormatters: [RegexService.usernameFormatter],
                            validator: (value) => RegexService.usernameValidator(value),
                          ),
                          IsselTextFormField(
                            hintText: "Contraseña",
                            obscureText: true,
                            validator: (value) {
                              if ((value ?? "").isEmpty) return 'La contraseña es obligatoria';
                              return null;
                            },
                          ),
                          IsselButton(
                            text: "Ingresar",
                            onTap: () => signIn(context),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ),

          //* Right
          Expanded(
            child: ColoredBox(
              color: colorScheme.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 30,
                children: [
                  Text("¡Hola, Bienvenido!", style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),),
                  SizedBox(
                    width: 400,
                    child: Text(
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
                      "Accede con tus credenciales asignadas para ingresar al sistema."
                    )
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  // Methods
  void signIn(BuildContext context) async {

    if(!formKey.currentState!.validate()){
      return ;
    }

    print("ingresando");

  }

}
