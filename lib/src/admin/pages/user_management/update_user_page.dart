import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../../../../commons/ctrl_response.dart';
import '../../../../commons/user_entity.dart';
import '../../../../core/app/consts.dart';
import '../../../../core/services/toast_service.dart';
import '../../../../inject_container.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../clean/enums/enums.dart';

class UpdateUserPage extends StatefulWidget {

  UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PageController pageController = PageController();
  int indexPage = 0;
  UserEntity? selectedUser;

  String? newUsername;
  AppRole? newAppRole;

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
                      userEntity: selectedUser!,
                      onChanged: (username, role) {
                        newAppRole = role;
                        newUsername = username;
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

    AuthController authController = context.read();
    ToastService toastService = locator();

    context.loaderOverlay.show();
    CtrlResponse response = await authController.deleteUserById(selectedUser!.id);
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

    AuthController authController = context.read();
    ToastService toastService = locator();

    context.loaderOverlay.show();
    CtrlResponse response = await authController.updateUser(selectedUser!.id, newUsername!, newAppRole!);
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
    AuthController authController = context.read();
    _future = authController.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

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

          List<UserEntity> users = snapshot.data!.element;

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
                title: Text(user.name, style: textTheme.bodyMedium?.copyWith(color: selected ? colorScheme.onPrimary : AppColors.grey),),
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
  final Function(String username, AppRole role) onChanged;

  const _UserUpdate({
    super.key,
    required this.userEntity,
    required this.onChanged,
  });

  @override
  State<_UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<_UserUpdate> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  AppRole selectedRole = AppRole.admin;

  @override
  void initState() {
    super.initState();
    username.text = widget.userEntity.name;
    selectedRole = widget.userEntity.role;
  }

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
                IsselFloatTextField(
                  controller: username,
                  hintText: "Nombre de usuario",
                  prefixIcon: Icons.person_outline,
                  fillColor: theme.scaffoldBackgroundColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Campo requerido";
                  },
                  onSubmitted: (value) {
                    widget.onChanged(value, selectedRole);
                  },
                ),
              ],
            ),
            //* Roles
            Row(
              spacing: 20,
              children: [
                IsselRadioCard(
                    value: AppRole.admin,
                    groupValue: selectedRole,
                    label: "Administrador",
                    asset: AppAssets.admin,
                    surfaceColor: theme.scaffoldBackgroundColor,
                    onChanged: (v) {
                      setState(() => selectedRole = v);
                      widget.onChanged(username.text, selectedRole);
                    }
                ),
                IsselRadioCard(
                    value: AppRole.dispatcher,
                    groupValue: selectedRole,
                    label: "Despachador",
                    asset: AppAssets.waterTank,
                    surfaceColor: theme.scaffoldBackgroundColor,
                    onChanged: (v) {
                      setState(() => selectedRole = v);
                      widget.onChanged(username.text, selectedRole);
                    }
                ),
                IsselRadioCard(
                    value: AppRole.seller,
                    groupValue: selectedRole,
                    label: "Vendedor",
                    asset: AppAssets.cashRegister,
                    surfaceColor: theme.scaffoldBackgroundColor,
                    onChanged: (v) {
                      setState(() => selectedRole = v);
                      widget.onChanged(username.text, selectedRole);
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
