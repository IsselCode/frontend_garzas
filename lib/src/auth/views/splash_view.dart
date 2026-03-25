import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../../core/app/consts.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late final AnimationController _circleCtrl;
  late final AnimationController _textCtrl;
  late final Animation<double> _circleAnim;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;

  @override
  void initState() {
    super.initState();
    Duration circleDuration = const Duration(milliseconds: 2000);
    Duration textDuration = const Duration(milliseconds: 1500);
    Duration startDelay = const Duration(milliseconds: 500);

    _circleCtrl = AnimationController(vsync: this, duration: circleDuration);
    _circleAnim = CurvedAnimation(parent: _circleCtrl, curve: Curves.easeOutCubic,);

    _textCtrl = AnimationController(vsync: this, duration: textDuration);
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textScale = Tween(begin: 0.0, end: 1.0,).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutBack));

    Future.delayed(startDelay, () async {
      _circleCtrl.forward();
      await Future.delayed(Duration(milliseconds: (circleDuration.inMilliseconds * 0.4).toInt()),);
      await _textCtrl.forward();
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      await context.read<AuthController>().restoreSession();
    });
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final fullRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: AnimatedBuilder(
        animation: _circleAnim,
        builder: (context, _) {
          final radius = _circleAnim.value * fullRadius;

          return Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _CenterCirclePainter(
                    color: theme.scaffoldBackgroundColor,
                    radius: radius,
                  ),
                ),
              ),
              ScaleTransition(
                scale: _textScale,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Image.asset(
                    AppAssets.logoText,
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CenterCirclePainter extends CustomPainter {
  final Color color;
  final double radius;

  _CenterCirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CenterCirclePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}
