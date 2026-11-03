import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';

/// In-memory responses for exercising the real admin controllers and views.
class AdminFixtureClient extends ApiClient {
  AdminFixtureClient()
    : super(serverStatusController: ServerStatusController());

  final requests = <String>[];
  final queries = <String, Map<String, dynamic>?>{};
  final configUpdates = <Map<String, dynamic>>[];
  bool failConfigUpdates = false;
  final generalConfig = <String, dynamic>{
    'water_supply': true,
    'user_created': true,
    'user_deleted': true,
    'user_modified': true,
    'login': true,
    'logout': true,
    'client_created': true,
    'client_deleted': true,
    'client_modified': true,
    'cash_register_opening': true,
    'cash_register_closing': true,
    'sale_created': true,
    'sale_credit_limit_rejected': true,
    'dispatch_completed': true,
    'business_name': 'Purificadora de prueba',
    'business_address': 'Dirección de prueba',
    'extra_info_1': 'Gracias por su compra',
    'extra_info_2': 'Vuelva pronto',
    'potable_liter_pricing': .5,
    'potable_gal_pricing': 2.0,
    'pozo_liter_pricing': .3,
    'pozo_gal_pricing': 1.2,
    'plc_endpoint': '192.168.0.20:502',
    'print_qnty': 2,
  };

  @override
  Future<dynamic> get(
    String path, {
    bool authRequired = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    Map<String, dynamic> pageItems(List<dynamic> items) {
      final page = (queryParams?['page'] as num?)?.toInt() ?? 1;
      final limit = (queryParams?['limit'] as num?)?.toInt() ?? 20;
      return {
        'items': items.skip((page - 1) * limit).take(limit).toList(),
        'page': page,
        'limit': limit,
        'total': items.length,
        'total_pages': (items.length / limit).ceil(),
      };
    }

    requests.add(path);
    queries[path] = queryParams;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month).toIso8601String();
    final monthEnd = DateTime(now.year, now.month + 1).toIso8601String();
    switch (path) {
      case '/flow-meter/daily/range':
        final summary = {
          'garza_number': 1,
          'garza_title': 'Garza 1',
          'metered_liters': 12345678.9,
          'registered_liters': 10000000.0,
          'unregistered_liters': 2345678.9,
        };
        return {
          'from': queryParams?['from'],
          'to': queryParams?['to'],
          'group_by': queryParams?['group_by'],
          'sold_liters': 8000000.0,
          'summaries': [summary],
          'days': [
            {
              'day': queryParams?['to'],
              'sold_liters': 8000000.0,
              'summaries': [summary],
            },
          ],
        };
      case '/settings/general':
        return Map<String, dynamic>.of(generalConfig);
      case '/sales':
      case '/sales/range':
        return pageItems([
          {
            'id': 1,
            'folio': 'V-001',
            'dispatch_code': 'D-001',
            'cash_cut_id': 1,
            'seller_uid': 'seller',
            'seller_username': 'Operador',
            'client_id': null,
            'commercial_name': 'Cliente de revisión',
            'water_type': 'potable',
            'unit_of_measurement': 'liters',
            'quantity': 10000.0,
            'unit_price': 0.5,
            'total': 5000.0,
            'payment_method': 'cash',
            'amount_paid': 5000.0,
            'change_amount': 0.0,
            'is_dispatched': true,
            'created_at': now.toIso8601String(),
            'pending_amount': 0.0,
            'is_paid': true,
            'paid_at': null,
            'paid_by_uid': null,
            'paid_by_username': null,
            'total_liters': 10000.0,
            'dispatched_liters': 10000.0,
            'remaining_liters': 0.0,
            'dispatch_duration_ms': 120000,
            'customer_employee_name': null,
            'dispatch_status': 'completed',
          },
        ]);
      case '/sales/monthly-payment-totals':
        return {
          'month_start': monthStart,
          'month_end': monthEnd,
          'cash_total': 5000.0,
          'cash_liters': 10000.0,
          'card_total': 2400.0,
          'card_liters': 4800.0,
          'credit_total': 1500.0,
          'credit_liters': 3000.0,
        };
      case '/sales/monthly-garza-totals':
        return {
          'month_start': monthStart,
          'month_end': monthEnd,
          'summaries': [
            {
              'garza_number': 1,
              'garza_title': 'Garza 1',
              'total_amount': 8900.0,
              'expected_amount': 8900.0,
              'total_liters': 17800.0,
              'expected_liters': 17800.0,
              'sales_count': 3,
            },
          ],
        };
      case '/logs':
      case '/logs/range':
        return pageItems([
          {
            'id': 1,
            'user_uid': 'admin',
            'username': 'Administrador',
            'display_name': 'Administrador',
            'role': 'admin',
            'tipo': 'Inicio de sesión',
            'info': 'Acceso al sistema',
            'status_code': 200,
            'duration_ms': 5.0,
            'created_at': now.toIso8601String(),
          },
        ]);
      default:
        throw AppException(message: 'Sin datos de prueba para $path');
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    if (path != '/settings/general') {
      throw AppException(message: 'Sin datos de prueba para $path');
    }
    configUpdates.add(Map.of(body!));
    if (failConfigUpdates) {
      throw AppException(message: 'No se pudo guardar la configuración');
    }
    generalConfig.addAll(body);
    return Map<String, dynamic>.of(generalConfig);
  }
}
