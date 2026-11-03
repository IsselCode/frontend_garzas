import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../clean/dialogs/admin_date_picker_dialog.dart';

/// The inline initial/final date fields used by PPG's report filters.
/// The application still receives an inclusive range, as its APIs expect.
class AdminDateRangeFields extends StatefulWidget {
  const AdminDateRangeFields({
    super.key,
    this.initialRange,
    this.firstDate,
    this.lastDate,
    required this.onChanged,
  });

  final DateTimeRange? initialRange;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Future<bool> Function(DateTimeRange?) onChanged;

  @override
  State<AdminDateRangeFields> createState() => _AdminDateRangeFieldsState();
}

class _AdminDateRangeFieldsState extends State<AdminDateRangeFields> {
  DateTime? _start;
  DateTime? _end;
  bool _applying = false;

  DateTime get _first => DateUtils.dateOnly(widget.firstDate ?? DateTime(2020));
  DateTime get _last => DateUtils.dateOnly(
    widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
  );

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start;
    _end = widget.initialRange?.end;
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: AdminDateFilterField(
          label: 'Fecha inicial',
          value: _start,
          onTap: _applying ? null : () => _pickDate(isStart: true),
          onClear: _applying ? null : () => _apply(null, _end),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: AdminDateFilterField(
          label: 'Fecha final',
          value: _end,
          onTap: _applying ? null : () => _pickDate(isStart: false),
          onClear: _applying ? null : () => _apply(_start, null),
        ),
      ),
    ],
  );

  Future<void> _pickDate({required bool isStart}) async {
    final first = !isStart && _start != null
        ? DateUtils.dateOnly(_start!)
        : _first;
    final last = isStart && _end != null ? DateUtils.dateOnly(_end!) : _last;
    var initial = DateUtils.dateOnly(
      (isStart ? _start : _end) ?? DateTime.now(),
    );
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (_) => AdminDatePickerDialog(
        title: 'Seleccionar fecha',
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      ),
    );
    if (!mounted || selected == null) return;
    await _apply(isStart ? selected : _start, isStart ? _end : selected);
  }

  Future<void> _apply(DateTime? start, DateTime? end) async {
    if (_applying) return;
    final effectiveStart = start ?? _first;
    final effectiveEnd = end ?? _last;
    final range = start == null && end == null
        ? null
        : DateTimeRange(
            start: DateUtils.dateOnly(effectiveStart),
            end: DateTime(
              effectiveEnd.year,
              effectiveEnd.month,
              effectiveEnd.day,
              23,
              59,
              59,
              999,
            ),
          );
    setState(() => _applying = true);
    try {
      final accepted = await widget.onChanged(range);
      if (!mounted || !accepted) return;
      setState(() {
        _start = start;
        _end = end;
      });
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }
}

/// Copied from PPG's labeled report date field: 18 px label, 40 px control,
/// calendar icon, formatted value and an individual clear action.
class AdminDateFilterField extends StatelessWidget {
  const AdminDateFilterField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 18,
          child: Text(label, style: theme.textTheme.labelMedium),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outline.withValues(alpha: .2)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 3),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: colors.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        value == null
                            ? 'Todas las fechas'
                            : DateFormat('dd/MM/yyyy').format(value!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (value != null)
                      IconButton(
                        tooltip: 'Limpiar filtro',
                        onPressed: onClear,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          Icons.close,
                          size: 17,
                          color: colors.outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
