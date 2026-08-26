import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/utils/date_range_query.dart';

void main() {
  test('sends local day boundaries with the local UTC offset', () {
    final query = DateRangeQuery.fromDates(
      startDate: DateTime(2026, 8, 25, 15, 30),
      endDate: DateTime(2026, 8, 25, 18, 45),
    );
    final offset = DateTime(2026, 8, 25).timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absoluteOffset = offset.abs();
    final zone =
        '$sign${absoluteOffset.inHours.toString().padLeft(2, '0')}:'
        '${(absoluteOffset.inMinutes % 60).toString().padLeft(2, '0')}';

    expect(query['start_at'], '2026-08-25T00:00:00$zone');
    expect(query['end_at'], '2026-08-26T00:00:00$zone');
    expect(query.containsKey('start_date'), isFalse);
    expect(query.containsKey('end_date'), isFalse);
  });
}
