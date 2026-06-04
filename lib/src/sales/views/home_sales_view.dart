import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_garzas/commons/sales_dispatch_home_switch_fab.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/src/sales/views/start_order_view.dart';
import 'package:lottie/lottie.dart';

import '../../../inject_container.dart';

class HomeSalesView extends StatefulWidget {
  const HomeSalesView({super.key});

  @override
  State<HomeSalesView> createState() => _HomeSalesViewState();
}

class _HomeSalesViewState extends State<HomeSalesView> {
  final FocusNode _focusNode = FocusNode();
  bool _isNavigating = false;

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
    if (_isNavigating) return;

    _isNavigating = true;
    NavigationService navigationService = locator();
    navigationService.navigateTo(StartOrderView.init(context));

    _isNavigating = false;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
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
              final scaleFactor = (constraints.maxWidth / 1366).clamp(
                1.0,
                1.28,
              );

              return SizedBox.expand(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ventas',
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 44 * scaleFactor,
                        ),
                      ),
                      Text(
                        'Haz clic o presiona cualquier tecla para comenzar una venta',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.outline,
                          fontSize: 18 * scaleFactor,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
