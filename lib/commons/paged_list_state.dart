import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import 'ctrl_response.dart';
import 'entities/page_result.dart';

/// State shared by paginated lists. Only the latest request can publish data.
class PagedListState<T> {
  PagedListState({required this.onChanged, int limit = 20})
    : data = PageResult.empty(limit: limit);
  final VoidCallback onChanged;
  PageResult<T> data;
  bool loading = false;
  String? error;
  int requestedPage = 1;
  int _revision = 0;
  bool _disposed = false;
  List<T> get items => data.items;

  Future<CtrlResponse> load(
    Future<PageResult<T>> Function(int) fetch, {
    int page = 1,
  }) async {
    final revision = ++_revision;
    requestedPage = page;
    loading = true;
    error = null;
    // Loads can start in a descendant's initState.
    await Future<void>.value();
    if (_disposed || revision != _revision) return CtrlResponse(success: true);
    onChanged();
    try {
      var result = await fetch(page);
      final lastPage = result.totalPages == 0 ? 1 : result.totalPages;
      if (page > lastPage && !_disposed && revision == _revision) {
        requestedPage = lastPage;
        result = await fetch(lastPage);
      }
      if (_disposed || revision != _revision) {
        return CtrlResponse(success: true);
      }
      data = result;
      return CtrlResponse(success: true);
    } on AppException catch (failure) {
      if (_disposed || revision != _revision) {
        return CtrlResponse(success: true);
      }
      error = failure.message;
      return CtrlResponse(success: false, message: failure.message);
    } finally {
      if (!_disposed && revision == _revision) {
        loading = false;
        onChanged();
      }
    }
  }

  void replace(PageResult<T> result) {
    _revision++;
    data = result;
    requestedPage = result.page;
    loading = false;
    error = null;
    onChanged();
  }

  void dispose() {
    _disposed = true;
    _revision++;
  }
}
