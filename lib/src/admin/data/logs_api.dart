import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/log_entity.dart';

class LogsApi {
  final ApiClient apiClient;

  LogsApi({required this.apiClient});

  final String _logsPath = "/logs";
  final String _logsByDateRangePath = "/logs/range";

  Future<List<LogEntity>> listLogs() async {

    try {
      List response = await apiClient.get(
        _logsPath,
        authRequired: true,
      );

      return response.map((e) => LogEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }

  Future<List<LogEntity>> listByDateRange(DateTime startDate, DateTime endDate) async {

    String start = startDate.toIso8601String().split("T").first;
    String end = endDate.toIso8601String().split("T").first;

    try {
      List response = await apiClient.get(
        _logsByDateRangePath,
        authRequired: true,
        queryParams: {"start_date": start, "end_date": end}
      );

      return response.map((e) => LogEntity.fromMap(e),).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }

  }


}
