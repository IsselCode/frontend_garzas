import 'admin_fixture_client.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';

class UsersFixtureClient extends AdminFixtureClient {
  final users = List.generate(
    45,
    (index) => <String, dynamic>{
      'uid': 'user-$index',
      'username': 'usuario${index.toString().padLeft(2, '0')}',
      'display_name': 'Usuario $index',
      'role': ['admin', 'seller', 'dispatch', 'sales_dispatch'][index % 4],
      'is_active': index % 3 != 0,
      'created_at': '2026-11-01T12:00:00Z',
    },
  );
  final userQueries = <Map<String, dynamic>>[];
  int statisticsRequests = 0;
  bool rejectUserUpdates = false;
  final pageCounts = <String, int>{};
  final failedListPaths = <String>{};

  @override
  Future<dynamic> get(
    String path, {
    bool authRequired = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    if (failedListPaths.contains(path)) {
      throw AppException(message: 'No se pudo consultar el listado');
    }
    if (path.startsWith('/cash-register/') && path.endsWith('/summary')) {
      return [
        {
          'payment_method': 'cash',
          'water_type': 'potable',
          'total_liters': 2600.0,
          'total_amount': 1300.0,
          'sales_count': 26,
        },
      ];
    }
    if (pageCounts.containsKey(path)) {
      final query = Map<String, dynamic>.of(queryParams ?? {});
      final page = query['page'] as int? ?? 1,
          limit = query['limit'] as int? ?? 20;
      Map<String, dynamic> template;
      if (path == '/sales' ||
          path == '/sales/range' ||
          path == '/logs' ||
          path == '/logs/range') {
        final first =
            await super.get(
                  path,
                  queryParams: {...query, 'page': 1, 'limit': 1},
                )
                as Map;
        template = Map<String, dynamic>.from(
          (first['items'] as List).first as Map,
        );
      } else {
        requests.add(path);
        if (path == '/cash-register' || path == '/cash-register/range') {
          template = {
            'id': 1,
            'opened_by_uid': 'admin',
            'opened_by_username': 'Administrador',
            'opening_amount': 100.0,
            'opened_at': '2026-11-02T12:00:00Z',
            'closed_at': '2026-11-02T18:00:00Z',
            'closed_by_username': 'Administrador',
            'status': 'closed',
            'cash_total': 1300.0,
            'card_total': 0.0,
            'credit_total': 0.0,
          };
        } else if (path.startsWith('/cash-register/')) {
          template = {
            'folio': 'V-1',
            'water_type': 'potable',
            'unit_of_measurement': 'liters',
            'quantity': 100.0,
            'payment_method': 'cash',
            'total': 50.0,
          };
        } else if (path.endsWith('/credit-payments')) {
          template = {
            'sale_folio': 'CR-1',
            'client_id': 7,
            'commercial_name': 'Cliente de prueba',
            'cash_cut_id': 1,
            'received_by_uid': 'admin',
            'received_by_username': 'Administrador',
            'payment_method': 'cash',
            'amount': 10.0,
            'created_at': '2026-11-02T12:00:00Z',
          };
        } else if (path == '/sales/credit/pending') {
          template = {
            'sale_folio': 'CR-1',
            'client_id': 7,
            'commercial_name': 'Cliente de prueba',
            'total': 1000.0,
            'amount_paid': 260.0,
            'sale_pending_amount': 740.0,
            'created_at': '2026-11-02T12:00:00Z',
          };
        } else if (path == '/pending-dispatches') {
          template = {
            'id': 1,
            'plate_or_unit_reference': 'ABC-1',
            'garza_number': 1,
            'water_type': 'potable',
            'unit_of_measurement': 'liters',
            'quantity': 100.0,
            'status': query['status'] ?? 'pending_payment',
            'created_at': '2026-11-02T12:00:00Z',
            'updated_at': '2026-11-02T13:00:00Z',
          };
        } else {
          throw AppException(message: 'Sin listado de prueba para $path');
        }
      }
      queries[path] = query;
      final total = pageCounts[path]!;
      final all = List.generate(
        total,
        (index) => {
          ...template,
          'id': index + 1,
          if (template.containsKey('folio')) 'folio': 'V-${index + 1}',
          if (path == '/sales/credit/pending') 'sale_folio': 'CR-${index + 1}',
        },
      );
      return {
        'items': all.skip((page - 1) * limit).take(limit).toList(),
        'page': page,
        'limit': limit,
        'total': total,
        'total_pages': (total / limit).ceil(),
      };
    }
    if (path == '/users') {
      requests.add(path);
      userQueries.add(Map.of(queryParams ?? {}));
      final name = (queryParams?['name'] as String?)?.toLowerCase();
      final matches = users
          .where(
            (user) =>
                (name == null ||
                    '${user['username']} ${user['display_name']}'
                        .toLowerCase()
                        .contains(name)) &&
                (queryParams?['role'] == null ||
                    user['role'] == queryParams!['role']) &&
                (queryParams?['is_active'] == null ||
                    user['is_active'] == queryParams!['is_active']),
          )
          .toList();
      final page = queryParams?['page'] as int? ?? 1,
          limit = queryParams?['limit'] as int? ?? 20;
      return {
        'items': matches.skip((page - 1) * limit).take(limit).toList(),
        'page': page,
        'limit': limit,
        'total': matches.length,
        'total_pages': (matches.length / limit).ceil(),
      };
    }
    if (path == '/statistics/users') {
      statisticsRequests++;
      return {
        'active_users': users.where((user) => user['is_active'] == true).length,
        'administrators': users.where((user) => user['role'] == 'admin').length,
        'sellers': users.where((user) => user['role'] == 'seller').length,
        'dispatchers': users.where((user) => user['role'] == 'dispatch').length,
        'sales_dispatchers': users
            .where((user) => user['role'] == 'sales_dispatch')
            .length,
      };
    }
    return super.get(
      path,
      authRequired: authRequired,
      headers: headers,
      queryParams: queryParams,
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    if (path != '/users') {
      throw AppException(message: 'Ruta no esperada: $path');
    }
    final user = <String, dynamic>{
      ...body!,
      'uid': 'user-new-${users.length}',
      'is_active': true,
      'created_at': '2026-11-02T12:00:00Z',
    }..remove('password');
    users.add(user);
    return user;
  }

  @override
  Future<dynamic> patch(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    if (path.startsWith('/users/')) {
      if (rejectUserUpdates) {
        throw AppException(message: 'No se puede modificar este usuario');
      }
      final user = users.firstWhere((user) => path == '/users/${user['uid']}');
      user.addAll(body!);
      user.remove('password');
      return user;
    }
    return super.patch(
      path,
      authRequired: authRequired,
      body: body,
      headers: headers,
      queryParams: queryParams,
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    users.removeWhere((user) => path == '/users/${user['uid']}');
    return null;
  }
}
