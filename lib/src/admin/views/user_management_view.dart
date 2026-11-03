import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/dialogs/notched_dialog.dart';
import 'package:provider/provider.dart';
import '../../../commons/ctrl_response.dart';
import '../../../commons/entities/user_entity.dart';
import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';
import '../clean/enums/enums.dart';
import '../controllers/users_controller.dart';
import '../widgets/users/user_form_dialog.dart';
import '../widgets/users/users_table_card.dart';
import '../widgets/users/users_widgets.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});
  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final _search = TextEditingController();
  late final UsersController _controller;
  UserEntity? _selected;
  AppRole? _role;
  bool? _active;
  Timer? _debounce;
  int _request = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = context.read<UsersController>();
    _load(statistics: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsersController>();
    final detail = UserDetailsCard(
      user: _selected,
      busy: _busy,
      onClose: () => setState(() => _selected = null),
      onEdit: () => _openForm(_selected),
      onToggleStatus: () => _mutate(_selected!, delete: false),
      onDelete: () => _mutate(_selected!, delete: true),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UsersStatisticsGrid(statistics: controller.userStatistics),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final table = UsersTableCard(
                    controller: controller,
                    selected: _selected,
                    search: _search,
                    role: _role,
                    active: _active,
                    onSearch: (_) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 350), () {
                        if (mounted) _load();
                      });
                    },
                    onRole: (value) {
                      setState(() => _role = value);
                      _debounce?.cancel();
                      _load();
                    },
                    onActive: (value) {
                      setState(() => _active = value);
                      _debounce?.cancel();
                      _load();
                    },
                    onSelect: (user) {
                      setState(() => _selected = user);
                      if (constraints.maxWidth < 900) {
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) => NotchedDialog(
                            icon: Icons.person_outline,
                            maxWidth: 400,
                            height: 640,
                            scrollable: false,
                            contentPadding: const EdgeInsets.only(top: 48),
                            closeTooltip: 'Cerrar detalle',
                            onClose: () => Navigator.pop(dialogContext),
                            child: UserDetailsCard(
                              user: user,
                              busy: _busy,
                              showCloseButton: false,
                              onClose: () => Navigator.pop(dialogContext),
                              onEdit: () {
                                Navigator.pop(dialogContext);
                                _openForm(user);
                              },
                              onToggleStatus: () {
                                Navigator.pop(dialogContext);
                                _mutate(user, delete: false);
                              },
                              onDelete: () {
                                Navigator.pop(dialogContext);
                                _mutate(user, delete: true);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    onCreate: _busy ? null : () => _openForm(null),
                    onPage: (page) => _load(page: page),
                    onRefresh: () => _load(
                      page: controller.paging.data.page,
                      statistics: true,
                    ),
                  );
                  if (constraints.maxWidth < 900) return table;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: table),
                      const SizedBox(width: 20),
                      SizedBox(width: 300, child: detail),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load({
    int page = 1,
    bool statistics = false,
    String? selectedUid,
  }) async {
    final request = ++_request;
    final results = await Future.wait([
      _controller.getUsers(
        _search.text,
        page: page,
        role: _role,
        isActive: _active,
      ),
      if (statistics) _controller.getUserStatistics(),
    ]);
    if (!mounted || request != _request) return;
    if (results.first.success) {
      final users = _controller.paging.items;
      setState(
        () => _selected =
            users
                .where((user) => user.uid == (selectedUid ?? _selected?.uid))
                .firstOrNull ??
            users.firstOrNull,
      );
    }
    for (final result in results) {
      if (!result.success) {
        locator<ToastService>().error(
          result.message ?? 'No se pudo cargar la información',
        );
      }
    }
  }

  Future<void> _openForm(UserEntity? user) async {
    if (_busy) return;
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserFormDialog(
        user: user,
        onSubmit: (username, name, password, role) => user == null
            ? _controller.insertNormalUser(username, name, password, role)
            : _controller.updateUser(
                user.uid,
                username,
                name,
                password.isEmpty ? null : password,
                role,
              ),
      ),
    );
    if (!mounted || changed != true) return;
    await _load(
      page: _controller.paging.data.page,
      statistics: true,
      selectedUid: user?.uid,
    );
    if (mounted) {
      locator<ToastService>().success(
        user == null
            ? 'Usuario creado correctamente'
            : 'Usuario actualizado correctamente',
      );
    }
  }

  Future<void> _mutate(UserEntity user, {required bool delete}) async {
    if (_busy) return;
    final action = delete
        ? 'Eliminar'
        : user.isActive
        ? 'Desactivar'
        : 'Activar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => NotchedConfirmationDialog(
        icon: delete
            ? Icons.delete_outline
            : user.isActive
            ? Icons.person_off_outlined
            : Icons.person_outline,
        title: '$action usuario',
        message: '¿$action a ${user.username}?',
        confirmText: action,
        destructive: delete,
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _busy = true);
    final CtrlResponse result = delete
        ? await _controller.deleteUserById(user.uid)
        : await _controller.updateStatus(user.uid, !user.isActive);
    if (!mounted) return;
    if (result.success) {
      await _load(
        page: _controller.paging.data.page,
        statistics: true,
        selectedUid: delete ? null : user.uid,
      );
      if (mounted) {
        locator<ToastService>().success('Usuario actualizado correctamente');
      }
    } else {
      locator<ToastService>().error(
        result.message ?? 'No se pudo actualizar el usuario',
      );
    }
    if (mounted) setState(() => _busy = false);
  }
}
