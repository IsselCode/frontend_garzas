import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/src/admin/clean/enums/credit_status.dart';
import 'package:frontend_garzas/src/admin/controllers/credits_controller.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';

void main() {
  test(
    'filter changes reset paging, clear details and retain combined filters',
    () async {
      final client = _Client();
      final controller = CreditsController(
        salesApi: SalesApi(apiClient: client),
      );
      addTearDown(controller.dispose);
      await controller.getCredits(page: 2);
      await controller.loadCreditPayments(controller.showedCredits.first);
      expect(controller.selectedCredit, isNotNull);
      await controller.filterCredits(
        status: CreditStatus.all,
        search: ' Rancho   Norte ',
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 3),
        updateDates: true,
      );
      expect(controller.selectedCredit, isNull);
      expect(controller.creditPayments, isEmpty);
      expect(controller.paging.data.page, 1);
      await controller.getCredits(page: 2);
      expect(client.queries.last, containsPair('status', 'all'));
      expect(client.queries.last, containsPair('search', 'Rancho Norte'));
      expect(client.queries.last, containsPair('page', 2));
      expect(
        DateTime.parse(client.queries.last['start_at']).toLocal(),
        DateTime(2026, 11, 1),
      );
      expect(
        DateTime.parse(client.queries.last['end_at']).toLocal(),
        DateTime(2026, 11, 4),
      );
      await controller.clearSalesDateRange();
      expect(client.queries.last, isNot(contains('start_at')));
      expect(client.queries.last, containsPair('search', 'Rancho Norte'));
      expect(client.queries.last, containsPair('status', 'all'));
      await controller.filterCredits(search: '  ');
      expect(client.queries.last, isNot(contains('search')));
      await controller.resetFilters();
      expect(client.queries.last['status'], 'pending');
    },
  );

  test(
    'late failed filters cannot roll back a newer successful query',
    () async {
      final client = _Client();
      final controller = CreditsController(
        salesApi: SalesApi(apiClient: client),
      );
      addTearDown(controller.dispose);
      await controller.getCredits();
      final delayed = Completer<dynamic>();
      client.next = delayed;
      final oldRequest = controller.filterCredits(search: 'viejo');
      await Future<void>.delayed(Duration.zero);
      await controller.filterCredits(
        status: CreditStatus.paid,
        search: 'nuevo',
      );
      delayed.completeError(AppException(message: 'Error anterior'));
      await oldRequest;
      expect(controller.search, 'nuevo');
      expect(controller.status, CreditStatus.paid);
      expect(controller.paging.error, isNull);
      client.fail = true;
      final failure = await controller.filterCredits(
        status: CreditStatus.all,
        search: 'fallido',
      );
      expect(failure.success, isFalse);
      expect(controller.status, CreditStatus.paid);
      expect(controller.search, 'nuevo');
      client.fail = false;
      await controller.getCredits();
      expect(client.queries.last, containsPair('search', 'nuevo'));
    },
  );
}

class _Client extends ApiClient {
  _Client() : super(serverStatusController: ServerStatusController());
  final queries = <Map<String, dynamic>>[];
  Completer<dynamic>? next;
  bool fail = false;

  @override
  Future<dynamic> get(
    String path, {
    bool authRequired = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    queries.add(Map.of(queryParams ?? {}));
    final delayed = next;
    next = null;
    if (delayed != null) return delayed.future;
    if (fail) throw AppException(message: 'Error actual');
    final payments = path.endsWith('/credit-payments');
    return {
      'items': [
        if (!payments)
          {
            'sale_folio': 'CR-1',
            'client_id': 1,
            'commercial_name': 'Rancho',
            'total': 1000.0,
            'amount_paid': 400.0,
            'sale_pending_amount': 600.0,
            'created_at': '2026-11-02T10:00:00Z',
          },
      ],
      'page': queryParams?['page'] ?? 1,
      'limit': 20,
      'total': payments ? 0 : 40,
      'total_pages': payments ? 0 : 2,
    };
  }
}
