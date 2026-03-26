import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/tickets/sell_ticket.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/entities/general_config_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/controllers/general_config_controller.dart';
import 'package:frontend_garzas/src/sales/clean/entities/client_entity.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../inject_container.dart';

class GeneralConfigView extends StatefulWidget {
  const GeneralConfigView({super.key});

  @override
  State<GeneralConfigView> createState() => _GeneralConfigViewState();
}

class _GeneralConfigViewState extends State<GeneralConfigView> {
  late final GeneralConfigController controller;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController businessNameCtrl = TextEditingController();
  TextEditingController bussinessAddressCtrl = TextEditingController();
  TextEditingController extraInfo1Ctrl = TextEditingController();
  TextEditingController extraInfo2Ctrl = TextEditingController();

  late Future<CtrlResponse> _loadGeneralConfig;

  @override
  void initState() {
    super.initState();
    controller = context.read<GeneralConfigController>();
    controller.addListener(_syncControllers);
    businessNameCtrl.addListener(_refreshPreview);
    bussinessAddressCtrl.addListener(_refreshPreview);
    extraInfo1Ctrl.addListener(_refreshPreview);
    extraInfo2Ctrl.addListener(_refreshPreview);
    _loadGeneralConfig = controller.loadGeneralConfig();
  }

  void _syncControllers() {
    final config = controller.generalConfigEntity;
    if (config == null ) return;

    businessNameCtrl.text = config.businessName;
    bussinessAddressCtrl.text = config.businessAddress;
    extraInfo1Ctrl.text = config.extraInfo1;
    extraInfo2Ctrl.text = config.extraInfo2;

  }

  @override
  void dispose() {
    controller.removeListener(_syncControllers);
    businessNameCtrl.removeListener(_refreshPreview);
    bussinessAddressCtrl.removeListener(_refreshPreview);
    extraInfo1Ctrl.removeListener(_refreshPreview);
    extraInfo2Ctrl.removeListener(_refreshPreview);
    businessNameCtrl.dispose();
    bussinessAddressCtrl.dispose();
    extraInfo1Ctrl.dispose();
    extraInfo2Ctrl.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    GeneralConfigController generalConfigController = context.watch();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: kWindowCaptionHeight + 10, left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            TextBackButton(),
            FutureBuilder(
              future: _loadGeneralConfig,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: Row(
                      spacing: 25,
                      children: [
                        Expanded(child: IsselShimmer(width: double.infinity, height: double.infinity)),
                        Expanded(child: IsselShimmer(width: double.infinity, height: double.infinity)),
                        Expanded(child: IsselShimmer(width: double.infinity, height: double.infinity)),
                      ],
                    ),
                  );
                }

                if (generalConfigController.generalConfigEntity == null) {
                  return Center(child: Text("No hay una configuración disponible"),);
                }

                return Expanded(
                  child: Row(
                    spacing: 25,
                    children: [
                      // LOGS
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Column(
                            spacing: 10,
                            children: [
                              Text("Logs", style: textTheme.titleLarge,),
                              IsselToggleField(
                                title: "Datos de la carga",
                                value: generalConfigController.generalConfigEntity!.loadData,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.loadData, value),
                              ),
                              IsselToggleField(
                                title: "Usuario creado",
                                value: generalConfigController.generalConfigEntity!.userCreated,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.userCreated, value),
                              ),
                              IsselToggleField(
                                title: "Usuario eliminado",
                                value: generalConfigController.generalConfigEntity!.userDeleted,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.userDeleted, value),
                              ),
                              IsselToggleField(
                                title: "Inicio de sesión",
                                value: generalConfigController.generalConfigEntity!.login,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.login, value),
                              ),
                              IsselToggleField(
                                title: "Cierre de sesión",
                                value: generalConfigController.generalConfigEntity!.logout,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.logout, value),
                              ),
                              IsselToggleField(
                                title: "Cliente creado",
                                value: generalConfigController.generalConfigEntity!.clientCreated,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.clientCreated, value),
                              ),
                              IsselToggleField(
                                title: "Cliente modificado",
                                value: generalConfigController.generalConfigEntity!.clientModified,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.clientModified, value),
                              ),
                              IsselToggleField(
                                title: "Cliente eliminado",
                                value: generalConfigController.generalConfigEntity!.clientDeleted,
                                backColor: colorScheme.surfaceContainer,
                                onChanged: (value) => updateLogs(GeneralConfigLogField.clientDeleted, value),
                              )
                            ],
                          ),
                        ),
                      ),
                      // Información del ticket
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("Información del ticket", style: textTheme.titleLarge, textAlign: TextAlign.center,),

                                Text("Nombre de la empresa", style: textTheme.titleSmall,),
                                IsselTextFormField(
                                  hintText: "PABN PURIFICADORA",
                                  prefixIcon: Icons.title_outlined,
                                  fillColor: colorScheme.surfaceContainer,
                                  controller: businessNameCtrl,
                                ),
                                Text("Información de la empresa", style: textTheme.titleSmall),
                                IsselTextFormField(
                                  hintText: "Monzón 81000",
                                  prefixIcon: Icons.directions_outlined,
                                  fillColor: colorScheme.surfaceContainer,
                                  controller: bussinessAddressCtrl,
                                ),
                                Text("Información adicional", style: textTheme.titleSmall),
                                IsselTextFormField(
                                  hintText: "Garcias por su compra.",
                                  prefixIcon: Icons.info_outline,
                                  fillColor: colorScheme.surfaceContainer,
                                  controller: extraInfo1Ctrl,
                                ),
                                IsselTextFormField(
                                  hintText: "¡Vuelva Pronto!",
                                  prefixIcon: Icons.info_outline,
                                  fillColor: colorScheme.surfaceContainer,
                                  controller: extraInfo2Ctrl,
                                ),
                                IsselButton(
                                  text: "Actualizar",
                                  onTap: () => updateTicket(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Previsualización del Ticket
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              children: [
                                Expanded(
                                  child: PdfPreview.builder(
                                    useActions: false,
                                    pdfPreviewPageDecoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [],
                                    ),
                                    scrollViewDecoration: BoxDecoration(
                                      color: colorScheme.surface,
                                    ),
                                    pagesBuilder: (context, pages) {
                                      if (pages.isEmpty) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      final page = pages.first;

                                      return LayoutBuilder(
                                        builder: (context, constraints) {
                                          final width = constraints.maxWidth * 0.95;

                                          return Center(
                                            child: SingleChildScrollView(
                                              child: Container(
                                                width: width,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [],
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: page.aspectRatio,
                                                  child: Image(
                                                    image: page.image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    build: (format) {
                                      final config = _buildPreviewConfig(generalConfigController.generalConfigEntity!);
                                      final ticket = SellTicketEntity(
                                        folio: 16383917445163345,
                                        client: ClientEntity(
                                          id: 1,
                                          user: "Cliente de ejemplo",
                                          phone: 6671234567,
                                          galPricing: 2.5,
                                          literPricing: 1.2,
                                        ),
                                        waterType: WaterType.potable,
                                        unitOfMeasurement: UnitOfMeasurement.gallons,
                                        quantity: 3.5,
                                      );

                                      return sellTicketPdf(config, ticket);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

              },
            )
          ],
        ),
      ),
    );
  }

  void updateLogs(GeneralConfigLogField field, bool newValue) async {

    if (!formKey.currentState!.validate()){
      return;
    }

    GeneralConfigController controller = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await controller.updatedLogs(field: field, value: newValue);
    if (!mounted) return;
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    if (response.success) {
      if (response.message != null) toastService.success(response.message!);
    } else {
      toastService.error(response.message!);
    }

  }

  void updateTicket() async {

    if (!formKey.currentState!.validate()){
      return;
    }

    GeneralConfigController controller = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await controller.updateTicketInfo(businessNameCtrl.text, bussinessAddressCtrl.text, extraInfo1Ctrl.text, extraInfo2Ctrl.text);
    if (!mounted) return;
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    if (response.success) {
      if (response.message != null) toastService.success(response.message!);
    } else {
      toastService.error(response.message!);
    }

  }

  GeneralConfigEntity _buildPreviewConfig(GeneralConfigEntity baseConfig) {
    return baseConfig.copyWith(
      businessName: businessNameCtrl.text,
      businessAddress: bussinessAddressCtrl.text,
      extraInfo1: extraInfo1Ctrl.text,
      extraInfo2: extraInfo2Ctrl.text,
    );
  }

}
