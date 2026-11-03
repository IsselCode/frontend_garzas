import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:frontend_garzas/src/auth/widgets/sign_in_form_card.dart';
import 'package:frontend_garzas/src/auth/widgets/sign_in_welcome.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // PPG's type scale is scoped to this view; Garzas keeps its app-wide theme.
    final loginTheme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        headlineSmall: theme.textTheme.headlineSmall?.copyWith(fontSize: 28),
      ),
    );

    return Theme(
      data: loginTheme,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.secondary],
              stops: const [0.10, 0.85],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.60,
                    child: Image.asset(
                      'assets/images/login_pattern.png',
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape =
                        constraints.maxWidth > constraints.maxHeight;
                    final isWide = isLandscape || constraints.maxWidth >= 860;
                    final isCompactLandscape =
                        isLandscape && constraints.maxWidth < 860;
                    final verticalPadding = isCompactLandscape
                        ? 16.0
                        : isWide
                        ? 40.0
                        : 24.0;
                    final contentHeight =
                        (constraints.maxHeight - verticalPadding * 2).clamp(
                          0.0,
                          constraints.maxHeight,
                        );
                    final card = SignInFormCard(
                      formKey: formKey,
                      userController: email,
                      passwordController: password,
                      onLogin: () => signIn(context),
                      maxHeight: isWide
                          ? (constraints.maxHeight - 80).clamp(0.0, 420.0)
                          : null,
                    );

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompactLandscape
                                ? 16
                                : isWide
                                ? 40
                                : 24,
                            vertical: verticalPadding,
                          ),
                          child: isWide
                              ? SizedBox(
                                  height: contentHeight,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: isCompactLandscape
                                                  ? 260
                                                  : 360,
                                            ),
                                            child: const SignInWelcome(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isCompactLandscape ? 24 : 100,
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: SizedBox(
                                            width: isCompactLandscape
                                                ? 320
                                                : 400,
                                            child: card,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SignInWelcome(compact: true),
                                      const SizedBox(height: 28),
                                      card,
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
