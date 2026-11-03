import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import '../entities/page_result.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.data,
    required this.onPageChanged,
    this.loading = false,
    this.noun = 'registros',
  });

  final PageResult<dynamic> data;
  final ValueChanged<int> onPageChanged;
  final bool loading;
  final String noun;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final start = data.total == 0 ? 0 : (data.page - 1) * data.limit + 1;
    final end = data.total == 0
        ? 0
        : (start + data.items.length - 1).clamp(0, data.total);
    final label = data.total == 0
        ? 'Mostrando 0 de 0 $noun'
        : 'Mostrando $start a $end de ${data.total} $noun';
    final count = data.totalPages.clamp(1, 4);
    final maxFirst = (data.totalPages - count + 1).clamp(1, 1 << 30);
    final first = (data.page - 1).clamp(1, maxFirst);
    Widget button({
      String? text,
      IconData? icon,
      bool selected = false,
      VoidCallback? onTap,
    }) => IsselPill(
      height: 34,
      padding: EdgeInsets.zero,
      color: selected ? colors.primary : colors.surfaceContainer,
      onTap: loading ? null : onTap,
      widget: SizedBox(
        width: 34,
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: 18,
                  color: onTap == null || loading
                      ? colors.outline.withValues(alpha: .45)
                      : colors.outline,
                )
              : Text(
                  text!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                  ),
                ),
        ),
      ),
    );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(
          icon: Icons.chevron_left,
          onTap: data.page > 1 ? () => onPageChanged(data.page - 1) : null,
        ),
        for (var index = 0; index < count; index++)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: button(
              text: '${first + index}',
              selected: first + index == data.page,
              onTap: data.totalPages > 0 && first + index != data.page
                  ? () => onPageChanged(first + index)
                  : null,
            ),
          ),
        const SizedBox(width: 5),
        button(
          icon: Icons.chevron_right,
          onTap: data.page < data.totalPages
              ? () => onPageChanged(data.page + 1)
              : null,
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final range = Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.outline),
          );
          if (constraints.maxWidth < 470) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                range,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: controls),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: range),
              controls,
            ],
          );
        },
      ),
    );
  }
}
