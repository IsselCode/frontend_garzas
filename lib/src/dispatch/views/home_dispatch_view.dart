import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';
import 'package:frontend_garzas/src/dispatch/views/dispatch_session_view.dart';
import 'package:frontend_garzas/src/dispatch/views/select_garza_view.dart';
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
  bool _showRuntimePanel = false;

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

    final loaderOverlay = context.loaderOverlay;
    loaderOverlay.show();
    DispatchController controller = context.read();
    CtrlResponse response = await controller.validateBarcode(scannedCode);

    if (!mounted) return;

    loaderOverlay.hide();

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
    final dispatchController = context.watch<DispatchController>();

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
            if (_showRuntimePanel)
              Positioned(
                right: 20,
                bottom: 92,
                child: _GarzasRuntimePanel(
                  busyGarzas: dispatchController.busyGarzas,
                  alarmGarzas: dispatchController.alarmGarzas,
                  runtimeMessage: dispatchController.runtimeMessage,
                  onTap: _openRuntimeGarza,
                ),
              ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Badge(
                isLabelVisible:
                    dispatchController.hasRuntimeWarning ||
                    dispatchController.runtimePanelGarzasCount > 0,
                label: Text(
                  dispatchController.hasRuntimeWarning
                      ? '!'
                      : '${dispatchController.runtimePanelGarzasCount}',
                ),
                backgroundColor: colorScheme.error,
                child: FloatingActionButton(
                  backgroundColor: dispatchController.hasRuntimeWarning
                      ? colorScheme.error
                      : null,
                  foregroundColor: dispatchController.hasRuntimeWarning
                      ? colorScheme.onError
                      : null,
                  onPressed: () {
                    setState(() {
                      _showRuntimePanel = !_showRuntimePanel;
                    });
                    _requestScannerFocus();
                  },
                  child: Icon(
                    _showRuntimePanel
                        ? Icons.close
                        : dispatchController.hasRuntimeWarning
                        ? Icons.warning_amber_rounded
                        : Icons.local_drink_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRuntimeGarza(GarzaRuntimeEntity garza) {
    final dispatchController = context.read<DispatchController>();
    final navigationService = locator<NavigationService>();

    dispatchController.selectRuntimeGarza(garza);
    setState(() {
      _showRuntimePanel = false;
      _isNavigating = true;
    });
    navigationService.navigateTo(DispatchSessionView()).whenComplete(() {
      if (!mounted) return;
      _isNavigating = false;
      _requestScannerFocus();
    });
  }
}

class _GarzasRuntimePanel extends StatelessWidget {
  final List<GarzaRuntimeEntity> busyGarzas;
  final List<GarzaRuntimeEntity> alarmGarzas;
  final String? runtimeMessage;
  final void Function(GarzaRuntimeEntity garza) onTap;

  const _GarzasRuntimePanel({
    required this.busyGarzas,
    required this.alarmGarzas,
    required this.runtimeMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final warningMessage = runtimeMessage?.trim();
    final hasRuntimeWarning = warningMessage?.isNotEmpty ?? false;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        constraints: const BoxConstraints(maxHeight: 420),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text('Garzas en atención', style: textTheme.titleMedium),
            ),
            if (hasRuntimeWarning)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RuntimeWarning(message: warningMessage!),
              ),
            if (busyGarzas.isEmpty && alarmGarzas.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No hay garzas ocupadas ni con alarmas',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (busyGarzas.isNotEmpty)
                      _RuntimeSectionTitle(text: 'Ocupadas'),
                    ...busyGarzas.map(
                      (garza) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _GarzaRuntimeTile(
                          garza: garza,
                          statusText: 'Ocupada',
                          onTap: () => onTap(garza),
                        ),
                      ),
                    ),
                    if (alarmGarzas.isNotEmpty)
                      _RuntimeSectionTitle(text: 'Con alarma'),
                    ...alarmGarzas.map(
                      (garza) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _GarzaRuntimeTile(
                          garza: garza,
                          statusText: 'Liberada con alarma',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RuntimeWarning extends StatelessWidget {
  final String message;

  const _RuntimeWarning({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuntimeSectionTitle extends StatelessWidget {
  final String text;

  const _RuntimeSectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 6),
      child: Text(
        text,
        style: textTheme.labelLarge?.copyWith(color: colorScheme.outline),
      ),
    );
  }
}

class _GarzaRuntimeTile extends StatelessWidget {
  final GarzaRuntimeEntity garza;
  final String statusText;
  final VoidCallback? onTap;

  const _GarzaRuntimeTile({
    required this.garza,
    required this.statusText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = garza.currentState?.label ?? 'Sin estado';
    final alarms = garza.activeAlarmDisplayNames.join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: garza.hasActiveAlarms
                ? colorScheme.error
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Badge(
              isLabelVisible: garza.hasActiveAlarms,
              backgroundColor: colorScheme.error,
              child: Image.asset(AppAssets.waterTank, width: 42, height: 42),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Garza ${garza.garzaNumber}',
                    style: textTheme.titleSmall,
                  ),
                  Text(
                    statusText,
                    style: textTheme.bodySmall?.copyWith(
                      color: garza.hasActiveAlarms
                          ? colorScheme.error
                          : colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$state  ${garza.dispensedVolume.toStringAsFixed(1)} / ${garza.authorizedVolume.toStringAsFixed(1)} ${garza.unitOfMeasurement.abbr}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  if (alarms.isNotEmpty)
                    Text(
                      alarms,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (garza.saleFolio != null)
                    Text(
                      garza.saleFolio!,
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
