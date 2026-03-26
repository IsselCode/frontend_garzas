import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/confirm_delete_user_dialog.dart';
import 'package:frontend_garzas/src/admin/controllers/users_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../../../../commons/ctrl_response.dart';
import '../../../../commons/entities/user_entity.dart';
import '../../../../core/app/consts.dart';
import '../../../../core/services/toast_service.dart';
import '../../../../inject_container.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../clean/enums/enums.dart';

class UpdateClientPage extends StatefulWidget {

  UpdateClientPage({super.key});

  @override
  State<UpdateClientPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateClientPage> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController displayName = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  AppRole selectedRole = AppRole.admin;

  PageController pageController = PageController();
  int indexPage = 0;
  UserEntity? selectedUser;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return Material(
      child: Column(
        spacing: 10,
        children: [
          //* Cuerpo [Lista de usuarios y datos de actualización]
          Expanded(
            child: Material(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  _UserList(
                    onChanged: (userEntity) => setState(() {selectedUser = userEntity;}),
                    selectedUser: selectedUser,
                  ),
                  if (selectedUser != null)
                  Form(
                    key: formKey,
                    child: _UserUpdate(
                      displayName: displayName,
                      selectedRole: selectedRole,
                      username: username,
                      password: password,
                      userEntity: selectedUser!,
                      onChanged: (role) {
                        selectedRole = role;
                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
            ),
          ),

          //* Botones para eliminar y actualizar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 10,
              children: [
                if (indexPage == 1)
                Expanded(
                  child: IsselButton(
                    text: "Eliminar",
                    color: Colors.red,
                    onTap: deleteUser,
                  ),
                ),
                Expanded(
                  child: IsselButton(
                    text: indexPage == 1 ? "Actualizar" : "Siguiente",
                    onTap: indexPage == 1 ? updateUser : selectUser,
                  ),
                )
              ],
            ),
          ),

          //* Botón para retroceder
          if (indexPage == 1)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: IsselButton(
              text: "Atras",
              textColor: AppColors.grey,
              color: Colors.transparent,
              onTap: backToList,
            ),
          ),
        ],
      ),
    );
  }

  void deleteUser() async {

    bool? dialogResponse = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteUserDialog(username: selectedUser!.username),
    );

    if (dialogResponse == null || dialogResponse == false) {
      return;
    }

    UsersController usersController = context.read();
    ToastService toastService = locator();

    context.loaderOverlay.show();
    CtrlResponse response = await usersController.deleteUserById(selectedUser!.uid);
    context.loaderOverlay.hide();

    if (response.success) {
      Duration duration = Duration(milliseconds: 350);
      Curve curve = Curves.linearToEaseOut;
      pageController.animateToPage(0, duration: duration, curve: curve);
      indexPage = 0;
      setState(() {});
      toastService.success("Usuario eliminado");
    } else {
      toastService.error(response.message!);
    }

  }

  void updateUser() async {

    if (!formKey.currentState!.validate()){
      return ;
    }

    UsersController usersController = context.read();
    ToastService toastService = locator();

    context.loaderOverlay.show();
    CtrlResponse response = await usersController.updateUser(
      selectedUser!.uid,
      username.text,
      displayName.text,
      password.text,
      selectedRole
    );
    context.loaderOverlay.hide();

    if (response.success) {
      toastService.success("Usuario modificado");
    } else {
      toastService.error(response.message!);
    }
  }

  void backToList() {
    Duration duration = Duration(milliseconds: 350);
    Curve curve = Curves.linearToEaseOut;
    pageController.animateToPage(0, duration: duration, curve: curve);
    indexPage = 0;
    setState(() {});
  }

  void selectUser() {
    Duration duration = Duration(milliseconds: 350);
    Curve curve = Curves.linearToEaseOut;
    ToastService toastService = locator();
    if (selectedUser != null) {
      displayName.text = selectedUser!.displayName;
      username.text = selectedUser!.username;
      selectedRole = selectedUser!.role;
      pageController.animateToPage(1, duration: duration, curve: curve);
      indexPage = 1;
      setState(() {});
    } else {
      toastService.error("Selecciona un usuario");
    }
  }

}


//* Lista de usuarios
class _UserList extends StatefulWidget {

  final UserEntity? selectedUser;
  final void Function(UserEntity? userEntity) onChanged;

  const _UserList({
    super.key,
    required this.selectedUser,
    required this.onChanged
  });

  @override
  State<_UserList> createState() => _UserListState();
}

class _UserListState extends State<_UserList> {

  late Future<CtrlResponse> _future;

  @override
  void initState() {
    super.initState();
    UsersController usersController = context.read();
    _future = usersController.getUsers(null);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    UsersController usersController = context.watch();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 50,
              child: IsselShimmer(
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text("No se encontraron usuarios"),);
          }

          if (snapshot.data != null && snapshot.data!.message != null) {
            return Center(child: Text(snapshot.data!.message!),);
          }

          List<UserEntity> users = usersController.showedUsers;

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10,),
            itemBuilder: (context, index) {
              UserEntity user = users[index];

              bool selected = user == widget.selectedUser;

              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: theme.scaffoldBackgroundColor,
                selectedTileColor: colorScheme.primary,
                title: Text(user.displayName, style: textTheme.bodyMedium?.copyWith(color: selected ? colorScheme.onPrimary : AppColors.grey),),
                trailing: Text(user.role.label, style: textTheme.labelSmall?.copyWith(color: selected ? colorScheme.onPrimary : AppColors.grey),),
                selected: selected,
                onTap: () => widget.onChanged(user),
              );
            },
          );

        },
      ),
    );
  }
}

//* Actualización
class _UserUpdate extends StatefulWidget {

  final UserEntity userEntity;
  final Function(AppRole role) onChanged;
  final TextEditingController displayName;
  final TextEditingController username;
  final TextEditingController password;
  final AppRole selectedRole;

  const _UserUpdate({
    super.key,
    required this.userEntity,
    required this.onChanged,
    required this.displayName,
    required this.username,
    required this.password,
    required this.selectedRole
  });

  @override
  State<_UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<_UserUpdate> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 30,
          children: [
            //* Inputs
            Flex(
              direction: Axis.vertical,
              spacing: 10,
              children: [
                IsselTextFormField(
                  controller: widget.displayName,
                  hintText: "Nombre",
                  prefixIcon: Icons.person_outline,
                  fillColor: theme.scaffoldBackgroundColor,
                ),
                IsselTextFormField(
                  controller: widget.username,
                  hintText: "Usuario",
                  prefixIcon: Icons.person_outline,
                  fillColor: theme.scaffoldBackgroundColor,
                ),
                IsselTextFormField(
                  controller: widget.password,
                  hintText: "Contraseña",
                  prefixIcon: Icons.password_outlined,
                  fillColor: theme.scaffoldBackgroundColor,
                )
              ],
            ),
            //* Roles
            Row(
              spacing: 20,
              children: [
                IsselRadioCard(
                  value: AppRole.admin,
                  groupValue: widget.selectedRole,
                  label: "Administrador",
                  asset: AppAssets.admin,
                  surfaceColor: theme.scaffoldBackgroundColor,
                  onChanged: (v) {
                    widget.onChanged(v);
                  }
                ),
                IsselRadioCard(
                  value: AppRole.dispatch,
                  groupValue: widget.selectedRole,
                  label: "Despachador",
                  asset: AppAssets.waterTank,
                  surfaceColor: theme.scaffoldBackgroundColor,
                  onChanged: (v) {
                    widget.onChanged(v);
                  }
                ),
                IsselRadioCard(
                  value: AppRole.seller,
                  groupValue: widget.selectedRole,
                  label: "Vendedor",
                  asset: AppAssets.cashRegister,
                  surfaceColor: theme.scaffoldBackgroundColor,
                  onChanged: (v) {
                    widget.onChanged(v);
                  }
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

}
