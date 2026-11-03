import 'package:flutter/material.dart';
import 'liters_statistics_view.dart';
import '../widgets/monthly_sales_overview.dart';

/// The dashboard composes the existing liter and monthly sales summaries.
class HomeAdminView extends StatelessWidget {
  const HomeAdminView({super.key});

  @override
  Widget build(BuildContext context) =>
      const LitersStatisticsView(footer: MonthlySalesOverview());
}
