import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/views/confirm_alarm_dispatch_dialog.dart';
import 'package:frontend_garzas/src/dispatch/views/finish_dispatch_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../inject_container.dart';

class SelectGarzaView extends StatefulWidget {
  const SelectGarzaView({super.key});

  @override
  State<SelectGarzaView> createState() => _SelectGarzaViewState();
}

class _SelectGarzaViewState extends State<SelectGarzaView> {
  late Future<CtrlResponse> _getAvailableGarzas;

  @override
  void initState() {
    super.initState();
    DispatchController dispatchController = context.read();
    _getAvailableGarzas = dispatchController.getAvailableGarzas();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (dispatchController.dispatchHasClient) {
        _openCustomerEmployeeDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Controllers
    DispatchController dispatchController = context.watch();

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Garzas con Agua ${dispatchController.activeWaterType == WaterType.pozo ? "de" : ""} ${dispatchController.activeWaterType!.dp}',
                  style: textTheme.displayLarge,
                ),
                Text(
                  'Selecciona la garza',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  future: _getAvailableGarzas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return IsselShimmer(width: 600, height: 350);
                    }

                    if (!snapshot.data!.success) {
                      return Center(child: Text(snapshot.data!.message!));
                    }

                    if (snapshot.data!.success &&
                        dispatchController.availableGarzas.isEmpty) {
                      return Center(child: Text("No hay garzas disponibles"));
                    }

                    List<ConfigGarzaEntity> garzas =
                        dispatchController.availableGarzas;

                    return ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: IsselCarousel(
                        onTap: (index) => selectGarza(garzas[index]),
                        height: 350,
                        itemCount: garzas.length,
                        selectedScale: 0.92,
                        unselectedScale: 0.92,
                        borderRadius: BorderRadius.circular(20),
                        itemBuilder: (context, index, isSelected) {
                          ConfigGarzaEntity garza = garzas[index];
                          final isOccupied = dispatchController.isGarzaOccupied(
                            garza.number,
                          );
                          final hasAlarms = dispatchController
                              .hasGarzaActiveAlarms(garza.number);

                          return Ink(
                            width: 350,
                            color: isOccupied
                                ? colorScheme.errorContainer.withValues(
                                    alpha: 0.35,
                                  )
                                : hasAlarms
                                ? colorScheme.tertiaryContainer.withValues(
                                    alpha: 0.45,
                                  )
                                : colorScheme.surface,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.waterTank,
                                  width: 128,
                                  height: 128,
                                ),
                                const SizedBox(height: 20),
                                Text(garza.title, style: textTheme.titleLarge),
                                Text(
                                  garza.garzaType.dp,
                                  style: textTheme.bodyLarge,
                                ),
                                if (isOccupied) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Ocupada',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else if (hasAlarms) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Con alarma',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: colorScheme.tertiary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton(),
          ),
          if (dispatchController.dispatchHasClient)
            Positioned(
              bottom: 25,
              right: 25,
              child: _CustomerEmployeeAction(
                employeeName: dispatchController.customerEmployeeName,
                showEmployeeText: dispatchController.hasCustomerEmployeeName,
                onTap: _openCustomerEmployeeDialog,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openCustomerEmployeeDialog() async {
    final dispatchController = context.read<DispatchController>();
    final employeeName = await showDialog<String>(
      context: context,
      builder: (context) => CustomerEmployeeDialog(
        initialValue: dispatchController.customerEmployeeName,
      ),
    );

    if (!mounted || employeeName == null) return;
    dispatchController.setCustomerEmployeeName(employeeName);
  }

  void selectGarza(ConfigGarzaEntity garza) async {
    DispatchController dispatchController = context.read();
    if (dispatchController.isGarzaOccupied(garza.number)) {
      locator<ToastService>().error('La garza ${garza.number} esta ocupada');
      return;
    }

    if (dispatchController.hasGarzaActiveAlarms(garza.number)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmAlarmDispatchDialog(
          garzaNumber: garza.number,
          alarms: dispatchController.getGarzaAlarmDisplayNames(garza.number),
        ),
      );

      if (!mounted || confirmed != true) return;
    }

    NavigationService navigationService = locator();
    dispatchController.selectedGarza = garza;
    if (dispatchController.isPendingDispatchFlow) {
      if (garza.garzaType == GarzaType.valvula) {
        final limitQuantity = await showDialog<double>(
          context: context,
          builder: (context) => _PendingDispatchLimitDialog(
            unitOfMeasurement: dispatchController.activeUnitOfMeasurement!,
          ),
        );

        if (!mounted || limitQuantity == null) return;
        dispatchController.setPendingDispatchLimitQuantity(limitQuantity);
      } else {
        dispatchController.setPendingDispatchLimitQuantity(null);
      }

      CtrlResponse response = await dispatchController
          .createSelectedPendingDispatch();
      if (!mounted) return;

      if (!response.success) {
        locator<ToastService>().error(response.message!);
        return;
      }
    }
    navigationService.navigateTo(FinishDispatchView());
  }
}

class _PendingDispatchLimitDialog extends StatefulWidget {
  final UnitOfMeasurement unitOfMeasurement;

  const _PendingDispatchLimitDialog({required this.unitOfMeasurement});

  @override
  State<_PendingDispatchLimitDialog> createState() =>
      _PendingDispatchLimitDialogState();
}

class _PendingDispatchLimitDialogState
    extends State<_PendingDispatchLimitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _quantityFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _quantityFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        width: 390,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 15,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Limite de seguridad',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                'Ingresa el limite en ${widget.unitOfMeasurement.dp.toLowerCase()} para esta garza automatica.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              IsselTextFormField(
                controller: _quantityController,
                focusNode: _quantityFocus,
                hintText: widget.unitOfMeasurement.dp,
                prefixIcon: Icons.water_drop_outlined,
                fillColor: theme.scaffoldBackgroundColor,
                textAlign: TextAlign.center,
                inputFormatters: <TextInputFormatter>[
                  RegexService.positiveNumberFormatter,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la cantidad';
                  }

                  final quantity = double.tryParse(value.trim());
                  if (quantity == null || quantity <= 0) {
                    return 'Ingresa un valor positivo';
                  }

                  return null;
                },
                onSubmitted: (_) => _submit(),
              ),
              Divider(color: colorScheme.outline),
              IsselButton(text: 'Continuar', height: 50, onTap: _submit),
              IsselButton(
                text: 'Volver',
                height: 50,
                color: Colors.transparent,
                textColor: colorScheme.onSurface,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, double.parse(_quantityController.text.trim()));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }
}

class _CustomerEmployeeAction extends StatelessWidget {
  final String? employeeName;
  final bool showEmployeeText;
  final VoidCallback onTap;

  const _CustomerEmployeeAction({
    required this.employeeName,
    required this.showEmployeeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        if (showEmployeeText && employeeName != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              employeeName!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        FloatingActionButton(
          heroTag: 'customerEmployeeButton',
          tooltip: 'Empleado del cliente',
          onPressed: onTap,
          child: const Icon(Icons.badge_outlined),
        ),
      ],
    );
  }
}

class CustomerEmployeeDialog extends StatefulWidget {
  final String? initialValue;

  const CustomerEmployeeDialog({super.key, this.initialValue});

  @override
  State<CustomerEmployeeDialog> createState() => _CustomerEmployeeDialogState();
}

class _CustomerEmployeeDialogState extends State<CustomerEmployeeDialog> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialValue ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      focusNode.requestFocus();
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        width: 430,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              'Empleado del cliente',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            IsselTextFormField(
              controller: controller,
              focusNode: focusNode,
              hintText: 'Nombre o gafete',
              prefixIcon: Icons.badge_outlined,
              fillColor: theme.scaffoldBackgroundColor,
              onSubmitted: (_) => _submit(),
            ),
            IsselButton(text: 'Continuar', height: 50, onTap: _submit),
            IsselButton(
              text: 'Cerrar',
              height: 50,
              color: Colors.transparent,
              textColor: colorScheme.onSurface,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    Navigator.pop(context, controller.text.trim());
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
