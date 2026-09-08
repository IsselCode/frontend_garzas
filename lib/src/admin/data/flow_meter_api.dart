import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/flow_meter_entity.dart';

class FlowMeterApi {
  final ApiClient apiClient;

  FlowMeterApi({required this.apiClient});

  static const _dailyRangePath = '/flow-meter/daily/range';

  Future<FlowMeterRange> getDailyRange({
    required DateTime from,
    required DateTime to,
    String groupBy = 'day',
  }) async {
    try {
      final response = await apiClient.get(
        _dailyRangePath,
        authRequired: true,
        queryParams: {
          'from': _formatDate(from),
          'to': _formatDate(to),
          'group_by': groupBy,
        },
      );

      return FlowMeterRange.fromMap((response as Map).cast<String, dynamic>());
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
