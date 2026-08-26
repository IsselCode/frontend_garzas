class DateRangeQuery {
  const DateRangeQuery._();

  /// Builds an inclusive local calendar-day range for APIs that use an
  /// exclusive end (`start_at <= date < end_at`).
  static Map<String, String> fromDates({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day + 1);

    return {'start_at': _withTimeZone(start), 'end_at': _withTimeZone(end)};
  }

  static String _withTimeZone(DateTime date) {
    final offset = date.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absoluteOffset = offset.abs();
    final hours = absoluteOffset.inHours.toString().padLeft(2, '0');
    final minutes = (absoluteOffset.inMinutes % 60).toString().padLeft(2, '0');
    final datePart =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}T'
        '${date.hour.toString().padLeft(2, '0')}:00:00';

    return '$datePart$sign$hours:$minutes';
  }
}
