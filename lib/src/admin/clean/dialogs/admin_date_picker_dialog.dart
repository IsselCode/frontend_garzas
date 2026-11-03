import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

/// Compact calendar shared by the initial and final date selectors.
class AdminDatePickerDialog extends StatefulWidget {
  const AdminDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  @override
  State<AdminDatePickerDialog> createState() => _AdminDatePickerDialogState();
}

class _AdminDatePickerDialogState extends State<AdminDatePickerDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return NotchedDialog(
      icon: Icons.calendar_month_outlined,
      maxWidth: 390,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              currentDate: DateUtils.dateOnly(DateTime.now()),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: IsselButton(
                  text: 'Cancelar',
                  height: 44,
                  color: Colors.transparent,
                  textColor: colors.primary,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: IsselButton(
                  text: 'Seleccionar',
                  height: 44,
                  color: colors.primary,
                  textColor: colors.onPrimary,
                  onTap: () => Navigator.of(context).pop(_selectedDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
