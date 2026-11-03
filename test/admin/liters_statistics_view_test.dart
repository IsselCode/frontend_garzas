import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/src/admin/clean/entities/flow_meter_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/flow_meter_controller.dart';
import 'package:frontend_garzas/src/admin/data/flow_meter_api.dart';
import 'package:frontend_garzas/src/admin/views/liters_statistics_view.dart';
import 'package:provider/provider.dart';
import '../support/admin_fixture_client.dart';

void main() {
  testWidgets(
    'liter metric cards round display to two decimals without altering source readings',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = FlowMeterController(flowMeterApi: _FlowApi());
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const MaterialApp(home: LitersStatisticsView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('12,345.68'), findsOneWidget);
      expect(find.text('9,000.13'), findsOneWidget);
      expect(find.text('3,345.55'), findsOneWidget);
      expect(find.text('8,000.00'), findsOneWidget);
      expect(controller.currentMonth!.metrics.meteredLiters, 12345.6789);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );
}

class _FlowApi extends FlowMeterApi {
  _FlowApi() : super(apiClient: AdminFixtureClient());
  @override
  Future<FlowMeterRange> getDailyRange({
    required DateTime from,
    required DateTime to,
    String groupBy = 'day',
  }) async => FlowMeterRange(
    from: from,
    to: to,
    soldLiters: 8000,
    groupBy: groupBy,
    days: const [],
    summaries: const [
      FlowMeterSummary(
        garzaNumber: 1,
        garzaTitle: 'Garza 1',
        meteredLiters: 12345.6789,
        registeredLiters: 9000.1267,
        unregisteredLiters: 3345.5522,
        firstReadAt: null,
        lastReadAt: null,
      ),
    ],
  );
}
