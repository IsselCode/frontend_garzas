import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';
import 'package:frontend_garzas/src/dispatch/views/confirm_finish_dispatch_dialog.dart';
import 'package:frontend_garzas/src/dispatch/views/home_dispatch_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class DispatchSessionView extends StatefulWidget {
  const DispatchSessionView({super.key});

  @override
  State<DispatchSessionView> createState() => _DispatchSessionViewState();
}

class _DispatchSessionViewState extends State<DispatchSessionView> {
  Future<CtrlResponse<DispatchSessionEntity>>? _loadSession;

  @override
  void initState() {
    super.initState();
    final controller = context.read<DispatchController>();
    final sessionId =
        controller.activeSession?.id ??
        controller.selectedRuntimeGarza?.activeSessionId;

    if (sessionId != null) {
      _loadSession = controller.loadRuntimeSession(sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final controller = context.watch<DispatchController>();
    final runtimeGarza = controller.selectedRuntimeGarza;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: FutureBuilder(
              future: _loadSession,
              builder: (context, snapshot) {
                if (_loadSession != null &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const IsselShimmer(width: 640, height: 360);
                }

                final session = controller.activeSession;
                if (runtimeGarza == null && session == null) {
                  return Text(
                    'No hay una sesion seleccionada',
                    style: textTheme.titleLarge,
                  );
                }

                final actions = _buildSessionActions(controller, session);
                final hasActiveAlarms = runtimeGarza?.hasActiveAlarms ?? false;
                final isCompleted =
                    runtimeGarza?.currentState == DispatchState.completed ||
                    session?.state == DispatchState.completed ||
                    controller.selectedRuntimeGarzaWasReleased;

                return Row(
                  children: [
                    Expanded(
                      child: _SessionSummary(
                        runtimeGarza: runtimeGarza,
                        session: session,
                        wasReleasedFromRuntime:
                            controller.selectedRuntimeGarzaWasReleased,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryToSecondary,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 320,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 18,
                              children: [
                                Text(
                                  'Control de despacho',
                                  style: textTheme.displaySmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (isCompleted) ...[
                                  Text(
                                    'El despacho se realizo con exito',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  IsselButton(
                                    text: 'Volver',
                                    onTap: _goToDispatchHome,
                                  ),
                                ] else if (hasActiveAlarms) ...[
                                  Text(
                                    'Se interrumpio el despacho por una alarma',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  IsselButton(
                                    text: 'Salir al home de despacho',
                                    onTap: _goToDispatchHome,
                                  ),
                                ] else if (actions.isEmpty)
                                  Text(
                                    'Sin acciones disponibles',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                else
                                  ...actions.map(
                                    (action) => IsselButton(
                                      text: action.label,
                                      color: action.color,
                                      onTap: () => _runAction(action),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton(
              text: 'Realizar nuevo despacho',
              onTap: _goToDispatchHome,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAction(_SessionAction action) async {
    if (action.confirmBeforeRun) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => const ConfirmFinishDispatchDialog(),
      );

      if (!mounted || confirmed != true) return;
    }

    final loaderOverlay = context.loaderOverlay;
    loaderOverlay.show();
    final response = await action.callback();

    if (!mounted) return;

    loaderOverlay.hide();

    final toastService = locator<ToastService>();
    if (response.success) {
      toastService.success('Sesion actualizada');
      if (action.goHomeOnSuccess) {
        _goToDispatchHome();
      }
      return;
    }

    toastService.error(
      response.message ?? 'No fue posible actualizar la sesion',
    );
  }

  void _goToDispatchHome() {
    locator<NavigationService>().pushAndRemoveUntil(const HomeDispatchView());
  }

  List<_SessionAction> _buildSessionActions(
    DispatchController controller,
    DispatchSessionEntity? session,
  ) {
    if (session == null) return [];

    if (session.state == DispatchState.completed ||
        session.state == DispatchState.interrupted) {
      return [];
    }

    if (session.mode == DispatchMode.manual) {
      return [
        _SessionAction(
          label: 'Terminar',
          color: Colors.red,
          callback: controller.completeActiveSession,
          confirmBeforeRun: true,
          goHomeOnSuccess: true,
        ),
      ];
    }

    switch (session.state) {
      case DispatchState.authorized:
        return [
          _SessionAction(
            label: 'Iniciar',
            callback: controller.startActiveSession,
          ),
        ];
      case DispatchState.dispensing:
        return [
          _SessionAction(
            label: 'Pausar',
            callback: controller.pauseActiveSession,
          ),
        ];
      case DispatchState.paused:
        return [
          _SessionAction(
            label: 'Reanudar',
            callback: controller.resumeActiveSession,
          ),
          _SessionAction(
            label: 'Terminar',
            color: Colors.red,
            callback: controller.completeActiveSession,
            confirmBeforeRun: true,
            goHomeOnSuccess: true,
          ),
        ];
      case DispatchState.completed:
      case DispatchState.interrupted:
        return [];
    }
  }
}

class _SessionAction {
  final String label;
  final Color? color;
  final Future<CtrlResponse<DispatchSessionEntity>> Function() callback;
  final bool confirmBeforeRun;
  final bool goHomeOnSuccess;

  const _SessionAction({
    required this.label,
    required this.callback,
    this.color,
    this.confirmBeforeRun = false,
    this.goHomeOnSuccess = false,
  });
}

class _SessionSummary extends StatelessWidget {
  final GarzaRuntimeEntity? runtimeGarza;
  final DispatchSessionEntity? session;
  final bool wasReleasedFromRuntime;

  const _SessionSummary({
    required this.runtimeGarza,
    required this.session,
    required this.wasReleasedFromRuntime,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final garzaNumber = runtimeGarza?.garzaNumber ?? session?.garzaNumber;
    final state = wasReleasedFromRuntime
        ? DispatchState.completed.label
        : runtimeGarza?.currentState?.label ?? session?.state.label ?? '-';
    final authorized =
        runtimeGarza?.authorizedVolume ??
        session?.authorizedVolume ??
        0;
    final dispensed =
        runtimeGarza?.dispensedVolume ??
        session?.dispensedVolume ??
        0;
    final unitOfMeasurement =
        runtimeGarza?.unitOfMeasurement ?? session?.unitOfMeasurement;
    final unitLabel = unitOfMeasurement?.dp ?? 'Cantidad';
    final unitAbbr = unitOfMeasurement?.abbr ?? '';

    return Center(
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text('Garza $garzaNumber', style: textTheme.displayMedium),

            Text("Estado", style: textTheme.titleMedium),
            IsselTextFormField(
              hintText: "Nombre del cliente",
              controller: TextEditingController(text: state),
              readOnly: true,
            ),

            Text("Folio", style: textTheme.titleMedium),
            IsselTextFormField(
              hintText: "Folio",
              controller: TextEditingController(
                text: runtimeGarza?.saleFolio ?? session?.saleFolio ?? '-',
              ),
              readOnly: true,
            ),

            Text("Codigo", style: textTheme.titleMedium),
            IsselTextFormField(
              hintText: "Codigo",
              controller: TextEditingController(
                text:
                    runtimeGarza?.dispatchCode ?? session?.dispatchCode ?? '-',
              ),
              readOnly: true,
            ),

            Text(unitLabel, style: textTheme.titleMedium),
            IsselTextFormField(
              hintText: unitLabel,
              controller: TextEditingController(
                text:
                    '${dispensed.toStringAsFixed(2)} / ${authorized.toStringAsFixed(2)} $unitAbbr',
              ),
              readOnly: true,
            ),

            if (runtimeGarza?.hasActiveAlarms ?? false)
              Text(
                'Alarmas: ${runtimeGarza!.activeAlarmDisplayNames.join(', ')}',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}
