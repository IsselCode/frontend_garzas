import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/scaled_text_style.dart';
import 'package:flutter/services.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/commons/sales_dispatch_home_switch_fab.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/pending_dispatch_entity.dart';
import 'package:frontend_garzas/src/sales/controllers/order_controller.dart';
import 'package:frontend_garzas/src/sales/views/finish_order_view.dart';
import 'package:frontend_garzas/src/sales/views/start_order_view.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../inject_container.dart';

class HomeSalesView extends StatefulWidget {
  const HomeSalesView({super.key});

  @override
  State<HomeSalesView> createState() => _HomeSalesViewState();
}

class _HomeSalesViewState extends State<HomeSalesView> {
  final FocusNode _focusNode = FocusNode();
  bool _isNavigating = false;
  bool _isPendingPaymentDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _handleUserInteraction() {
    if (_isNavigating || _isPendingPaymentDialogOpen) return;

    _isNavigating = true;
    NavigationService navigationService = locator();
    navigationService.navigateTo(StartOrderView.init(context));

    _isNavigating = false;
  }

  Future<void> _openPendingPaymentsDialog() async {
    if (_isPendingPaymentDialogOpen) return;

    setState(() {
      _isPendingPaymentDialogOpen = true;
    });

    final selection = await showDialog<_PendingPaymentSelection>(
      context: context,
      builder: (context) => const _PendingPaymentsDialog(),
    );

    if (!mounted) return;

    setState(() {
      _isPendingPaymentDialogOpen = false;
    });

    if (selection == null) {
      _focusNode.requestFocus();
      return;
    }

    final controller = OrderController(
      salesApi: locator(),
      clientsApi: locator(),
      printerService: locator(),
      generalConfigController: context.read(),
      authController: context.read(),
      pendingDispatchesApi: locator(),
    );

    controller.preparePendingDispatchPayment(
      pendingDispatch: selection.pendingDispatch,
      client: selection.client,
    );

    locator<NavigationService>().navigateTo(
      FinishOrderView.initWithController(controller),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_isPendingPaymentDialogOpen) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      _handleUserInteraction();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      floatingActionButton: const SalesDispatchHomeSwitchFab(
        target: SalesDispatchHomeTarget.dispatch,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleUserInteraction,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaleFactor = (constraints.maxWidth / 1366).clamp(1.0, 1.7);

              return SizedBox.expand(
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ventas',
                            style: scaledTextStyle(
                              textTheme.displayLarge,
                              scaleFactor,
                            ),
                          ),
                          Text(
                            'Haz clic o presiona cualquier tecla para comenzar una venta',
                            style: scaledTextStyle(
                              textTheme.bodyLarge,
                              scaleFactor,
                              color: colorScheme.outline,
                            ),
                          ),
                          SizedBox(height: 20 * scaleFactor),
                          Lottie.asset(
                            AppLotties.glass_water,
                            width: 350 * scaleFactor,
                            height: 350 * scaleFactor,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20 * scaleFactor,
                      bottom: 20 * scaleFactor,
                      child: FloatingActionButton(
                        heroTag: 'pendingPaymentsButton',
                        tooltip: 'Despachos por cobrar',
                        onPressed: _openPendingPaymentsDialog,
                        child: const Icon(Icons.receipt_long_outlined),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PendingPaymentsDialog extends StatefulWidget {
  const _PendingPaymentsDialog();

  @override
  State<_PendingPaymentsDialog> createState() => _PendingPaymentsDialogState();
}

class _PendingPaymentsDialogState extends State<_PendingPaymentsDialog> {
  final _referenceController = TextEditingController();
  ClientEntity? _selectedClient;
  late Future<CtrlResponse<List<PendingDispatchEntity>>> _pendingDispatches;
  late Future<List<ClientEntity>> _clients;
  List<ClientEntity> _showedClients = [];

  @override
  void initState() {
    super.initState();
    _pendingDispatches = _loadPendingDispatches();
    _clients = _loadClients();
  }

  Future<List<ClientEntity>> _loadClients() async {
    final clients = await locator<ClientsApi>().listClients(limit: 10);
    _showedClients = clients;
    return clients;
  }

  Future<CtrlResponse<List<PendingDispatchEntity>>>
  _loadPendingDispatches() async {
    try {
      final pendingDispatches = await locator<PendingDispatchesApi>()
          .listPendingDispatches(
            status: 'pending_payment',
            plateOrUnitReference: _referenceController.text,
          );
      return CtrlResponse(success: true, element: pendingDispatches);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        width: 620,
        height: 640,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(
              'Despachos por cobrar',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            FutureBuilder(
              future: _clients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const IsselShimmer(width: double.infinity, height: 50);
                }

                return IsselSearchDropdown<ClientEntity>(
                  height: 60,
                  maxItemsToShow: 5,
                  color: colorScheme.surfaceContainer,
                  items: _showedClients.map((client) {
                    return DropdownMenuItem(
                      value: client,
                      child: Text(client.commercialName),
                    );
                  }).toList(),
                  value: _selectedClient,
                  hintText: 'Selecciona un cliente',
                  onChanged: (client) {
                    setState(() {
                      _selectedClient = client;
                    });
                  },
                  onSearchSubmitted: _searchClients,
                );
              },
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: IsselTextFormField(
                    controller: _referenceController,
                    hintText: 'Placa o unidad',
                    prefixIcon: Icons.local_shipping_outlined,
                    fillColor: theme.scaffoldBackgroundColor,
                    onSubmitted: (_) => _searchPendingDispatches(),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: IsselButton(
                    text: 'Buscar',
                    height: 50,
                    onTap: _searchPendingDispatches,
                  ),
                ),
              ],
            ),
            Divider(color: colorScheme.outline),
            Expanded(
              child: FutureBuilder<CtrlResponse<List<PendingDispatchEntity>>>(
                future: _pendingDispatches,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const IsselShimmer(
                      width: double.infinity,
                      height: 260,
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

                  final pendingDispatches = response.element ?? [];
                  if (pendingDispatches.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay despachos por cobrar',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 4),
                    itemCount: pendingDispatches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final pendingDispatch = pendingDispatches[index];
                      return _PendingPaymentTile(
                        pendingDispatch: pendingDispatch,
                        onTap: () {
                          Navigator.pop(
                            context,
                            _PendingPaymentSelection(
                              pendingDispatch: pendingDispatch,
                              client: _selectedClient,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Divider(color: colorScheme.outline),
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

  Future<void> _searchClients(String value) async {
    try {
      final clients = await locator<ClientsApi>().listClients(
        limit: 10,
        search: value,
      );
      if (!mounted) return;
      setState(() {
        _showedClients = clients;
      });
    } on AppException catch (e) {
      locator<ToastService>().error(e.message);
    }
  }

  void _searchPendingDispatches() {
    setState(() {
      _pendingDispatches = _loadPendingDispatches();
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }
}

class _PendingPaymentTile extends StatelessWidget {
  final PendingDispatchEntity pendingDispatch;
  final VoidCallback onTap;

  const _PendingPaymentTile({
    required this.pendingDispatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final quantity =
        pendingDispatch.quantity ?? pendingDispatch.dispensedVolume;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: colorScheme.primary.withValues(alpha: 0.16),
        highlightColor: colorScheme.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pendingDispatch.plateOrUnitReference,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Garza ${pendingDispatch.garzaNumber}',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                pendingDispatch.customerEmployeeName,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _PendingPaymentDetail(
                    icon: Icons.water_drop_outlined,
                    text: pendingDispatch.waterType.dp,
                  ),
                  _PendingPaymentDetail(
                    icon: Icons.format_list_numbered_outlined,
                    text:
                        '${_formatDialogQuantity(quantity)} ${pendingDispatch.unitOfMeasurement.abbr}',
                  ),
                  _PendingPaymentDetail(
                    icon: Icons.check_circle_outline,
                    text: 'Despachado',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingPaymentDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PendingPaymentDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.outline),
        const SizedBox(width: 5),
        Text(
          text,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PendingPaymentSelection {
  final PendingDispatchEntity pendingDispatch;
  final ClientEntity? client;

  const _PendingPaymentSelection({
    required this.pendingDispatch,
    required this.client,
  });
}

String _formatDialogQuantity(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}
