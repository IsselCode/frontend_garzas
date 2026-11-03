import 'package:frontend_garzas/commons/entities/user_entity.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import '../../../commons/entities/page_result.dart';
import '../../../core/services/paginated_api.dart';
import '../clean/entities/user_statistics.dart';

class UsersApi {
  final ApiClient apiClient;

  UsersApi({required this.apiClient});

  final String _getUsersPath = "/users";
  final String _createUserPath = "/users";
  final String _deleteUserByIdPath = "/users";
  final String _updateUserByIdPath = "/users";

  Future<PageResult<UserEntity>> listPage({
    int page = 1,
    int limit = 20,
    String? name,
    AppRole? role,
    bool? isActive,
  }) => PaginatedApi.get(
    apiClient,
    _getUsersPath,
    UserEntity.fromMap,
    page: page,
    limit: limit,
    filters: {
      if (name?.trim().isNotEmpty ?? false) 'name': name!.trim(),
      if (role != null) 'role': role.wireName,
      'is_active': ?isActive,
    },
  );

  Future<UserStatistics> getStatistics() async => UserStatistics.fromMap(
    Map<String, dynamic>.from(
      await apiClient.get('/statistics/users', authRequired: true) as Map,
    ),
  );

  Future<UserEntity> updateStatus(String uid, bool active) async =>
      UserEntity.fromMap(
        Map<String, dynamic>.from(
          await apiClient.patch(
                '/users/$uid',
                body: {'is_active': active},
                authRequired: true,
              )
              as Map,
        ),
      );

  Future<List<UserEntity>> listUsers(String? queryUsers) =>
      PaginatedApi.all((page) => listPage(page: page, name: queryUsers));

  Future<UserEntity> createUser(
    String username,
    String displayName,
    String password,
    AppRole role,
  ) async {
    Map<String, dynamic> body = {
      "username": username,
      "display_name": displayName,
      "password": password,
      "role": role.wireName,
    };

    Map<String, dynamic> response = await apiClient.post(
      _createUserPath,
      authRequired: true,
      body: body,
    );

    return UserEntity.fromMap(response);
  }

  Future<void> deleteUserById(String uid) async {
    await apiClient.delete("$_deleteUserByIdPath/$uid", authRequired: true);
  }

  Future<UserEntity> updateUserById(
    String uid,
    String? username,
    String? displayName,
    String? password,
    AppRole newRole,
  ) async {
    final data = {
      "username": username,
      "display_name": displayName,
      "password": password,
      "role": newRole.wireName,
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
