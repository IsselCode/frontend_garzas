import 'package:flutter/material.dart';

/// Keep table columns readable when the window or navigation pane is narrow.
class AdminTableViewport extends StatelessWidget {
  const AdminTableViewport({
    super.key,
    required this.child,
    this.minWidth = 760,
  });

  final Widget child;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth < minWidth
            ? minWidth
            : constraints.maxWidth,
        height: constraints.maxHeight,
        child: child,
      ),
    ),
  );
}
