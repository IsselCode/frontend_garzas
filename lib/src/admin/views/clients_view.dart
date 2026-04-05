import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/confirm_delete_client_dialog.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/update_client_dialog.dart';
import 'package:frontend_garzas/src/admin/controllers/clients_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../../inject_container.dart';
import '../../../commons/text_back_button.dart';
import '../clean/dialogs/create_client_dialog.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ReportsAndLogsViewState();
}

class _ReportsAndLogsViewState extends State<ClientsView> {

  late Future<CtrlResponse> _getClients;
  FocusNode findByPhoneNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ClientsController clientsController = context.read();
    _getClients = clientsController.getClients();
  }

  @override
  Widget build(BuildContext context) {
    // Theme
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    // Controllers
    ClientsController clientsController = context.watch();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: kWindowCaptionHeight + 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            // App Bar
            Column(
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextBackButton(),
                    Flex(
                      direction: Axis.horizontal,
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 250,
                          child: IsselTextFormField(
                            focusNode: findByPhoneNode,
                            height: 50,
                            prefixIcon: Icons.search,
                            hintText: "Teléfono",
                            onSubmitted: findClientByPhone,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: IsselButton(
                            text: "Nuevo",
                            height: 50,
                            onTap: createClient,
                          ),
                        )
                      ],
                    )
                  ],
                ),

              ],
            ),
            // Body
            FutureBuilder(
              future: _getClients,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(child: IsselShimmer(width: double.infinity, height: double.infinity));
                }

                if (!snapshot.data!.success) {
                  return Expanded(child: Center(child: Text(snapshot.data!.message!)));
                }

                if (clientsController.showedClients.isEmpty){
                  return Expanded(child: Center(child: Text("No hay clientes disponibles"),));
                }

                List<ClientEntity> clients = clientsController.showedClients;

                return Expanded(
                  child: IsselTableWidget(
                    header: IsselHeaderTable(
                      titleHeaders: ["Nombre", "Teléfono", "Costo agua potable", "Costo agua pozo", "Acciones"],
                    ),
                    rows: clients.map((client) {
                      return IsselRowTable(
                        cells: [
                          IsselPill(
                            widget: Text(client.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            color: colorScheme.surfaceContainer,
                            alignment: Alignment.centerLeft,
                            height: 60,
                          ),
                          IsselPill(
                            widget: Text(client.phone, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            color: colorScheme.surfaceContainer,
                            height: 60,
                            alignment: Alignment.centerLeft,
                          ),
                          IsselPill(
                            height: 60,
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("M3: ${client.potableM3Pricing != 0 ? "\$${client.potableM3Pricing}" : "n/a"}", maxLines: 1, overflow: TextOverflow.ellipsis,),
                                Text("Gal: ${client.potableGalPricing != 0 ? "\$${client.potableGalPricing}" : "n/a"}", maxLines: 1, overflow: TextOverflow.ellipsis,),
                              ],
                            ),
                            color: colorScheme.surfaceContainer,
                            alignment: Alignment.centerLeft,
                          ),
                          IsselPill(
                            height: 60,
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("M3: ${client.pozoM3Pricing != 0 ? "\$${client.pozoM3Pricing}" : "n/a" }", maxLines: 1, overflow: TextOverflow.ellipsis,),
                                Text("Gal: ${client.pozoGalPricing != 0 ? "\$${client.pozoGalPricing}" : "n/a" }", maxLines: 1, overflow: TextOverflow.ellipsis,),
                              ],
                            ),
                            color: colorScheme.surfaceContainer,
                            alignment: Alignment.centerLeft,
                          ),
                          IsselPill(
                            height: 60,
                            widget: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              spacing: 5,
                              children: [
                                IconButton(
                                  onPressed: () => editClient(client),
                                  icon: Icon(Icons.edit, color: colorScheme.primary,)
                                ),
                                IconButton(
                                  onPressed: () => deleteClient(client.phone),
                                  icon: Icon(Icons.delete_outline, color: Colors.red,)
                                ),
                              ],
                            ),
                            color: colorScheme.surfaceContainer,
                          ),
                        ]
                      );
                    },).toList()
                  ),
                );

              },
            )
          ],
        ),
      ),
    );
  }

  void findClientByPhone(String phone) async {
    ClientsController clientsController = context.read();

    context.loaderOverlay.show();
    CtrlResponse response = await clientsController.getClientsByPhone(phone);
    context.loaderOverlay.hide();

    if (!response.success) {
      ToastService toastService = locator();
      toastService.error(response.message!);
    }

    findByPhoneNode.requestFocus();

  }

  void editClient(ClientEntity client) async {

    await showDialog(
      context: context,
      builder: (context) => UpdateClientDialog(clientEntity: client),
    );

  }

  void deleteClient(String phone) async {

    ClientsController clientsController = context.read();

    bool dialogResponse = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteClientDialog(client: phone),
    ) ?? false;

    if (!dialogResponse) return;

    context.loaderOverlay.show();
    CtrlResponse response = await clientsController.deleteClientByPhone(phone);
    context.loaderOverlay.hide();

    ToastService toastService = locator();
    if (response.success) {
      toastService.success("Cliente eliminado");
    } else {
      toastService.error(response.message!);
    }

  }

  void createClient() async {

    await showDialog(
      context: context,
      builder: (context) => CreateClientDialog(),
    );

  }

}
