class FlowMeterSummary {
  final int garzaNumber;
  final String garzaTitle;
  final double meteredLiters;
  final double registeredLiters;
  final double unregisteredLiters;
  final DateTime? firstReadAt;
  final DateTime? lastReadAt;

  const FlowMeterSummary({
    required this.garzaNumber,
    required this.garzaTitle,
    required this.meteredLiters,
    required this.registeredLiters,
    required this.unregisteredLiters,
    required this.firstReadAt,
    required this.lastReadAt,
  });

  factory FlowMeterSummary.fromMap(Map<String, dynamic> data) {
    final number = (data['garza_number'] as num?)?.toInt() ?? 0;
    return FlowMeterSummary(
      garzaNumber: number,
      garzaTitle: data['garza_title'] as String? ?? 'Garza $number',
      meteredLiters: _doubleValue(data['metered_liters']),
      registeredLiters: _doubleValue(data['registered_liters']),
      unregisteredLiters: _doubleValue(data['unregistered_liters']),
      firstReadAt: _dateValue(data['first_read_at']),
      lastReadAt: _dateValue(data['last_read_at']),
    );
  }

  static DateTime? _dateValue(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}

double _doubleValue(dynamic value) => value is num ? value.toDouble() : 0;

class FlowMeterDay {
  final DateTime day;
  final double soldLiters;
  final List<FlowMeterSummary> summaries;

  const FlowMeterDay({
    required this.day,
    required this.soldLiters,
    required this.summaries,
  });

  factory FlowMeterDay.fromMap(Map<String, dynamic> data) {
    final summaries = (data['summaries'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (summary) =>
              FlowMeterSummary.fromMap(summary.cast<String, dynamic>()),
        )
        .toList();

    return FlowMeterDay(
      day: DateTime.parse(data['day'] as String),
      soldLiters: _doubleValue(data['sold_liters']),
      summaries: summaries,
    );
  }

  FlowMeterMetrics get metrics =>
      FlowMeterMetrics.fromSummaries(summaries, soldLiters: soldLiters);
}

class FlowMeterMonth {
  final DateTime month;
  final double soldLiters;
  final List<FlowMeterSummary> summaries;

  const FlowMeterMonth({
    required this.month,
    required this.soldLiters,
    required this.summaries,
  });

  factory FlowMeterMonth.fromMap(Map<String, dynamic> data) {
    final value = data['month'] as String?;
    final match = value == null
        ? null
        : RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw const FormatException('Invalid flow meter month');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) {
      throw const FormatException('Invalid flow meter month');
    }

    final summaries = (data['summaries'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (summary) =>
              FlowMeterSummary.fromMap(summary.cast<String, dynamic>()),
        )
        .toList();

    return FlowMeterMonth(
      month: DateTime(year, month),
      soldLiters: _doubleValue(data['sold_liters']),
      summaries: summaries,
    );
  }

  FlowMeterMetrics get metrics =>
      FlowMeterMetrics.fromSummaries(summaries, soldLiters: soldLiters);
}

class FlowMeterRange {
  final DateTime from;
  final DateTime to;
  final double soldLiters;
  final String groupBy;
  final List<FlowMeterDay> days;
  final List<FlowMeterMonth> months;
  final List<FlowMeterSummary> summaries;

  const FlowMeterRange({
    required this.from,
    required this.to,
    required this.soldLiters,
    required this.groupBy,
    required this.days,
    this.months = const [],
    required this.summaries,
  });

  factory FlowMeterRange.fromMap(Map<String, dynamic> data) {
    final days = (data['days'] as List? ?? const [])
        .whereType<Map>()
        .map((day) => FlowMeterDay.fromMap(day.cast<String, dynamic>()))
        .toList();
    final summaries = (data['summaries'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (summary) =>
              FlowMeterSummary.fromMap(summary.cast<String, dynamic>()),
        )
        .toList();
    final months = (data['months'] as List? ?? const [])
        .whereType<Map>()
        .map((month) => FlowMeterMonth.fromMap(month.cast<String, dynamic>()))
        .toList();

    return FlowMeterRange(
      from: DateTime.parse(data['from'] as String),
      to: DateTime.parse(data['to'] as String),
      soldLiters: _doubleValue(data['sold_liters']),
      groupBy: data['group_by'] as String? ?? 'day',
      days: days,
      months: months,
      summaries: summaries,
    );
  }

  List<FlowMeterDay> get chartDays => groupBy == 'month'
      ? [
          for (final month in months)
            FlowMeterDay(
              day: month.month,
              soldLiters: month.soldLiters,
              summaries: month.summaries,
            ),
        ]
      : days;

  FlowMeterMetrics get metrics {
    final rangeSummaries = summaries.isNotEmpty
        ? summaries
        : months.isNotEmpty
        ? months.expand((month) => month.summaries)
        : days.expand((day) => day.summaries);

    return FlowMeterMetrics.fromSummaries(
      rangeSummaries,
      soldLiters: soldLiters,
    );
  }
}

class FlowMeterMetrics {
  final double meteredLiters;
  final double registeredLiters;
  final double unregisteredLiters;
  final double soldLiters;

  const FlowMeterMetrics({
    required this.meteredLiters,
    required this.registeredLiters,
    required this.unregisteredLiters,
    required this.soldLiters,
  });

  factory FlowMeterMetrics.fromSummaries(
    Iterable<FlowMeterSummary> summaries, {
    required double soldLiters,
  }) {
    var metered = 0.0;
    var registered = 0.0;
    var unregistered = 0.0;

    for (final summary in summaries) {
      metered += summary.meteredLiters;
      registered += summary.registeredLiters;
      unregistered += summary.unregisteredLiters;
    }

    return FlowMeterMetrics(
      meteredLiters: metered,
      registeredLiters: registered,
      unregisteredLiters: unregistered,
      soldLiters: soldLiters,
    );
  }
}
