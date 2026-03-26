import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/admin/data/users_api.dart';

import '../../../commons/ctrl_response.dart';
import '../../../commons/entities/user_entity.dart';
import '../../../core/errors/exceptions.dart';
import '../clean/enums/enums.dart';

class UsersController extends ChangeNotifier {

  UsersApi usersApi;

  UsersController({
    required this.usersApi,
  });

  List<UserEntity> allUsers = [];
  List<UserEntity> showedUsers = [];

  Future<CtrlResponse> deleteUserById(String id) async {

    try {

      await usersApi.deleteUserById(id);
      allUsers.removeWhere((element) => element.uid == id,);
      showedUsers = allUsers;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> updateUser(String uid, String? username, String? displayName, String? password, AppRole newRole) async {

    try {

      UserEntity tempUser = await usersApi.updateUserById(uid, username, displayName, password, newRole);

      int index = allUsers.indexWhere((element) => element.uid == uid,);
      allUsers[index] = tempUser;
      showedUsers = allUsers;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getUsers(String? query) async {

    try {

      if (allUsers.isNotEmpty){
        return CtrlResponse(success: true);
      }

      List<UserEntity> tempUsers = await usersApi.listUsers(query);
      allUsers = tempUsers;
      showedUsers = tempUsers;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> insertNormalUser(String username, String displayName, String password, AppRole role,) async {

    try {

      UserEntity tempUser = await usersApi.createUser(username, displayName, password, role);
      allUsers.insert(0, tempUser);
      showedUsers = allUsers;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }


}