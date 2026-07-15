import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/scaled_text_style.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/controllers/dispatch_controller.dart';
import 'package:frontend_garzas/src/dispatch/entities/pending_dispatch_entity.dart';
import 'package:frontend_garzas/src/dispatch/views/finish_dispatch_view.dart';
import 'package:frontend_garzas/src/dispatch/views/select_garza_view.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class PendingDispatchesView extends StatefulWidget {
  const PendingDispatchesView({super.key});

  @override
  State<PendingDispatchesView> createState() => _PendingDispatchesViewState();
}

class _PendingDispatchesViewState extends State<PendingDispatchesView> {
  late Future<CtrlResponse<List<PendingDispatchEntity>>> _pendingDispatches;

  @override
  void initState() {
    super.initState();
    _loadPendingDispatches();
  }

  void _loadPendingDispatches() {
    _pendingDispatches = context
        .read<DispatchController>()
        .listPendingDispatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final scaleFactor = (constraints.maxWidth / 1366).clamp(1.0, 1.7);
              final panelPadding = 28 * scaleFactor;

              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        panelPadding,
                        kWindowCaptionHeight + 52 * scaleFactor,
                        panelPadding,
                        panelPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child:
                                FutureBuilder<
                                  CtrlResponse<List<PendingDispatchEntity>>
                                >(
                                  future: _pendingDispatches,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const IsselShimmer(
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    }

                                    final response = snapshot.data;
                                    if (response == null || !response.success) {
                                      return Center(
                                        child: Text(
                                          response?.message ??
                                              'No fue posible cargar los despachos',
                                        ),
                                      );
                                    }

                                    final pendingDispatches =
                                        response.element ?? [];
                                    if (pendingDispatches.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No hay despachos pendientes',
                                          style: scaledTextStyle(
                                            textTheme.titleMedium,
                                            scaleFactor,
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                      );
                                    }

                                    return ScrollConfiguration(
                                      behavior: const MaterialScrollBehavior()
                                          .copyWith(
                                            dragDevices: {
                                              PointerDeviceKind.touch,
                                              PointerDeviceKind.mouse,
                                            },
                                          ),
                                      child: ListView.separated(
                                        itemCount: pendingDispatches.length,
                                        separatorBuilder: (_, _) =>
                                            SizedBox(height: 12 * scaleFactor),
                                        itemBuilder: (context, index) {
                                          final pendingDispatch =
                                              pendingDispatches[index];
                                          return _PendingDispatchTile(
                                            pendingDispatch: pendingDispatch,
                                            scaleFactor: scaleFactor,
                                            onTap: () => _openPendingDispatch(
                                              pendingDispatch,
                                            ),
                                            onCancel: () =>
                                                _cancelPendingDispatch(
                                                  pendingDispatch,
                                                ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryToSecondary,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 360 * scaleFactor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 18 * scaleFactor,
                            children: [
                              Text(
                                'Nuevo despacho pendiente',
                                style: scaledTextStyle(
                                  textTheme.displaySmall,
                                  scaleFactor,
                                  color: colorScheme.onPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              IsselButton(
                                height: 56 * scaleFactor,
                                text: 'Crear despacho',
                                onTap: _openCreateDialog,
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
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: const TextBackButton(),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final form = await showDialog<_PendingDispatchFormValue>(
      context: context,
      builder: (context) => const _CreatePendingDispatchDialog(),
    );

    if (!mounted || form == null) return;

    final controller = context.read<DispatchController>();
    controller.preparePendingDispatch(
      customerEmployeeName: form.customerEmployeeName,
      plateOrUnitReference: form.plateOrUnitReference,
      waterType: form.waterType,
      unitOfMeasurement: form.unitOfMeasurement,
    );

    locator<NavigationService>().navigateTo(SelectGarzaView());
  }

  void _openPendingDispatch(PendingDispatchEntity pendingDispatch) {
    context.read<DispatchController>().selectPendingDispatch(pendingDispatch);
    locator<NavigationService>().navigateTo(FinishDispatchView());
  }

  Future<void> _cancelPendingDispatch(
    PendingDispatchEntity pendingDispatch,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _CancelPendingDispatchDialog(pendingDispatch: pendingDispatch),
    );

    if (!mounted || confirmed != true) return;

    final loaderOverlay = context.loaderOverlay;
    loaderOverlay.show();
    final response = await context
        .read<DispatchController>()
        .cancelPendingDispatch(pendingDispatch.id);

    if (!mounted) return;

    loaderOverlay.hide();
    final toastService = locator<ToastService>();
    if (response.success) {
      toastService.success('Despacho pendiente cancelado');
      setState(_loadPendingDispatches);
      return;
    }

    toastService.error(response.message ?? 'No fue posible cancelar');
  }
}

class _PendingDispatchTile extends StatelessWidget {
  final PendingDispatchEntity pendingDispatch;
  final double scaleFactor;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _PendingDispatchTile({
    required this.pendingDispatch,
    required this.scaleFactor,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final date = DateTime.tryParse(pendingDispatch.createdAt);
    final createdAt = date == null
        ? pendingDispatch.createdAt
        : DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8 * scaleFactor),
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10 * scaleFactor,
              offset: Offset(0, 4 * scaleFactor),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * scaleFactor),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: 'Cancelar',
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  color: colorScheme.error,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scaleFactor,
                    vertical: 6 * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6 * scaleFactor),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Text(
                    'Garza ${pendingDispatch.garzaNumber}',
                    style: scaledTextStyle(
                      textTheme.labelLarge,
                      scaleFactor,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 58 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10 * scaleFactor,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          color: colorScheme.primary,
                          size: 24 * scaleFactor,
                        ),
                        SizedBox(width: 10 * scaleFactor),
                        Expanded(
                          child: Text(
                            pendingDispatch.plateOrUnitReference,
                            style: scaledTextStyle(
                              textTheme.titleMedium,
                              scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    _PendingDispatchInfoRow(
                      scaleFactor: scaleFactor,
                      icon: Icons.badge_outlined,
                      text: pendingDispatch.customerEmployeeName,
                    ),
                    Wrap(
                      spacing: 14 * scaleFactor,
                      runSpacing: 6 * scaleFactor,
                      children: [
                        _PendingDispatchDetail(
                          scaleFactor: scaleFactor,
                          icon: Icons.water_drop_outlined,
                          text: pendingDispatch.waterType.dp,
                        ),
                        _PendingDispatchDetail(
                          scaleFactor: scaleFactor,
                          icon: Icons.format_list_numbered_outlined,
                          text: pendingDispatch.quantity == null
                              ? 'Manual'
                              : '${pendingDispatch.quantity!.toStringAsFixed(2)} ${pendingDispatch.unitOfMeasurement.abbr}',
                        ),
                        _PendingDispatchDetail(
                          scaleFactor: scaleFactor,
                          icon: Icons.schedule_outlined,
                          text: createdAt,
                          style: scaledTextStyle(
                            textTheme.bodySmall,
                            scaleFactor,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingDispatchInfoRow extends StatelessWidget {
  final double scaleFactor;
  final IconData icon;
  final String text;

  const _PendingDispatchInfoRow({
    required this.scaleFactor,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18 * scaleFactor,
          color: colorScheme.onSurface.withValues(alpha: 0.62),
        ),
        SizedBox(width: 8 * scaleFactor),
        Expanded(
          child: Text(
            text,
            style: scaledTextStyle(
              textTheme.bodyMedium,
              scaleFactor,
              color: colorScheme.onSurface.withValues(alpha: 0.78),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PendingDispatchDetail extends StatelessWidget {
  final double scaleFactor;
  final IconData icon;
  final String text;
  final TextStyle? style;

  const _PendingDispatchDetail({
    required this.scaleFactor,
    required this.icon,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16 * scaleFactor, color: colorScheme.outline),
        SizedBox(width: 5 * scaleFactor),
        Text(
          text,
          style:
              style ??
              scaledTextStyle(
                textTheme.bodySmall,
                scaleFactor,
                color: colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _CancelPendingDispatchDialog extends StatelessWidget {
  final PendingDispatchEntity pendingDispatch;

  const _CancelPendingDispatchDialog({required this.pendingDispatch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancelar despacho',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              'Deseas cancelar el despacho pendiente de ${pendingDispatch.plateOrUnitReference}?',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Divider(color: colorScheme.outline),
            IsselButton(
              text: 'Cancelar despacho',
              color: Colors.red,
              onTap: () => Navigator.pop(context, true),
            ),
            IsselButton(
              text: 'Volver',
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePendingDispatchDialog extends StatefulWidget {
  const _CreatePendingDispatchDialog();

  @override
  State<_CreatePendingDispatchDialog> createState() =>
      _CreatePendingDispatchDialogState();
}

class _CreatePendingDispatchDialogState
    extends State<_CreatePendingDispatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _employeeController = TextEditingController();
  final _referenceController = TextEditingController();
  final _employeeFocus = FocusNode();
  final _referenceFocus = FocusNode();
  WaterType _waterType = WaterType.potable;
  UnitOfMeasurement _unitOfMeasurement = UnitOfMeasurement.liters;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _employeeFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                'Crear despacho pendiente',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              IsselTextFormField(
                controller: _employeeController,
                focusNode: _employeeFocus,
                hintText: 'Empleado del cliente',
                prefixIcon: Icons.badge_outlined,
                fillColor: theme.scaffoldBackgroundColor,
                validator: _requiredValidator,
                onSubmitted: (_) => _referenceFocus.requestFocus(),
              ),
              IsselTextFormField(
                controller: _referenceController,
                focusNode: _referenceFocus,
                hintText: 'Placa o unidad',
                prefixIcon: Icons.local_shipping_outlined,
                fillColor: theme.scaffoldBackgroundColor,
                validator: _requiredValidator,
                onSubmitted: (_) => _submit(),
              ),
              Text('Tipo de agua', style: textTheme.bodyMedium),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: IsselPill(
                      text: 'Potable',
                      textColor: _waterType == WaterType.potable
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      color: _waterType == WaterType.potable
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      onTap: () =>
                          setState(() => _waterType = WaterType.potable),
                    ),
                  ),
                  Expanded(
                    child: IsselPill(
                      text: 'Pozo',
                      textColor: _waterType == WaterType.pozo
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      color: _waterType == WaterType.pozo
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      onTap: () => setState(() => _waterType = WaterType.pozo),
                    ),
                  ),
                ],
              ),
              Text('Unidad de medida', style: textTheme.bodyMedium),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: IsselPill(
                      text: 'Litros',
                      textColor: _unitOfMeasurement == UnitOfMeasurement.liters
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      color: _unitOfMeasurement == UnitOfMeasurement.liters
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      onTap: () => setState(
                        () => _unitOfMeasurement = UnitOfMeasurement.liters,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IsselPill(
                      text: 'Galones',
                      textColor: _unitOfMeasurement == UnitOfMeasurement.gallons
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      color: _unitOfMeasurement == UnitOfMeasurement.gallons
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      onTap: () => setState(
                        () => _unitOfMeasurement = UnitOfMeasurement.gallons,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              IsselButton(
                text: 'Seleccionar garza',
                height: 50,
                onTap: _submit,
              ),
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
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      _PendingDispatchFormValue(
        customerEmployeeName: _employeeController.text.trim(),
        plateOrUnitReference: _referenceController.text.trim(),
        waterType: _waterType,
        unitOfMeasurement: _unitOfMeasurement,
      ),
    );
  }

  @override
  void dispose() {
    _employeeController.dispose();
    _referenceController.dispose();
    _employeeFocus.dispose();
    _referenceFocus.dispose();
    super.dispose();
  }
}

class _PendingDispatchFormValue {
  final String customerEmployeeName;
  final String plateOrUnitReference;
  final WaterType waterType;
  final UnitOfMeasurement unitOfMeasurement;

  const _PendingDispatchFormValue({
    required this.customerEmployeeName,
    required this.plateOrUnitReference,
    required this.waterType,
    required this.unitOfMeasurement,
  });
}
