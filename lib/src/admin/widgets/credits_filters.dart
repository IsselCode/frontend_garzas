import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../clean/enums/credit_status.dart';
import 'admin_date_range_fields.dart';

class CreditsFilters extends StatelessWidget {
  const CreditsFilters({
    super.key,
    required this.search,
    required this.searchKey,
    required this.status,
    required this.dateRange,
    required this.loading,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
  });

  final TextEditingController search;
  final GlobalKey<FormFieldState<String>> searchKey;
  final CreditStatus status;
  final DateTimeRange? dateRange;
  final bool loading;
  final ValueChanged<String> onSearchChanged, onSearchSubmitted;
  final VoidCallback onClearSearch;
  final ValueChanged<CreditStatus> onStatusChanged;
  final Future<bool> Function(DateTimeRange?) onDateRangeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final client = _field(
      context,
      label: 'Cliente',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: IsselTextFormField(
              key: searchKey,
              controller: search,
              height: 40,
              hintText: 'Nombre comercial',
              prefixIcon: Icons.search,
              fillColor: colors.surfaceContainer,
              readOnly: loading,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
              validator: (value) {
                final normalized = (value ?? '').trim().replaceAll(
                  RegExp(r'\s+'),
                  ' ',
                );
                return normalized.runes.length > 45
                    ? 'Máximo 45 caracteres'
                    : null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          if (search.text.isNotEmpty)
            IconButton(
              tooltip: 'Limpiar cliente',
              onPressed: loading ? null : onClearSearch,
              color: colors.outline,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
    final state = _field(
      context,
      label: 'Estado',
      child: AbsorbPointer(
        absorbing: loading,
        child: IsselDropdown<CreditStatus>(
          height: 40,
          value: status,
          hintText: 'Estado',
          color: colors.surfaceContainer,
          items: [
            for (final value in CreditStatus.values)
              DropdownMenuItem(value: value, child: Text(value.label)),
          ],
          onChanged: (value) {
            if (!loading && value != null) onStatusChanged(value);
          },
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 440
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [client, state],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Expanded(child: client),
                    SizedBox(width: 170, child: state),
                  ],
                ),
        ),
        AbsorbPointer(
          absorbing: loading,
          child: Tooltip(
            message: 'El rango corresponde a la fecha de creación de la venta.',
            child: AdminDateRangeFields(
              initialRange: dateRange,
              onChanged: onDateRangeChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context, {
    required String label,
    required Widget child,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 18,
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
      const SizedBox(height: 4),
      child,
    ],
  );
}
