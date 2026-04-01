import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class IsselCarouselTest extends StatefulWidget {
  const IsselCarouselTest({
    super.key,
    required this.height,
    required this.itemBuilder,
    required this.itemCount,
    this.viewportFraction = 0.25,
    this.selectedScale = 1.0,
    this.unselectedScale = 2 / 3,
    this.initialIndex = 0,
    this.onChanged,
    this.onTap,
    this.borderRadius,
    this.stepAnimationDuration = const Duration(milliseconds: 220),
    this.scaleAnimationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
  }) : assert(itemCount > 0, 'itemCount debe ser > 0');

  final Widget Function(BuildContext context, int index, bool isSelected)
  itemBuilder;

  final int itemCount;
  final double height;
  final double viewportFraction;
  final double selectedScale;
  final double unselectedScale;
  final BorderRadius? borderRadius;
  final int initialIndex;
  final void Function(int index)? onChanged;
  final void Function(int index)? onTap;
  final Duration stepAnimationDuration;
  final Duration scaleAnimationDuration;
  final Curve curve;

  @override
  State<IsselCarouselTest> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<IsselCarouselTest> {
  late final PageController _pageController;

  static const int _kVirtualCount = 1000000;

  late int _selected;
  bool _isAnimating = false;
  double? _lastPixels;

  int get _virtualCenterAligned {
    final base = _kVirtualCount ~/ 2;
    final offset = base % widget.itemCount;
    return base - offset;
  }

  int get _initialGlobalPage => _virtualCenterAligned + _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex % widget.itemCount;
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: _initialGlobalPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateToGlobal(int globalTarget) async {
    _isAnimating = true;
    try {
      await _pageController.animateToPage(
        globalTarget,
        duration: widget.stepAnimationDuration,
        curve: widget.curve,
      );
    } finally {
      _isAnimating = false;
    }
  }

  Future<void> _animateStep(int dir) async {
    final pageNow = _pageController.page?.round() ?? _initialGlobalPage;
    await _animateToGlobal(pageNow + dir);
  }

  void _maybeRecentre(int globalIndex) {
    const int guard = 2000;
    if (globalIndex < guard || globalIndex > (_kVirtualCount - guard)) {
      final newCenter = _virtualCenterAligned + (globalIndex % widget.itemCount);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pageController.jumpToPage(newCenter);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: widget.height,
            child: Center(
              child: SizedBox(
                width: constraints.maxWidth * widget.viewportFraction,
                child: AnimatedScale(
                  duration: widget.scaleAnimationDuration,
                  scale: widget.selectedScale,
                  child: Material(
                    borderRadius: widget.borderRadius,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: widget.borderRadius,
                      onTap: () {
                        widget.onTap?.call(0);
                      },
                      child: widget.itemBuilder(context, 0, true),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (_isAnimating) return false;

        final page = _pageController.page ?? _initialGlobalPage.toDouble();
        final atRest = (page - page.roundToDouble()).abs() < 0.0001;

        if (n is ScrollUpdateNotification && atRest) {
          final pixels = n.metrics.pixels;
          if (_lastPixels == null) {
            _lastPixels = pixels;
            return false;
          }
          final delta = pixels - _lastPixels!;
          _lastPixels = pixels;

          if (delta.abs() > 0.5) {
            final dir = delta > 0 ? 1 : -1;
            _animateStep(dir);
          }
        }
        if (n is ScrollEndNotification) {
          _lastPixels = null;
        }
        return false;
      },
      child: SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _kVirtualCount,
          pageSnapping: true,
          physics: const PageScrollPhysics(),
          onPageChanged: (globalIndex) {
            final real = globalIndex % widget.itemCount;
            if (_selected != real) {
              setState(() => _selected = real);
              widget.onChanged?.call(real);
            }
            _maybeRecentre(globalIndex);
          },
          itemBuilder: (context, globalIndex) {
            final real = globalIndex % widget.itemCount;
            final isSelected = real == _selected;

            return Center(
              child: AnimatedScale(
                duration: widget.scaleAnimationDuration,
                scale: isSelected ? widget.selectedScale : widget.unselectedScale,
                child: Material(
                  borderRadius: widget.borderRadius,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: widget.borderRadius,
                    onTap: () {
                      final real = globalIndex % widget.itemCount;
                      widget.onTap?.call(real);
                    },
                    child: widget.itemBuilder(context, real, isSelected)
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
