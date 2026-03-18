import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:window_manager/window_manager.dart';

class DateRangeDialog extends StatefulWidget {
  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const DateRangeDialog({
    super.key,
    this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<DateRangeDialog> createState() => _DateRangeDialogState();
}

class DateRangeDialogResult {
  final DateTimeRange? range;
  final bool cleared;

  const DateRangeDialogResult({this.range, this.cleared = false});
}

class _DateRangeDialogState extends State<DateRangeDialog> {
  final DateFormat _formatter = DateFormat('dd/MM/yyyy');
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _endDateCtrl;

  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
    _startDateCtrl = TextEditingController();
    _endDateCtrl = TextEditingController();
    _syncControllers();
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 430,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'Seleccionar rango de fecha',
                  style: textTheme.headlineMedium,
                ),
                Text(
                  'Elige una fecha inicial y final para filtrar la información.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: IsselTextFormField(
                    controller: _startDateCtrl,
                    hintText: 'Fecha inicial',
                    prefixIcon: Icons.calendar_month_rounded,
                    fillColor: colorScheme.surfaceContainer,
                    readOnly: true,
                    onTap: _pickDateRange,
                  ),
                ),
                Expanded(
                  child: IsselTextFormField(
                    controller: _endDateCtrl,
                    hintText: 'Fecha final',
                    prefixIcon: Icons.event_rounded,
                    fillColor: colorScheme.surfaceContainer,
                    readOnly: true,
                    onTap: _pickDateRange,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                IsselPill(
                  text: 'Hoy',
                  color: colorScheme.surfaceContainer,
                  onTap: () => _setQuickRange(_QuickRange.today),
                ),
                IsselPill(
                  text: 'Ultimos 7 dias',
                  color: colorScheme.surfaceContainer,
                  onTap: () => _setQuickRange(_QuickRange.last7Days),
                ),
                IsselPill(
                  text: 'Este mes',
                  color: colorScheme.surfaceContainer,
                  onTap: () => _setQuickRange(_QuickRange.thisMonth),
                ),
                IsselPill(
                  text: 'Calendario',
                  color: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                  onTap: _pickDateRange,
                ),
              ],
            ),
            Divider(color: colorScheme.outlineVariant),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: IsselButton(
                    text: 'Limpiar',
                    color: Colors.transparent,
                    textColor: colorScheme.outline,
                    onTap: () => Navigator.pop(
                      context,
                      const DateRangeDialogResult(cleared: true),
                    ),
                  ),
                ),
                Expanded(
                  child: IsselButton(
                    text: 'Aplicar',
                    onTap: () => Navigator.pop(
                      context,
                      DateRangeDialogResult(range: _selectedRange),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final range = await showDateRangePicker(
      context: context,
      locale: const Locale('es', 'MX'),
      initialDateRange: _selectedRange,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      builder: (context, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              kWindowCaptionHeight + 24,
              24,
              24,
            ),
            child: Theme(
              data: theme.copyWith(
                colorScheme: colorScheme.copyWith(
                  surface: colorScheme.surface,
                  surfaceContainerHighest: colorScheme.surfaceContainer,
                  primary: colorScheme.primary,
                  onPrimary: colorScheme.onPrimary,
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    textStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (range == null || !mounted) return;

    setState(() {
      _selectedRange = DateTimeRange(
        start: _startOfDay(range.start),
        end: _endOfDay(range.end),
      );
      _syncControllers();
    });
  }

  void _setQuickRange(_QuickRange value) {
    final now = DateTime.now();

    switch (value) {
      case _QuickRange.today:
        _selectedRange = DateTimeRange(
          start: _startOfDay(now),
          end: _endOfDay(now),
        );
        break;
      case _QuickRange.last7Days:
        final start = now.subtract(const Duration(days: 6));
        _selectedRange = DateTimeRange(
          start: _startOfDay(start),
          end: _endOfDay(now),
        );
        break;
      case _QuickRange.thisMonth:
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1, 0);
        _selectedRange = DateTimeRange(
          start: _startOfDay(start),
          end: _endOfDay(end),
        );
        break;
    }

    setState(_syncControllers);
  }

  void _syncControllers() {
    _startDateCtrl.text = _selectedRange == null
        ? ''
        : _formatter.format(_selectedRange!.start);
    _endDateCtrl.text = _selectedRange == null
        ? ''
        : _formatter.format(_selectedRange!.end);
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
  }
}

enum _QuickRange { today, last7Days, thisMonth }
