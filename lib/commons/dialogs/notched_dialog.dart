import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

/// Shared PPG dialog surface for forms, selectors and confirmations.
class NotchedDialog extends StatelessWidget {
  const NotchedDialog({
    super.key,
    required this.icon,
    required this.child,
    required this.onClose,
    this.iconBackgroundColor,
    this.iconColor,
    this.maxWidth = 400,
    this.height,
    this.scrollable = true,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 48, 24, 24),
    this.closeTooltip = 'Cerrar',
  });

  final IconData icon;
  final Widget child;
  final VoidCallback? onClose;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final double maxWidth;
  final double? height;
  final bool scrollable;
  final EdgeInsets contentPadding;
  final String closeTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.none,
      child: SizedBox(
        width: maxWidth,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: contentPadding,
              child: scrollable ? SingleChildScrollView(child: child) : child,
            ),
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ?? colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? colors.onPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: closeTooltip,
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: colors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotchedConfirmationDialog extends StatelessWidget {
  const NotchedConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'Cancelar',
    this.icon = Icons.help_outline,
    this.destructive = false,
    this.canConfirm = true,
    this.details,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final bool destructive;
  final bool canConfirm;
  final Widget? details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return NotchedDialog(
      icon: icon,
      iconBackgroundColor: destructive ? colors.error : colors.primary,
      iconColor: destructive ? colors.onError : colors.onPrimary,
      maxWidth: 460,
      onClose: () => Navigator.of(context).pop(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          ?details,
          IsselButton(
            text: confirmText,
            height: 48,
            color: destructive ? colors.error : colors.primary,
            textColor: destructive ? colors.onError : colors.onPrimary,
            onTap: canConfirm ? () => Navigator.of(context).pop(true) : null,
          ),
          IsselButton(
            text: cancelText,
            height: 48,
            color: Colors.transparent,
            textColor: colors.primary,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
