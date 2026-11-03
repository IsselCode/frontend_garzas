class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  const PageResult.empty({this.limit = 20})
    : items = const [],
      page = 1,
      total = 0,
      totalPages = 0;

  final List<T> items;
  final int page, limit, total, totalPages;

  factory PageResult.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) decode,
  ) => PageResult(
    items: (map['items'] as List)
        .map((item) => decode(Map<String, dynamic>.from(item as Map)))
        .toList(),
    page: (map['page'] as num).toInt(),
    limit: (map['limit'] as num).toInt(),
    total: (map['total'] as num).toInt(),
    totalPages: (map['total_pages'] as num).toInt(),
  );
}
