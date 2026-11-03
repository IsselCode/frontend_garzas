import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/paginated_api.dart';
import 'package:frontend_garzas/commons/entities/page_result.dart';
import 'package:frontend_garzas/core/utils/date_range_query.dart';
import '../clean/entities/log_entity.dart';

class LogsApi {
  LogsApi({required this.apiClient});
  final ApiClient apiClient;

  Future<PageResult<LogEntity>> listPage({
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final ranged = startDate != null && endDate != null;
    return PaginatedApi.get(
      apiClient,
      ranged ? '/logs/range' : '/logs',
      LogEntity.fromMap,
      page: page,
      limit: limit,
      filters: ranged
          ? DateRangeQuery.fromDates(startDate: startDate, endDate: endDate)
          : {},
    );
  }

  Future<List<LogEntity>> listLogs() =>
      PaginatedApi.all((page) => listPage(page: page, limit: 200));
  Future<List<LogEntity>> listByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) => PaginatedApi.all(
    (page) => listPage(
      page: page,
      limit: 200,
      startDate: startDate,
      endDate: endDate,
    ),
  );
}
