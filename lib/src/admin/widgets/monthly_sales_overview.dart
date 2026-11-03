import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import '../../../commons/ctrl_response.dart';
import '../controllers/statistics_controller.dart';
import 'monthly_sales_summary.dart';

/// Same monthly queries and month switch as the reports sidebar.
class MonthlySalesOverview extends StatefulWidget {
  const MonthlySalesOverview({super.key});

  @override
  State<MonthlySalesOverview> createState() => _MonthlySalesOverviewState();
}

class _MonthlySalesOverviewState extends State<MonthlySalesOverview> {
  final _pages = PageController();
  TabSwitcherAlignStates _mode = TabSwitcherAlignStates.left;
  late DateTime _month;
  late Future<CtrlResponse> _statistics, _garzas;

  bool get _showingPreviousMonth {
    final now = DateTime.now();
    return _month.year != now.year || _month.month != now.month;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  void _load() {
    final controller = context.read<StatisticsController>();
    _statistics = controller.getMonthlyPaymentTotals(month: _month);
    _garzas = controller.getMonthlyGarzaTotals(month: _month);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MonthlySalesSummary(
    horizontal: true,
    loadStatistics: _statistics,
    loadGarzaTotals: _garzas,
    month: _month,
    pageController: _pages,
    mode: _mode,
    onModeChanged: (value) {
      setState(() => _mode = value);
      _pages.animateToPage(
        value == TabSwitcherAlignStates.left ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    },
    canViewPreviousMonth: DateTime.now().day <= 30,
    showingPreviousMonth: _showingPreviousMonth,
    onToggleMonth: () {
      final now = DateTime.now();
      setState(() {
        _month = _showingPreviousMonth
            ? DateTime(now.year, now.month)
            : DateTime(now.year, now.month - 1);
        _load();
      });
    },
  );
}
