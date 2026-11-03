import 'package:flutter/material.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'package:window_manager/window_manager.dart';

/// Read native state once; keep it current through window events.
class DesktopWindowControls extends StatefulWidget {
  const DesktopWindowControls({super.key, this.brightness});

  final Brightness? brightness;

  @override
  State<DesktopWindowControls> createState() => _DesktopWindowControlsState();
}

class _DesktopWindowControlsState extends State<DesktopWindowControls>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _readInitialState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = widget.brightness ?? Theme.of(context).brightness;
    return Row(
      key: ValueKey(brightness),
      mainAxisSize: MainAxisSize.min,
      children: [
        WindowCaptionButton.minimize(
          brightness: brightness,
          onPressed: () => windowManager.minimize(),
        ),
        if (_isMaximized)
          SnapLayoutsButton.unmaximize(
            brightness: brightness,
            onPressed: () => windowManager.unmaximize(),
          )
        else
          SnapLayoutsButton.maximize(
            brightness: brightness,
            onPressed: () => windowManager.maximize(),
          ),
        WindowCaptionButton.close(
          brightness: brightness,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }

  Future<void> _readInitialState() async {
    final maximized = await windowManager.isMaximized();
    if (mounted && maximized != _isMaximized) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }
}
