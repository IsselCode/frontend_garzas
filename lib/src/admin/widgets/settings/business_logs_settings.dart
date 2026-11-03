import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../clean/entities/general_config_entity.dart';
import '../../clean/enums/enums.dart';

class BusinessLogsSettings extends StatefulWidget {
  const BusinessLogsSettings({
    super.key,
    required this.config,
    required this.onChanged,
  });

  final GeneralConfigEntity config;
  final void Function(GeneralConfigLogField, bool) onChanged;

  @override
  State<BusinessLogsSettings> createState() => _BusinessLogsSettingsState();
}

class _BusinessLogsSettingsState extends State<BusinessLogsSettings> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          primary: false,
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final field in GeneralConfigLogField.values) ...[
                if (field != GeneralConfigLogField.values.first)
                  const SizedBox(height: 10),
                IsselToggleField(
                  title: _label(field),
                  value: _value(field),
                  backColor: colors.surfaceContainer,
                  valueBackColor: colors.surface,
                  onChanged: (value) => widget.onChanged(field, value),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _label(GeneralConfigLogField field) => switch (field) {
    GeneralConfigLogField.waterSupply => 'Datos de la carga',
    GeneralConfigLogField.userCreated => 'Usuario creado',
    GeneralConfigLogField.userDeleted => 'Usuario eliminado',
    GeneralConfigLogField.userModified => 'Usuario modificado',
    GeneralConfigLogField.login => 'Inicio de sesión',
    GeneralConfigLogField.logout => 'Cierre de sesión',
    GeneralConfigLogField.clientCreated => 'Cliente creado',
    GeneralConfigLogField.clientDeleted => 'Cliente eliminado',
    GeneralConfigLogField.clientModified => 'Cliente modificado',
    GeneralConfigLogField.cashRegisterOpening => 'Apertura de corte',
    GeneralConfigLogField.cashRegisterClosing => 'Cierre de corte',
    GeneralConfigLogField.saleCreated => 'Venta creada',
    GeneralConfigLogField.saleCreditLimitRejected =>
      'Crédito rechazado por límite',
    GeneralConfigLogField.dispatchCompleted => 'Despacho completo',
  };

  bool _value(GeneralConfigLogField field) {
    final config = widget.config;
    return switch (field) {
      GeneralConfigLogField.waterSupply => config.waterSupply,
      GeneralConfigLogField.userCreated => config.userCreated,
      GeneralConfigLogField.userDeleted => config.userDeleted,
      GeneralConfigLogField.userModified => config.userModified,
      GeneralConfigLogField.login => config.login,
      GeneralConfigLogField.logout => config.logout,
      GeneralConfigLogField.clientCreated => config.clientCreated,
      GeneralConfigLogField.clientDeleted => config.clientDeleted,
      GeneralConfigLogField.clientModified => config.clientModified,
      GeneralConfigLogField.cashRegisterOpening => config.cashRegisterOpening,
      GeneralConfigLogField.cashRegisterClosing => config.cashRegisterClosing,
      GeneralConfigLogField.saleCreated => config.saleCreated,
      GeneralConfigLogField.saleCreditLimitRejected =>
        config.saleCreditLimitRejected,
      GeneralConfigLogField.dispatchCompleted => config.dispatchCompleted,
    };
  }
}
