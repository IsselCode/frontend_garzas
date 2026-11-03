import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/commons/entities/page_result.dart';
import 'package:frontend_garzas/commons/paged_list_state.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:frontend_garzas/src/admin/data/cash_register_api.dart';
import 'package:frontend_garzas/src/admin/data/logs_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/admin/data/users_api.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';

PageResult<int> _page(int page, List<int> items, {int total = 40}) =>
    PageResult(
      items: items,
      page: page,
      limit: 20,
      total: total,
      totalPages: (total / 20).ceil(),
    );

void main() {
  test('a late response cannot replace the latest requested page', () async {
    final first = Completer<PageResult<int>>(),
        second = Completer<PageResult<int>>();
    final state = PagedListState<int>(onChanged: () {});
    final oldRequest = state.load((_) => first.future);
    await Future<void>.delayed(Duration.zero);
    final newRequest = state.load((_) => second.future, page: 2);
    await Future<void>.delayed(Duration.zero);
    second.complete(_page(2, [21]));
    await newRequest;
    first.complete(_page(1, [1]));
    await oldRequest;
    expect(state.data.page, 2);
    expect(state.items, [21]);
    expect(state.loading, false);
    state.dispose();
  });

  test(
    'deletion or shrinking totals reloads the last available page',
    () async {
      final requests = <int>[];
      final state = PagedListState<int>(onChanged: () {});
      await state.load((page) async {
        requests.add(page);
        return _page(page, page == 2 ? [21] : [], total: 21);
      }, page: 9);
      expect(requests, [9, 2]);
      expect(state.data.page, 2);
      expect(state.items, [21]);
      state.dispose();
    },
  );

  test(
    'a failed page preserves data and remembers which page to retry',
    () async {
      final state = PagedListState<int>(onChanged: () {});
      await state.load((page) async => _page(page, [1]));
      final failure = await state.load(
        (_) async => throw AppException(message: 'Sin conexión'),
        page: 2,
      );
      expect(failure.success, false);
      expect(state.items, [1]);
      expect(state.data.page, 1);
      expect(state.requestedPage, 2);
      expect(state.error, 'Sin conexión');
      await state.load(
        (page) async => _page(page, [21]),
        page: state.requestedPage,
      );
      expect(state.items, [21]);
      expect(state.error, isNull);
      state.dispose();
    },
  );

  test(
    'disposing a pending list prevents later notifications and mutations',
    () async {
      var changes = 0;
      final response = Completer<PageResult<int>>();
      final state = PagedListState<int>(onChanged: () => changes++);
      final pending = state.load((_) => response.future);
      await Future<void>.delayed(Duration.zero);
      state.dispose();
      final before = changes;
      response.complete(_page(1, [1]));
      await pending;
      expect(changes, before);
      expect(state.items, isEmpty);
    },
  );

  test(
    'all paginated endpoints send page, limit and retain server metadata',
    () async {
      final client = _PageClient();
      final sales = SalesApi(apiClient: client),
          cuts = CashRegisterApi(apiClient: client);
      final calls = <(String, Future<PageResult<dynamic>> Function())>[
        ('/sales', () => sales.listSalesPage(page: 2)),
        ('/logs', () => LogsApi(apiClient: client).listPage(page: 2)),
        ('/cash-register', () => cuts.listCutsPage(page: 2)),
        ('/cash-register/9/sales', () => cuts.getSalesPageByCutId(9, page: 2)),
        ('/sales/credit/pending', () => sales.getPendingCreditsPage(page: 2)),
        (
          '/sales/credit/by-client/7',
          () => sales.listPendingCreditSalesByClientPage(7, page: 2),
        ),
        (
          '/sales/V-9/credit-payments',
          () => sales.getCreditPaymentsPage('V-9', page: 2),
        ),
        (
          '/pending-dispatches',
          () => PendingDispatchesApi(apiClient: client).listPage(page: 2),
        ),
        (
          '/users',
          () => UsersApi(apiClient: client).listPage(
            page: 2,
            name: ' Ana ',
            role: AppRole.seller,
            isActive: false,
          ),
        ),
      ];
      for (final (path, fetch) in calls) {
        final result = await fetch();
        expect(client.calls.last.$1, path);
        expect(client.calls.last.$2['page'], 2);
        expect(client.calls.last.$2['limit'], path == '/logs' ? 50 : 20);
        expect(result.page, 2);
        expect(result.total, 88);
        expect(result.totalPages, 5);
      }
      expect(client.calls.last.$2, containsPair('name', 'Ana'));
      expect(client.calls.last.$2, containsPair('role', 'seller'));
      expect(client.calls.last.$2, containsPair('is_active', false));
    },
  );

  test(
    'date filters remain on later pages and include the complete final day',
    () async {
      final client = _PageClient();
      final start = DateTime(2026, 11, 2), end = DateTime(2026, 11, 4);
      await SalesApi(
        apiClient: client,
      ).listSalesPage(page: 3, startDate: start, endDate: end);
      await LogsApi(
        apiClient: client,
      ).listPage(page: 3, startDate: start, endDate: end);
      await CashRegisterApi(
        apiClient: client,
      ).listCutsPage(page: 3, startDate: start, endDate: end);
      await SalesApi(
        apiClient: client,
      ).getPendingCreditsPage(page: 3, startDate: start, endDate: end);
      await PendingDispatchesApi(apiClient: client).listPage(
        page: 3,
        status: 'pending_payment',
        plateOrUnitReference: ' ABC ',
        startDate: start,
        endDate: end,
      );
      expect(client.calls.map((call) => call.$1), [
        '/sales/range',
        '/logs/range',
        '/cash-register/range',
        '/sales/credit/pending',
        '/pending-dispatches',
      ]);
      for (final (_, query) in client.calls) {
        expect(query['page'], 3);
        expect(DateTime.parse(query['start_at'] as String).toLocal(), start);
        expect(
          DateTime.parse(query['end_at'] as String).toLocal(),
          DateTime(2026, 11, 5),
        );
      }
      expect(client.calls.last.$2['status'], 'pending_payment');
      expect(client.calls.last.$2['plate_or_unit_reference'], 'ABC');
    },
  );

  test('bulk payment callers still receive credits from every page', () async {
    final client = _PageClient()..creditCount = 205;
    final credits = await SalesApi(
      apiClient: client,
    ).listPendingCreditSalesByClient(7);
    expect(credits, hasLength(205));
    expect(credits.first.saleFolio, 'V-0');
    expect(credits.last.saleFolio, 'V-204');
    expect(client.calls.map((call) => call.$2['page']), [1, 2, 3]);
    expect(client.calls.every((call) => call.$2['limit'] == 100), true);
  });

  test('invalid list responses surface as a recoverable API failure', () async {
    final client = _PageClient()..bareList = true;
    await expectLater(
      SalesApi(apiClient: client).listSalesPage(),
      throwsA(isA<AppException>()),
    );
  });

  test(
    'failed date changes preserve the previously applied sales and log filters',
    () async {
      final client = _PageClient();
      final controller = StatisticsController(
        logsApi: LogsApi(apiClient: client),
        salesApi: SalesApi(apiClient: client),
      );
      final start = DateTime(2026, 11, 1), end = DateTime(2026, 11, 2);
      await controller.getSalesByDateRange(startDate: start, endDate: end);
      await controller.getLogsByDateRange(startDate: start, endDate: end);
      client.fail = true;
      expect(
        (await controller.getSalesByDateRange(
          startDate: DateTime(2026, 11, 4),
          endDate: DateTime(2026, 11, 5),
        )).success,
        false,
      );
      expect(
        (await controller.getLogsByDateRange(
          startDate: DateTime(2026, 11, 4),
          endDate: DateTime(2026, 11, 5),
        )).success,
        false,
      );
      client.fail = false;
      await controller.getSales(page: 2);
      await controller.getLogs(page: 2);
      for (final (_, query) in client.calls.skip(client.calls.length - 2)) {
        expect(query['page'], 2);
        expect(DateTime.parse(query['start_at'] as String).toLocal(), start);
        expect(
          DateTime.parse(query['end_at'] as String).toLocal(),
          DateTime(2026, 11, 3),
        );
      }
      controller.dispose();
    },
  );
}

class _PageClient extends ApiClient {
  _PageClient() : super(serverStatusController: ServerStatusController());
  final calls = <(String, Map<String, dynamic>)>[];
  bool fail = false, bareList = false;
  int? creditCount;

  @override
  Future<dynamic> get(
    String path, {
    bool authRequired = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    final query = Map<String, dynamic>.of(queryParams ?? {});
    calls.add((path, query));
    if (fail) throw AppException(message: 'Sin conexión');
    if (bareList) return [];
    final page = query['page'] as int, limit = query['limit'] as int;
    final total = creditCount ?? 88;
    final from = ((page - 1) * limit).clamp(0, total),
        to = (page * limit).clamp(0, total);
    return {
      'items': creditCount == null
          ? []
          : List.generate(
              to - from,
              (index) => {
                'sale_folio': 'V-${from + index}',
                'client_id': 7,
                'commercial_name': 'Cliente de prueba',
                'total': 100.0,
                'amount_paid': 10.0,
                'sale_pending_amount': 90.0,
                'created_at': '2026-11-02T12:00:00Z',
              },
            ),
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': creditCount == null ? 5 : (total / limit).ceil(),
    };
  }
}
