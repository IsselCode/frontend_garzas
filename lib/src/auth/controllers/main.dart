import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

class AuthController extends ChangeNotifier {

  Future<CtrlResponse> deleteUserById(int id) async {
    throw UnimplementedError();
  }

  Future<CtrlResponse> updateUser(int id, String newUsername, AppRole newRole) async {
    throw UnimplementedError();
  }

  Future<CtrlResponse> getUsers() async {
    throw UnimplementedError();
  }

  Future<CtrlResponse> insertNormalUser(String username, String password, AppRole role) async {
    throw UnimplementedError();
  }

}