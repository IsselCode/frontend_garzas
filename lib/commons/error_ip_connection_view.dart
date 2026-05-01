import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class ErrorIpConnectionView extends StatefulWidget {
  const ErrorIpConnectionView({super.key});

  @override
  State<ErrorIpConnectionView> createState() => _ErrorIpConnectionViewState();
}

class _ErrorIpConnectionViewState extends State<ErrorIpConnectionView> {
  final TextEditingController serverCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    serverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primaryToSecondary,
              ),
              child: Center(
                child: SizedBox(
                  width: 420,
                  child: Text(
                    "Falló la detección automática del servidor. Intenta agregando la IP y puerto manualmente.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 340,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 24,
                    children: [
                      Text("Conexión manual", style: textTheme.titleLarge),
                      IsselTextFormField(
                        controller: serverCtrl,
                        hintText: "IP y puerto",
                        prefixIcon: Icons.dns_outlined,
                        validator: _serverValidator,
                      ),
                      IsselButton(text: "Continuar", onTap: _continue),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _serverValidator(String? value) {
    final endpoint = _parseEndpoint(value);

    if (endpoint == null) {
      return "Ingresa una IP y puerto válidos";
    }

    return null;
  }

  Future<void> _continue() async {
    if (!formKey.currentState!.validate()) return;

    final endpoint = _parseEndpoint(serverCtrl.text);
    if (endpoint == null) return;

    context.loaderOverlay.show();

    final apiClient = locator<ApiClient>();
    final toastService = locator<ToastService>();
    final isAvailable = await apiClient.configureManualBackend(
      host: endpoint.host,
      port: endpoint.port,
    );

    if (!mounted) return;

    if (!isAvailable) {
      context.loaderOverlay.hide();
      toastService.error("No fue posible conectar con el servidor indicado");
      return;
    }

    context.loaderOverlay.hide();
    await context.read<AuthController>().restoreSession();
  }

  _ManualEndpoint? _parseEndpoint(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final uriText = text.contains('://') ? text : 'http://$text';
    final uri = Uri.tryParse(uriText);

    if (uri == null || uri.host.isEmpty || !uri.hasPort) {
      return null;
    }

    if (uri.port <= 0 || uri.port > 65535) {
      return null;
    }

    return _ManualEndpoint(host: uri.host, port: uri.port);
  }
}

class _ManualEndpoint {
  final String host;
  final int port;

  const _ManualEndpoint({required this.host, required this.port});
}
