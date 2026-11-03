import '../../commons/entities/page_result.dart';
import '../errors/exceptions.dart';
import 'api_client.dart';

class PaginatedApi {
  const PaginatedApi._();

  static Future<PageResult<T>> get<T>(
    ApiClient client,
    String path,
    T Function(Map<String, dynamic>) decode, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      final response = await client.get(
        path,
        authRequired: true,
        queryParams: {...filters, 'page': page, 'limit': limit},
      );
      return PageResult.fromMap(
        Map<String, dynamic>.from(response as Map),
        decode,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(message: 'No se pudo leer el listado: $error');
    }
  }

  /// Operational callers that need a complete selection (e.g. bulk payments)
  /// explicitly traverse every page, independently of the admin table's page.
  static Future<List<T>> all<T>(
    Future<PageResult<T>> Function(int) fetch,
  ) async {
    final items = <T>[];
    var page = 1;
    while (true) {
      final result = await fetch(page);
      items.addAll(result.items);
      if (result.items.isEmpty || page >= result.totalPages) return items;
      page++;
    }
  }
}
