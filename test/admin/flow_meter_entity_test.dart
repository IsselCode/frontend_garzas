import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/src/admin/clean/entities/flow_meter_entity.dart';

void main() {
  test('parses monthly flow meter ranges', () {
    final range = FlowMeterRange.fromMap({
      'from': '2025-10-01',
      'to': '2026-09-06',
      'sold_liters': 95,
      'group_by': 'month',
      'months': [
        {
          'month': '2025-10',
          'sold_liters': 95,
          'summaries': [
            {
              'garza_number': 1,
              'garza_title': 'Garza 1',
              'metered_liters': 120.5,
              'registered_liters': 100,
              'unregistered_liters': 20.5,
            },
          ],
        },
      ],
    });

    expect(range.months, hasLength(1));
    expect(range.months.single.month, DateTime(2025, 10));
    expect(range.chartDays.single.day, DateTime(2025, 10));
    expect(range.chartDays.single.soldLiters, 95);
    expect(range.metrics.meteredLiters, 120.5);
    expect(range.metrics.soldLiters, 95);
  });

  test(
    'parses sold liters at day level independently from garza summaries',
    () {
      final range = FlowMeterRange.fromMap({
        'from': '2026-09-01',
        'to': '2026-09-01',
        'sold_liters': 100,
        'group_by': 'day',
        'days': [
          {
            'day': '2026-09-01',
            'sold_liters': 100,
            'summaries': [
              {
                'garza_number': 1,
                'garza_title': 'Garza 1',
                'metered_liters': 60,
                'registered_liters': 60,
                'unregistered_liters': 0,
              },
              {
                'garza_number': 2,
                'garza_title': 'Garza 2',
                'metered_liters': 40,
                'registered_liters': 40,
                'unregistered_liters': 0,
              },
            ],
          },
        ],
      });

      expect(range.metrics.soldLiters, 100);
      expect(range.chartDays.single.metrics.soldLiters, 100);
      expect(range.chartDays.single.metrics.meteredLiters, 100);
    },
  );
}
