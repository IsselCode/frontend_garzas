import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/regex_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:frontend_garzas/src/sales/views/finish_order_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/entities/client_entity.dart';
import '../../../inject_container.dart';

class StartOrderView extends StatefulWidget {
  const StartOrderView._();

  static Widget init(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderController(
        salesApi: locator(),
        clientsApi: locator(),
        printerService: locator(),
        generalConfigController: context.read(),
        authController: context.read(),
      ),
      builder: (context, child) => const StartOrderView._(),
    );
  }

  @override
  State<StartOrderView> createState() => _StartOrderViewState();
}

class _StartOrderViewState extends State<StartOrderView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Future<void> _getClients;

  @override
  void initState() {
    super.initState();
    OrderController orderController = context.read();
    _getClients = orderController.getClients();
  }

  @override
  Widget build(BuildContext context) {
    //* Theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    //* Controllers
    OrderController orderController = context.watch();

    return Scaffold(
      body: Stack(
        children: [
          // Body
          LayoutBuilder(
            builder: (context, constraints) {
              final scaleFactor = (constraints.maxWidth / 1366).clamp(
                1.0,
                1.28,
              );
              final formWidth = 350 * scaleFactor;
              final contentSpacing = 30 * scaleFactor;
              final sectionSpacing = 10 * scaleFactor;
              final controlHeight = 50 * scaleFactor;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: SizedBox(
                      width: formWidth,
                      child: Form(
                        key: formKey,
                        child: Column(
                          spacing: contentSpacing,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Comenzar Orden",
                              style: textTheme.displayLarge?.copyWith(
                                fontSize: 44 * scaleFactor,
                              ),
                            ),

                            //* Seleccionar Usuario
                            Column(
                              spacing: sectionSpacing,
                              children: [
                                Text(
                                  "Selecciona al cliente",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.outline,
                                    fontSize: 18 * scaleFactor,
                                  ),
                                ),
                                FutureBuilder(
                                  future: _getClients,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return IsselShimmer(
                                        width: double.infinity,
                                        height: controlHeight,
                                      );
                                    }

                                    return IsselSearchDropdown<ClientEntity>(
                                      height: controlHeight,
                                      maxItemsToShow: 10,
                                      items: orderController.showedClients.map((
                                        e,
                                      ) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [Text(e.commercialName)],
                                          ),
                                        );
                                      }).toList(),
                                      value: orderController.selectedClient,
                                      hintText: "Selecciona un cliente",
                                      onChanged: (p0) {
                                        orderController.selectedClient = p0;
                                      },
                                      onSearchSubmitted: (value) =>
                                          searchClients(context, value),
                                    );
                                  },
                                ),
                              ],
                            ),

                            //* Seleccionar tipo de agua
                            Column(
                              spacing: sectionSpacing,
                              children: [
                                Text(
                                  "Selecciona el tipo de agua",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.outline,
                                    fontSize: 18 * scaleFactor,
                                  ),
                                ),
                                IsselTabSwitcher(
                                  height: controlHeight,
                                  state: orderController.state,
                                  leftText: "Potable",
                                  rightText: "Pozo",
                                  onChanged: (value) =>
                                      orderController.state = value,
                                ),
                              ],
                            ),

                            //* Seleccionar La unidad de medida
                            Column(
                              spacing: sectionSpacing,
                              children: [
                                Text(
                                  "Selecciona la unidad",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.outline,
                                    fontSize: 18 * scaleFactor,
                                  ),
                                ),
                                IsselTabSwitcher(
                                  height: controlHeight,
                                  state: orderController.stateUnit,
                                  leftText: "Litros",
                                  rightText: "Galones",
                                  onChanged: (value) =>
                                      orderController.stateUnit = value,
                                ),
                              ],
                            ),

                            //* Cantidad de Litros
                            Column(
                              spacing: sectionSpacing,
                              children: [
                                Text(
                                  "Ingresa la cantidad a vender en ${orderController.stateUnit == TabSwitcherAlignStates.left ? "litros" : "galones"} ",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.outline,
                                    fontSize: 18 * scaleFactor,
                                  ),
                                ),
                                IsselTextFormField(
                                  hintText: "5",
                                  height: controlHeight,
                                  controller:
                                      orderController.quantityController,
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontSize: 28 * scaleFactor,
                                  ),
                                  inputFormatters: [
                                    RegexService.positiveNumberFormatter,
                                  ],
                                  validator: (value) {
                                    if (value == null) {
                                      return "Ingresa la cantidad de Litros a vender";
                                    }
                                    if (value.isEmpty) {
                                      return "Ingresa la cantidad de Litros a vender";
                                    }
                                    if (double.tryParse(value) == null ||
                                        double.parse(value) <= 0) {
                                      return "Ingresa un valor positivo";
                                    }
                                    return null;
                                  },
                                  onSubmitted: (value) => finishOrder(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // AppBar
          Positioned(
            top: kWindowCaptionHeight + 10,
            left: 10,
            child: TextBackButton(),
          ),
        ],
      ),
    );
  }

  void searchClients(BuildContext context, String value) async {
    OrderController orderController = context.read();
    context.loaderOverlay.show();
    CtrlResponse response = await orderController.getSearchClients(value);
    if (!context.mounted) return;
    context.loaderOverlay.hide();

    if (!response.success) {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }
  }

  void finishOrder(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    NavigationService navigationService = locator();
    navigationService.navigateTo(FinishOrderView.init(context));
  }
}
