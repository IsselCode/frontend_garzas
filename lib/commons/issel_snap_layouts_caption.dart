import 'package:flutter/material.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'package:window_manager/window_manager.dart';

class IsselWindowCaptionAction extends StatelessWidget {
  const IsselWindowCaptionAction({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(28, 28)),
      padding: EdgeInsets.zero,
      iconSize: 16,
      icon: icon,
      highlightColor: Colors.transparent,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

class IsselSnapLayoutsCaption extends StatefulWidget {
  const IsselSnapLayoutsCaption({
    super.key,
    this.icon,
    this.title,
    this.backgroundColor,
    this.brightness,
    this.actions = const [],
    this.snapLayoutsEnabled = true,
  });

  final Widget? icon;
  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;
  final List<IsselWindowCaptionAction> actions;
  final bool snapLayoutsEnabled;

  @override
  State<IsselSnapLayoutsCaption> createState() =>
      _IsselSnapLayoutsCaptionState();
}

class _IsselSnapLayoutsCaptionState extends State<IsselSnapLayoutsCaption>
    with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (widget.brightness == Brightness.dark
                ? const Color(0xff1C1C1C)
                : Colors.transparent),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: SizedBox(
              width: 18,
              height: 18,
              child: widget.icon ?? const FlutterLogo(),
            ),
          ),
          Expanded(
            child: DragToMoveArea(
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color:
                                widget.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black.withValues(alpha: 0.8956),
                            fontSize: 12,
                          ),
                          child: widget.title ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 5,),
          widget.actions.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Row(
                    spacing: 2,
                    children: widget.actions,
                  ),
                )
              : const SizedBox.shrink(),
          WindowCaptionButton.minimize(
            brightness: widget.brightness,
            onPressed: () async {
              final isMinimized = await windowManager.isMinimized();
              if (isMinimized) {
                windowManager.restore();
                return;
              }
              windowManager.minimize();
            },
          ),
          FutureBuilder<bool>(
            future: windowManager.isMaximized(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return SnapLayoutsButton.unmaximize(
                  brightness: widget.brightness,
                  enabled: widget.snapLayoutsEnabled,
                  onPressed: () {
                    windowManager.unmaximize();
                  },
                );
              }

              return SnapLayoutsButton.maximize(
                brightness: widget.brightness,
                enabled: widget.snapLayoutsEnabled,
                onPressed: () {
                  windowManager.maximize();
                },
              );
            },
          ),
          WindowCaptionButton.close(
            brightness: widget.brightness,
            onPressed: () {
              windowManager.close();
            },
          ),
        ],
      ),
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}
