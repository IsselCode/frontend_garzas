import 'package:frontend_garzas/commons/entities/user_entity.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';

class UsersApi {
  final ApiClient apiClient;

  UsersApi({required this.apiClient});

  final String _getUsersPath = "/users";
  final String _createUserPath = "/users";
  final String _deleteUserByIdPath = "/users";
  final String _updateUserByIdPath = "/users";

  Future<List<UserEntity>> listUsers(String? queryUsers) async {

    List response = await apiClient.get(
      _getUsersPath,
      authRequired: true,
      queryParams: queryUsers == null || queryUsers.trim().isEmpty ? null : {'name': queryUsers.trim()},
    ) as List;

    return response.map((e) => UserEntity.fromMap(e),).toList();

  }

  Future<UserEntity> createUser(String username, String displayName, String password, AppRole role) async {

    Map<String, dynamic> body = {
      "username": username,
      "display_name": displayName,
      "password": password,
      "role": role.name
    };

    Map<String, dynamic> response = await apiClient.post(
      _createUserPath,
      authRequired: true,
      body: body
    );

    return UserEntity.fromMap(response);
  }

  Future<void> deleteUserById(String uid) async {

    await apiClient.delete(
      "$_deleteUserByIdPath/$uid",
      authRequired: true
    );

  }

  Future<UserEntity> updateUserById(String uid, String? username, String? displayName, String? password, AppRole newRole) async {

    final data = {
      "username": username,
      "display_name": displayName,
      "password": password,
      "role": newRole.name,
    };

    data.removeWhere((key, value) => value == null || value.isEmpty);

    Map<String, dynamic> response = await apiClient.patch(
      "$_updateUserByIdPath/$uid",
      authRequired: true,
      body: data,
    );

    return UserEntity.fromMap(response);

  }


}
