import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/src/admin/clean/enums/credit_status.dart';
import 'package:frontend_garzas/src/admin/controllers/credits_controller.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';

// Run the local Postman simulation, then:
// flutter test --dart-define=CREDITS_SIMULATION_URL=http://localhost:14010/backend/api/v1 test/admin/credits_api_simulation_test.dart
const _baseUrl = String.fromEnvironment('CREDITS_SIMULATION_URL');

void main() {
  test(
    'real HTTP credit filters, pagination, literal search and error recovery',
    () async {
      final server = ServerStatusController();
      final client = ApiClient(serverStatusController: server)
        ..baseUrl = _baseUrl
        ..configureAuth(
          accessTokenProvider: () async => 'local-synthetic-token',
        );
      final api = SalesApi(apiClient: client);
      final controller = CreditsController(salesApi: api);
      addTearDown(controller.dispose);
      addTearDown(server.dispose);

      final initial = await controller.resetFilters();
      expect(initial.success, isTrue, reason: initial.message);
      expect(controller.paging.data.total, 25);
      expect(
        controller.showedCredits.every(
          (credit) => credit.salePendingAmount > 0,
        ),
        isTrue,
      );

      expect(
        (await controller.filterCredits(status: CreditStatus.paid)).success,
        isTrue,
      );
      expect(controller.paging.data.total, 20);
      expect(
        controller.showedCredits.every(
          (credit) => credit.salePendingAmount == 0,
        ),
        isTrue,
      );

      expect(
        (await controller.filterCredits(
          status: CreditStatus.all,
          search: '  Rancho   ',
          startDate: DateTime(2026, 11, 1),
          endDate: DateTime(2026, 11, 3),
          updateDates: true,
        )).success,
        isTrue,
      );
      expect(controller.paging.data.total, 44);
      expect(controller.paging.data.totalPages, 3);
      await controller.getCredits(page: 2);
      expect(controller.paging.data.page, 2);
      expect(controller.showedCredits.first.saleFolio, 'CRED-021');
      expect(controller.showedCredits.last.saleFolio, 'CRED-040');
      expect(
        controller.showedCredits.any((credit) => credit.salePendingAmount == 0),
        isTrue,
      );
      expect(
        controller.showedCredits.any((credit) => credit.salePendingAmount > 0),
        isTrue,
      );

      await controller.filterCredits(search: r'  Peña  %_\ Norte ');
      expect(controller.paging.data.page, 1);
      expect(controller.paging.data.total, 1);
      expect(controller.showedCredits.single.commercialName, r'Peña %_\ Norte');

      final failed = await controller.filterCredits(search: 'FALLAR');
      expect(failed.success, isFalse);
      expect(failed.message, 'No se pudieron consultar los créditos');
      expect(controller.search, r'Peña %_\ Norte');
      expect(controller.showedCredits, hasLength(1));
      await controller.getCredits();
      expect(controller.paging.error, isNull);

      await controller.filterCredits(search: 'Sin coincidencias');
      expect(controller.showedCredits, isEmpty);
      expect(controller.paging.data.totalPages, 0);
      await controller.filterCredits(search: '  ');
      expect(controller.paging.data.total, 45);
      final invalid = await controller.filterCredits(search: 'x' * 46);
      expect(invalid.success, isFalse);
      expect(controller.search, '');
    },
    skip: _baseUrl.isEmpty
        ? 'Requires the local Postman credits simulation'
        : false,
  );
}
