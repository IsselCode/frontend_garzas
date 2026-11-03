import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import '../../../../commons/entities/user_entity.dart';
import '../../../../commons/widgets/pagination_footer.dart';
import '../../clean/enums/enums.dart';
import '../../controllers/users_controller.dart';
import '../admin_table_viewport.dart';
import 'users_widgets.dart';

class UsersTableCard extends StatelessWidget {
  const UsersTableCard({
    super.key,
    required this.controller,
    required this.selected,
    required this.search,
    required this.role,
    required this.active,
    required this.onSearch,
    required this.onRole,
    required this.onActive,
    required this.onSelect,
    required this.onCreate,
    required this.onPage,
    required this.onRefresh,
  });
  final UsersController controller;
  final UserEntity? selected;
  final TextEditingController search;
  final AppRole? role;
  final bool? active;
  final ValueChanged<String> onSearch;
  final ValueChanged<AppRole?> onRole;
  final ValueChanged<bool?> onActive;
  final ValueChanged<UserEntity> onSelect;
  final VoidCallback? onCreate;
  final ValueChanged<int> onPage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final state = controller.paging;
    double selectorWidth(Iterable<String> labels) {
      var width = 0.0;
      for (final label in labels) {
        final painter = TextPainter(
          text: TextSpan(text: label, style: theme.textTheme.bodyMedium),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        if (painter.width > width) width = painter.width;
        painter.dispose();
      }
      return width + 56;
    }

    final roleWidth = selectorWidth([
      'Todos los roles',
      ...AppRole.values.map((value) => value.label),
    ]);
    final activeWidth = selectorWidth([
      'Todos los estados',
      'Activos',
      'Inactivos',
    ]);
    final roleField = IsselDropdown<AppRole>(
      value: role,
      hintText: 'Todos los roles',
      height: 40,
      color: colors.surfaceContainer,
      items: [
        const DropdownMenuItem<AppRole>(child: Text('Todos los roles')),
        ...AppRole.values.map(
          (value) => DropdownMenuItem(value: value, child: Text(value.label)),
        ),
      ],
      onChanged: onRole,
    );
    final activeField = IsselDropdown<bool>(
      value: active,
      hintText: 'Todos los estados',
      height: 40,
      color: colors.surfaceContainer,
      items: const [
        DropdownMenuItem<bool>(child: Text('Todos los estados')),
        DropdownMenuItem(value: true, child: Text('Activos')),
        DropdownMenuItem(value: false, child: Text('Inactivos')),
      ],
      onChanged: onActive,
    );
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outline.withValues(alpha: .18),
          width: .7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('Usuarios', style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Actualizar usuarios',
                  onPressed: state.loading ? null : onRefresh,
                  icon: const Icon(Icons.refresh_outlined),
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                IsselButton(
                  text: 'Nuevo usuario',
                  height: 38,
                  width: 150,
                  onTap: onCreate,
                ),
              ],
            ),
          ),
          Divider(color: colors.outline.withValues(alpha: .16), height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: LayoutBuilder(
              builder: (_, constraints) {
                final searchField = IsselTextFormField(
                  controller: search,
                  hintText: 'Buscar usuario...',
                  prefixIcon: Icons.search,
                  height: 40,
                  fillColor: colors.surfaceContainer,
                  onChanged: onSearch,
                );
                if (constraints.maxWidth < roleWidth + activeWidth + 210) {
                  return Column(
                    children: [
                      searchField,
                      const SizedBox(height: 10),
                      if (constraints.maxWidth >= roleWidth + activeWidth + 10)
                        Row(
                          children: [
                            Expanded(child: roleField),
                            const SizedBox(width: 10),
                            Expanded(child: activeField),
                          ],
                        )
                      else ...[
                        roleField,
                        const SizedBox(height: 10),
                        activeField,
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 10),
                    SizedBox(width: roleWidth, child: roleField),
                    const SizedBox(width: 10),
                    SizedBox(width: activeWidth, child: activeField),
                  ],
                );
              },
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ),
          Expanded(
            child: AdminTableViewport(
              minWidth: 600,
              child: Column(
                children: [
                  Container(
                    height: 42,
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        for (final header in [
                          'Usuario',
                          'Nombre',
                          'Rol',
                          'Estado',
                        ])
                          Expanded(
                            flex: header == 'Nombre' || header == 'Usuario'
                                ? 3
                                : 2,
                            child: Text(
                              header,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.outline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.loading
                        ? Center(child: IsselCircularProgressIndicator())
                        : state.items.isEmpty
                        ? Center(
                            child: Text(
                              'No hay usuarios que coincidan con la búsqueda.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.outline,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            itemCount: state.items.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: colors.outline.withValues(alpha: .12),
                            ),
                            itemBuilder: (_, index) {
                              final user = state.items[index];
                              return IsselPill(
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                color: selected?.uid == user.uid
                                    ? colors.primary.withValues(alpha: .08)
                                    : Colors.transparent,
                                onTap: () => onSelect(user),
                                widget: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          UserAvatar(user: user),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              user.username,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        user.displayName,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: UserBadge(
                                          label: user.role.label,
                                          color: colors.primary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: UserBadge(
                                          label: user.isActive
                                              ? 'Activo'
                                              : 'Inactivo',
                                          color: user.isActive
                                              ? Colors.green
                                              : colors.outline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          PaginationFooter(
            data: state.data,
            loading: state.loading,
            noun: 'usuarios',
            onPageChanged: onPage,
          ),
        ],
      ),
    );
  }
}
