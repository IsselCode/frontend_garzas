import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/src/sales/views/start_order_view.dart';
import 'package:lottie/lottie.dart';

class HomeSalesView extends StatefulWidget {
  const HomeSalesView({super.key,});

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
    Navigator.push(context, MaterialPageRoute(builder: (context) => StartOrderView(),),
    ).then((_) {
      _isNavigating = false;
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleUserInteraction,
          child: SizedBox.expand(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ventas', style: textTheme.displayLarge),
                  Text(
                    'Haz clic o presiona cualquier tecla para comenzar una venta',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Lottie.asset(
                    AppLotties.scan,
                    width: 350,
                    height: 350,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
