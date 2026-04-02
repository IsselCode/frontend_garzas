import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/select_garza_view.dart';
import 'package:frontend_garzas/src/sales/views/start_order_view.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../inject_container.dart';

class HomeDispatchView extends StatefulWidget {
  const HomeDispatchView({super.key});

  @override
  State<HomeDispatchView> createState() => _HomeDispatchViewState();
}

class _HomeDispatchViewState extends State<HomeDispatchView> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _scannerController = TextEditingController();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestScannerFocus();
    });
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && mounted && !_isNavigating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestScannerFocus();
      });
    }
  }

  void _requestScannerFocus() {
    if (!mounted || _focusNode.hasFocus) return;
    _focusNode.requestFocus();
  }

  void _handleScannerSubmit(String value) async {

    final scannedCode = value.trim();

    if (scannedCode.isEmpty || _isNavigating) {
      _scannerController.clear();
      _requestScannerFocus();
      return;
    }


    context.loaderOverlay.show();
    DispatchController controller = context.read();
    CtrlResponse response = await controller.validateBarcode(_scannerController.text.trim());
    context.loaderOverlay.hide();

    if (response.success) {
      _isNavigating = true;
      _scannerController.clear();
      NavigationService navigationService = locator();
      await navigationService.navigateTo(SelectGarzaView());
    } else {
      _scannerController.clear();
      ToastService toastService = locator();
      toastService.error(response.message!);
    }

    if (!mounted) return;

    _isNavigating = false;
    _requestScannerFocus();

    // TODO: VERIFICAR SI SE PUEDE LIMPIAR EL CONTROLADOR DE DESPACHO
    print("SE NAVEGÓ HASTA ESTA VISTA DESPUES DEL TICKET");
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _requestScannerFocus,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Despacho', style: textTheme.displayLarge),
                    Text(
                      'Escanea un nuevo ticket para comenzar',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Lottie.asset(
                      AppLotties.scan,
                      width: 350,
                      height: 350,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _scannerController,
                  focusNode: _focusNode,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableInteractiveSelection: false,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  cursorColor: Colors.transparent,
                  onTapOutside: (_) => _requestScannerFocus(),
                  onSubmitted: _handleScannerSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
