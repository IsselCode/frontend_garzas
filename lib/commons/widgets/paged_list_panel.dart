import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import '../paged_list_state.dart';
import 'pagination_footer.dart';

class PagedListPanel extends StatelessWidget {
  const PagedListPanel({
    super.key,
    required this.state,
    required this.onPageChanged,
    required this.child,
    this.noun = 'registros',
  });
  final PagedListState<dynamic> state;
  final ValueChanged<int> onPageChanged;
  final Widget child;
  final String noun;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (state.error != null)
        Row(
          children: [
            Expanded(
              child: Text(
                state.error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Reintentar',
              onPressed: state.loading
                  ? null
                  : () => onPageChanged(state.requestedPage),
              icon: const Icon(Icons.refresh_outlined),
            ),
          ],
        ),
      Expanded(
        child: state.loading
            ? Center(child: IsselCircularProgressIndicator())
            : state.items.isEmpty
            ? const Center(child: Text('No hay registros para mostrar'))
            : child,
      ),
      PaginationFooter(
        data: state.data,
        loading: state.loading,
        noun: noun,
        onPageChanged: onPageChanged,
      ),
    ],
  );
}
