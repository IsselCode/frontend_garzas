import 'package:flutter/foundation.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/flow_meter_entity.dart';
import 'package:frontend_garzas/src/admin/data/flow_meter_api.dart';

enum FlowMeterPeriod {
  week,
  currentMonth,
  previousMonth,
  last12Months,
  currentYear,
}

extension FlowMeterPeriodX on FlowMeterPeriod {
  bool get groupsByMonth => switch (this) {
    FlowMeterPeriod.last12Months || FlowMeterPeriod.currentYear => true,
    _ => false,
  };
}

class FlowMeterController extends ChangeNotifier {
  final FlowMeterApi flowMeterApi;

  FlowMeterController({required this.flowMeterApi});

  FlowMeterRange? currentMonth;
  FlowMeterRange? currentMonthChartData;
  FlowMeterRange? chartData;
  int _requestId = 0;

  Future<CtrlResponse> loadInitial() async {
    final requestId = ++_requestId;
    try {
      final range = _periodRange(FlowMeterPeriod.currentMonth);
      final data = await Future.wait([
        flowMeterApi.getDailyRange(
          from: range.$1,
          to: range.$2,
          groupBy: 'total',
        ),
        flowMeterApi.getDailyRange(from: range.$1, to: range.$2),
      ]);

      if (requestId == _requestId) {
        currentMonth = data[0];
        currentMonthChartData = data[1];
        chartData = data[1];
        notifyListeners();
      }

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> loadPeriod(FlowMeterPeriod period) async {
    final requestId = ++_requestId;
    if (period == FlowMeterPeriod.currentMonth &&
        currentMonthChartData != null) {
      chartData = currentMonthChartData;
      notifyListeners();
      return CtrlResponse(success: true);
    }

    try {
      final range = _periodRange(period);
      final data = await flowMeterApi.getDailyRange(
        from: range.$1,
        to: range.$2,
        groupBy: period.groupsByMonth ? 'month' : 'day',
      );

      if (requestId == _requestId) {
        chartData = data;
        notifyListeners();
      }

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  (DateTime, DateTime) _periodRange(FlowMeterPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case FlowMeterPeriod.week:
        return (today.subtract(const Duration(days: 6)), today);
      case FlowMeterPeriod.currentMonth:
        return (DateTime(today.year, today.month), today);
      case FlowMeterPeriod.previousMonth:
        final monthStart = DateTime(today.year, today.month - 1);
        final monthEnd = DateTime(today.year, today.month, 0);
        return (monthStart, monthEnd);
      case FlowMeterPeriod.last12Months:
        return (DateTime(today.year, today.month - 11), today);
      case FlowMeterPeriod.currentYear:
        return (DateTime(today.year), today);
    }
  }
}
