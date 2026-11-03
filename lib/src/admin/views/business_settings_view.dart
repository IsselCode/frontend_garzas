import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../../../commons/ctrl_response.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../clean/entities/general_config_entity.dart';
import '../controllers/general_config_controller.dart';
import '../widgets/settings/business_logs_settings.dart';
import '../widgets/settings/business_general_settings.dart';
import '../widgets/settings/business_plc_settings.dart';
import '../widgets/settings/business_prices_settings.dart';
import '../widgets/settings/business_ticket_settings.dart';

enum BusinessSettingsSection { general, ticket }

class BusinessSettingsView extends StatefulWidget {
  const BusinessSettingsView({super.key});

  @override
  State<BusinessSettingsView> createState() => _BusinessSettingsViewState();
}

class _BusinessSettingsViewState extends State<BusinessSettingsView> {
  final _ticketFormKey = GlobalKey<FormState>();
  final _plcFormKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _businessAddress = TextEditingController();
  final _extraInfo1 = TextEditingController();
  final _extraInfo2 = TextEditingController();
  final _plc = TextEditingController();
  late final GeneralConfigController _controller;
  late Future<CtrlResponse> _loadConfiguration;
  var _section = BusinessSettingsSection.general;
  var _saving = false;
  double _potableLiter = 0, _potableGallon = 0, _pozoLiter = 0, _pozoGallon = 0;
  int _printQuantity = 0;

  @override
  void initState() {
    super.initState();
    _controller = context.read<GeneralConfigController>();
    for (final field in [
      _businessName,
      _businessAddress,
      _extraInfo1,
      _extraInfo2,
    ]) {
      field.addListener(_refreshPreview);
    }
    _loadConfiguration = _load();
  }

  @override
  void dispose() {
    for (final field in [
      _businessName,
      _businessAddress,
      _extraInfo1,
      _extraInfo2,
      _plc,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<GeneralConfigController>().generalConfigEntity;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: AbsorbPointer(
          absorbing: _saving,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: IsselFilterBar<BusinessSettingsSection>(
                      value: _section,
                      height: 44,
                      itemHeight: 40,
                      selectedColor: colors.primary,
                      selectedTextColor: colors.onPrimary,
                      unselectedColor: colors.surface,
                      unselectedTextColor: colors.onSurface,
                      options: const [
                        IsselFilterOption(
                          value: BusinessSettingsSection.general,
                          label: 'General',
                        ),
                        IsselFilterOption(
                          value: BusinessSettingsSection.ticket,
                          label: 'Ticket',
                        ),
                      ],
                      onChanged: (section) =>
                          setState(() => _section = section),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IsselButton(
                    text: _section == BusinessSettingsSection.general
                        ? 'Guardar cambios'
                        : 'Guardar ticket',
                    width: 200,
                    height: 44,
                    onTap: config == null || _saving
                        ? null
                        : _section == BusinessSettingsSection.general
                        ? _saveOperatingSettings
                        : _saveTicket,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<CtrlResponse>(
                  future: _loadConfiguration,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return IsselShimmer(
                        width: double.infinity,
                        height: double.infinity,
                      );
                    }
                    if (config == null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snapshot.data?.message ??
                                  'No hay una configuración disponible',
                            ),
                            const SizedBox(height: 16),
                            IsselButton(
                              text: 'Reintentar',
                              width: 180,
                              height: 44,
                              onTap: () {
                                final pending = _load();
                                setState(() {
                                  _loadConfiguration = pending;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    final section = _buildSection(config);
                    if (_section == BusinessSettingsSection.general) {
                      return section;
                    }
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: section,
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

  Widget _buildSection(GeneralConfigEntity config) => switch (_section) {
    BusinessSettingsSection.general => BusinessGeneralSettings(
      logs: BusinessLogsSettings(
        config: config,
        onChanged: (field, value) =>
            _save(() => _controller.updatedLogs(field: field, value: value)),
      ),
      prices: BusinessPricesSettings(
        potableLiter: _potableLiter,
        potableGallon: _potableGallon,
        pozoLiter: _pozoLiter,
        pozoGallon: _pozoGallon,
        onPotableLiterChanged: (value) => _potableLiter = value,
        onPotableGallonChanged: (value) => _potableGallon = value,
        onPozoLiterChanged: (value) => _pozoLiter = value,
        onPozoGallonChanged: (value) => _pozoGallon = value,
      ),
      plc: BusinessPlcSettings(
        formKey: _plcFormKey,
        controller: _plc,
        validator: _validateEndpoint,
      ),
    ),
    BusinessSettingsSection.ticket => BusinessTicketSettings(
      formKey: _ticketFormKey,
      businessName: _businessName,
      businessAddress: _businessAddress,
      extraInfo1: _extraInfo1,
      extraInfo2: _extraInfo2,
      printQuantity: _printQuantity,
      onPrintQuantityChanged: (value) => _printQuantity = value.toInt(),
      previewConfig: config.copyWith(
        businessName: _businessName.text,
        businessAddress: _businessAddress.text,
        extraInfo1: _extraInfo1.text,
        extraInfo2: _extraInfo2.text,
      ),
    ),
  };

  Future<CtrlResponse> _load() async {
    final response = await _controller.loadGeneralConfig();
    final config = _controller.generalConfigEntity;
    if (!mounted || config == null) return response;
    _businessName.text = config.businessName;
    _businessAddress.text = config.businessAddress;
    _extraInfo1.text = config.extraInfo1;
    _extraInfo2.text = config.extraInfo2;
    _plc.text = config.plcEndpoint;
    _potableLiter = config.potableLiterPricing;
    _potableGallon = config.potableGalPricing;
    _pozoLiter = config.pozoLiterPricing;
    _pozoGallon = config.pozoGalPricing;
    _printQuantity = config.printQnty;
    return response;
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  void _saveOperatingSettings() {
    if (_plcFormKey.currentState?.validate() != true) {
      final plcContext = _plcFormKey.currentContext;
      if (plcContext != null) {
        Scrollable.ensureVisible(
          plcContext,
          duration: const Duration(milliseconds: 180),
          alignment: .5,
        );
      }
      return;
    }
    _save(
      () => _controller.updateOperatingSettings(
        potableGalPricing: _potableGallon,
        potableLiterPricing: _potableLiter,
        pozoGalPricing: _pozoGallon,
        pozoLiterPricing: _pozoLiter,
        plcEndpoint: _plc.text,
      ),
    );
  }

  void _saveTicket() {
    if (_ticketFormKey.currentState?.validate() != true) return;
    _save(
      () => _controller.updateTicketInfo(
        _businessName.text,
        _businessAddress.text,
        _extraInfo1.text,
        _extraInfo2.text,
        _printQuantity,
      ),
    );
  }

  Future<void> _save(Future<CtrlResponse> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    context.loaderOverlay.show();
    try {
      final response = await action();
      if (!mounted) return;
      final toast = locator<ToastService>();
      if (response.success) {
        toast.success(
          response.message ?? 'Configuración guardada correctamente',
        );
      } else {
        toast.error(response.message ?? 'No se pudo guardar la configuración');
      }
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
        setState(() => _saving = false);
      }
    }
  }

  String? _validateEndpoint(String? value) {
    final text = value?.trim() ?? '';
    final uri = Uri.tryParse(text.contains('://') ? text : 'http://$text');
    if (text.isEmpty ||
        uri == null ||
        uri.host.isEmpty ||
        !uri.hasPort ||
        uri.port <= 0 ||
        uri.port > 65535) {
      return 'Ingresa una IP y puerto válidos';
    }
    return null;
  }
}
