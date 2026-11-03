import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import '../../../../commons/entities/user_entity.dart';
import '../../clean/entities/user_statistics.dart';

class UsersStatisticsGrid extends StatelessWidget {
  const UsersStatisticsGrid({super.key, required this.statistics});
  final UserStatistics? statistics;
  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Usuarios activos',
        statistics?.activeUsers,
        Icons.groups_outlined,
        const Color(0xff13b86b),
      ),
      (
        'Administradores',
        statistics?.administrators,
        Icons.security_outlined,
        const Color(0xff6d27d9),
      ),
      (
        'Vendedores',
        statistics?.sellers,
        Icons.point_of_sale_outlined,
        const Color(0xff1683e8),
      ),
      (
        'Despachadores',
        statistics?.dispatchers,
        Icons.water_drop_outlined,
        const Color(0xffc98209),
      ),
      (
        'Venta/Despacho',
        statistics?.salesDispatchers,
        Icons.sync_alt_outlined,
        const Color(0xff1495a0),
      ),
    ];
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 5
            : constraints.maxWidth >= 500
            ? 3
            : 2;
        final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stat in stats)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: stat.$4.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(stat.$3, color: stat.$4, size: 21),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.outline,
                              ),
                            ),
                            Text(
                              stat.$2?.toString() ?? '—',
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 32});
  final UserEntity user;
  final double size;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final words = user.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final initials = words
        .map((word) => word.characters.first.toUpperCase())
        .join();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colors.primary.withValues(alpha: .1),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.primary,
          fontSize: size * .34,
        ),
      ),
    );
  }
}

class UserBadge extends StatelessWidget {
  const UserBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class UserDetailsCard extends StatelessWidget {
  const UserDetailsCard({
    super.key,
    required this.user,
    required this.busy,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onClose,
    this.showCloseButton = true,
  });
  final UserEntity? user;
  final bool busy;
  final bool showCloseButton;
  final VoidCallback onEdit, onToggleStatus, onDelete, onClose;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final value = user;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: value == null
          ? Center(
              child: Text(
                'Selecciona un usuario para ver su información',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.outline,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalle del usuario',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (showCloseButton)
                        IconButton(
                          tooltip: 'Cerrar detalle',
                          onPressed: onClose,
                          icon: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(child: UserAvatar(user: value, size: 76)),
                  const SizedBox(height: 14),
                  Text(
                    value.displayName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${value.username}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      UserBadge(label: value.role.label, color: colors.primary),
                      UserBadge(
                        label: value.isActive ? 'Activo' : 'Inactivo',
                        color: value.isActive ? Colors.green : colors.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: colors.outline.withValues(alpha: .16)),
                  const SizedBox(height: 12),
                  Text(
                    'Fecha de creación',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(value.createAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  IsselButton(
                    text: 'Editar usuario',
                    height: 42,
                    onTap: busy ? null : onEdit,
                  ),
                  const SizedBox(height: 10),
                  IsselButton(
                    text: value.isActive
                        ? 'Desactivar usuario'
                        : 'Activar usuario',
                    height: 42,
                    color: colors.surfaceContainer,
                    textColor: colors.primary,
                    onTap: busy ? null : onToggleStatus,
                  ),
                  const SizedBox(height: 10),
                  IsselButton(
                    text: 'Eliminar usuario',
                    height: 42,
                    color: colors.error,
                    textColor: colors.onError,
                    onTap: busy ? null : onDelete,
                  ),
                ],
              ),
            ),
    );
  }
}
