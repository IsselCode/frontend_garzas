import 'package:flutter/material.dart';
import '../../../commons/ctrl_response.dart';
import '../../../commons/entities/user_entity.dart';
import '../../../commons/paged_list_state.dart';
import '../../../core/errors/exceptions.dart';
import '../clean/entities/user_statistics.dart';
import '../clean/enums/enums.dart';
import '../data/users_api.dart';

class UsersController extends ChangeNotifier {
  UsersController({required this.usersApi}) {
    paging = PagedListState(
      onChanged: () {
        allUsers = showedUsers = paging.items;
        notifyListeners();
      },
    );
  }
  final UsersApi usersApi;
  late final PagedListState<UserEntity> paging;
  bool usersLoaded = false;
  List<UserEntity> allUsers = [], showedUsers = [];
  UserStatistics? userStatistics;
  String? _name;
  AppRole? _role;
  bool? _active;
  bool _disposed = false;
  int _statisticsRequest = 0;

  Future<CtrlResponse> getUsers(
    String? query, {
    int page = 1,
    AppRole? role,
    bool? isActive,
  }) {
    _name = query;
    _role = role;
    _active = isActive;
    usersLoaded = true;
    return paging.load(
      (number) => usersApi.listPage(
        page: number,
        name: query,
        role: role,
        isActive: isActive,
      ),
      page: page,
    );
  }

  Future<CtrlResponse> getPage(int page) =>
      getUsers(_name, page: page, role: _role, isActive: _active);
  Future<CtrlResponse> getUserStatistics() async {
    final request = ++_statisticsRequest;
    try {
      final result = await usersApi.getStatistics();
      if (_disposed || request != _statisticsRequest) {
        return CtrlResponse(success: true);
      }
      userStatistics = result;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> deleteUserById(String id) async {
    try {
      await usersApi.deleteUserById(id);
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> updateUser(
    String uid,
    String? username,
    String? displayName,
    String? password,
    AppRole newRole,
  ) async {
    try {
      await usersApi.updateUserById(
        uid,
        username,
        displayName,
        password,
        newRole,
      );
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> updateStatus(String uid, bool active) async {
    try {
      await usersApi.updateStatus(uid, active);
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> insertNormalUser(
    String username,
    String displayName,
    String password,
    AppRole role,
  ) async {
    try {
      await usersApi.createUser(username, displayName, password, role);
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    paging.dispose();
    super.dispose();
  }
}
