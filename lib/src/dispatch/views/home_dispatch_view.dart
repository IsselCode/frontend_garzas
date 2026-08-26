import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/sales_dispatch_home_switch_fab.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/scaled_text_style.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';
import 'package:frontend_garzas/src/dispatch/views/dispatch_session_view.dart';
import 'package:frontend_garzas/src/dispatch/views/pending_dispatches_view.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scaleFactor = (constraints.maxWidth / 1366).clamp(1.0, 1.7);
            final edgeSpacing = 20 * scaleFactor;
            final runtimePanelBottom = 92 * scaleFactor;
            final animationSize = 350 * scaleFactor;

            return Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Despacho',
                          style: scaledTextStyle(
                            textTheme.displayLarge,
                            scaleFactor,
                          ),
                        ),
                        Text(
                          'Escanea un nuevo ticket para comenzar',
                          style: scaledTextStyle(
                            textTheme.bodyLarge,
                            scaleFactor,
                            color: colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: 20 * scaleFactor),
                        Lottie.asset(
                          AppLotties.scan,
                          width: animationSize,
                          height: animationSize,
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
                    right: edgeSpacing,
                    bottom: runtimePanelBottom,
                    child: _GarzasRuntimePanel(
                      scaleFactor: scaleFactor,
                      busyGarzas: dispatchController.busyGarzas,
                      alarmGarzas: dispatchController.alarmGarzas,
                      lastDispatches: dispatchController.lastDispatchesForPanel,
                      runtimeMessage: dispatchController.runtimeMessage,
                      onTap: _openRuntimeGarza,
                      onLastDispatchTap: _openLastDispatch,
                    ),
                  ),
                Positioned(
                  left: edgeSpacing,
                  bottom: edgeSpacing,
                  child: const SalesDispatchHomeSwitchFab(
                    target: SalesDispatchHomeTarget.sales,
                  ),
                ),
                Positioned(
                  right: 92 * scaleFactor,
                  bottom: edgeSpacing,
                  child: FloatingActionButton(
                    heroTag: 'pendingDispatchesButton',
                    tooltip: 'Despachos pendientes',
                    onPressed: () {
                      _isNavigating = true;
                      locator<NavigationService>()
                          .navigateTo(const PendingDispatchesView())
                          .whenComplete(() {
                            if (!mounted) return;
                            _isNavigating = false;
                            _requestScannerFocus();
                          });
                    },
                    child: const Icon(Icons.assignment_outlined),
                  ),
                ),
                Positioned(
                  right: edgeSpacing,
                  bottom: edgeSpacing,
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
            );
          },
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

  void _openLastDispatch(LastDispatchSnapshot lastDispatch) {
    final dispatchController = context.read<DispatchController>();
    final navigationService = locator<NavigationService>();

    dispatchController.selectLastDispatch(lastDispatch);
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
  final double scaleFactor;
  final List<GarzaRuntimeEntity> busyGarzas;
  final List<GarzaRuntimeEntity> alarmGarzas;
  final List<LastDispatchSnapshot> lastDispatches;
  final String? runtimeMessage;
  final void Function(GarzaRuntimeEntity garza) onTap;
  final void Function(LastDispatchSnapshot lastDispatch) onLastDispatchTap;

  const _GarzasRuntimePanel({
    required this.scaleFactor,
    required this.busyGarzas,
    required this.alarmGarzas,
    required this.lastDispatches,
    required this.runtimeMessage,
    required this.onTap,
    required this.onLastDispatchTap,
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
        width: 500 * scaleFactor,
        constraints: BoxConstraints(maxHeight: 580 * scaleFactor),
        padding: EdgeInsets.all(18 * scaleFactor),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18 * scaleFactor,
              offset: Offset(0, 8 * scaleFactor),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4 * scaleFactor,
                vertical: 8 * scaleFactor,
              ),
              child: Text(
                'Garzas en atención',
                style: scaledTextStyle(textTheme.titleMedium, scaleFactor),
              ),
            ),
            if (hasRuntimeWarning)
              Padding(
                padding: EdgeInsets.only(bottom: 10 * scaleFactor),
                child: _RuntimeWarning(
                  message: warningMessage!,
                  scaleFactor: scaleFactor,
                ),
              ),
            if (busyGarzas.isEmpty &&
                alarmGarzas.isEmpty &&
                lastDispatches.isEmpty)
              Padding(
                padding: EdgeInsets.all(20 * scaleFactor),
                child: Text(
                  'No hay garzas con despachos activos o recientes',
                  style: scaledTextStyle(
                    textTheme.bodyMedium,
                    scaleFactor,
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (busyGarzas.isNotEmpty)
                      _RuntimeSectionTitle(
                        text: 'Ocupadas',
                        scaleFactor: scaleFactor,
                      ),
                    ...busyGarzas.map(
                      (garza) => Padding(
                        padding: EdgeInsets.only(bottom: 10 * scaleFactor),
                        child: _GarzaRuntimeTile(
                          scaleFactor: scaleFactor,
                          garza: garza,
                          statusText: 'Ocupada',
                          onTap: () => onTap(garza),
                        ),
                      ),
                    ),
                    if (alarmGarzas.isNotEmpty)
                      _RuntimeSectionTitle(
                        text: 'Con alarma',
                        scaleFactor: scaleFactor,
                      ),
                    ...alarmGarzas.map(
                      (garza) => Padding(
                        padding: EdgeInsets.only(bottom: 10 * scaleFactor),
                        child: _GarzaRuntimeTile(
                          scaleFactor: scaleFactor,
                          garza: garza,
                          statusText: 'Liberada con alarma',
                        ),
                      ),
                    ),
                    if (lastDispatches.isNotEmpty)
                      _RuntimeSectionTitle(
                        text: 'Último despacho',
                        scaleFactor: scaleFactor,
                      ),
                    ...lastDispatches.map(
                      (lastDispatch) => Padding(
                        padding: EdgeInsets.only(bottom: 10 * scaleFactor),
                        child: _LastDispatchTile(
                          scaleFactor: scaleFactor,
                          lastDispatch: lastDispatch,
                          onTap: () => onLastDispatchTap(lastDispatch),
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
  final double scaleFactor;

  const _RuntimeWarning({required this.message, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scaleFactor),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8 * scaleFactor),
        border: Border.all(color: colorScheme.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
            size: 22 * scaleFactor,
          ),
          SizedBox(width: 10 * scaleFactor),
          Expanded(
            child: Text(
              message,
              style: scaledTextStyle(
                textTheme.bodyMedium,
                scaleFactor,
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
  final double scaleFactor;

  const _RuntimeSectionTitle({required this.text, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 4 * scaleFactor,
        top: 10 * scaleFactor,
        bottom: 8 * scaleFactor,
      ),
      child: Text(
        text,
        style: scaledTextStyle(
          textTheme.labelLarge,
          scaleFactor,
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LastDispatchTile extends StatelessWidget {
  final double scaleFactor;
  final LastDispatchSnapshot lastDispatch;
  final VoidCallback onTap;

  const _LastDispatchTile({
    required this.scaleFactor,
    required this.lastDispatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final session = lastDispatch.session;
    final runtimeGarza = lastDispatch.runtimeGarza;
    final elapsed = lastDispatch.dispatchElapsedMs == null
        ? '--:--:---'
        : _formatDispatchDuration(
            Duration(milliseconds: lastDispatch.dispatchElapsedMs!),
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8 * scaleFactor),
      child: Ink(
        padding: EdgeInsets.all(14 * scaleFactor),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: colorScheme.primary,
              size: 42 * scaleFactor,
            ),
            SizedBox(width: 12 * scaleFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Garza ${session.garzaNumber}',
                    style: scaledTextStyle(textTheme.titleSmall, scaleFactor),
                  ),
                  Text(
                    session.state.label,
                    style: scaledTextStyle(
                      textTheme.bodySmall,
                      scaleFactor,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${session.dispensedVolume.toStringAsFixed(1)} / ${session.authorizedVolume.toStringAsFixed(1)} ${session.unitOfMeasurement.abbr}  •  $elapsed',
                    style: scaledTextStyle(
                      textTheme.bodySmall,
                      scaleFactor,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (session.saleFolio != null || session.dispatchCode != null)
                    Text(
                      session.saleFolio ?? session.dispatchCode!,
                      style: scaledTextStyle(textTheme.bodySmall, scaleFactor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (runtimeGarza?.hasActiveAlarms ?? false)
                    Text(
                      runtimeGarza!.activeAlarmDisplayNames.join(', '),
                      style: scaledTextStyle(
                        textTheme.bodySmall,
                        scaleFactor,
                        color: colorScheme.error,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.primary,
              size: 24 * scaleFactor,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDispatchDuration(Duration duration) {
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final milliseconds = duration.inMilliseconds
      .remainder(1000)
      .toString()
      .padLeft(3, '0');
  return '$minutes:$seconds:$milliseconds';
}

class _GarzaRuntimeTile extends StatelessWidget {
  final double scaleFactor;
  final GarzaRuntimeEntity garza;
  final String statusText;
  final VoidCallback? onTap;

  const _GarzaRuntimeTile({
    required this.scaleFactor,
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
      borderRadius: BorderRadius.circular(8 * scaleFactor),
      child: Ink(
        padding: EdgeInsets.all(14 * scaleFactor),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          border: Border.all(
            color: garza.hasActiveAlarms
                ? colorScheme.error
                : colorScheme.primary.withValues(alpha: 0.32),
          ),
        ),
        child: Row(
          children: [
            Badge(
              isLabelVisible: garza.hasActiveAlarms,
              backgroundColor: colorScheme.error,
              child: Image.asset(
                AppAssets.waterTank,
                width: 52 * scaleFactor,
                height: 52 * scaleFactor,
              ),
            ),
            SizedBox(width: 12 * scaleFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Garza ${garza.garzaNumber}',
                    style: scaledTextStyle(textTheme.titleSmall, scaleFactor),
                  ),
                  Text(
                    statusText,
                    style: scaledTextStyle(
                      textTheme.bodySmall,
                      scaleFactor,
                      color: garza.hasActiveAlarms
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$state  ${garza.dispensedVolume.toStringAsFixed(1)} / ${garza.authorizedVolume.toStringAsFixed(1)} ${garza.unitOfMeasurement.abbr}',
                    style: scaledTextStyle(
                      textTheme.bodySmall,
                      scaleFactor,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (alarms.isNotEmpty)
                    Text(
                      alarms,
                      style: scaledTextStyle(
                        textTheme.bodySmall,
                        scaleFactor,
                        color: colorScheme.error,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (garza.saleFolio != null)
                    Text(
                      garza.saleFolio!,
                      style: scaledTextStyle(textTheme.bodySmall, scaleFactor),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: colorScheme.primary,
                size: 24 * scaleFactor,
              ),
          ],
        ),
      ),
    );
  }
}
