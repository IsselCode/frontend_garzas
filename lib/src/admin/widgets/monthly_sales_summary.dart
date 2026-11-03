import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/src/admin/clean/entities/monthly_garza_total_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/statistic_garza_container.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/statistic_garza_container_2.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import 'monthly_sales_cards.dart';

class MonthlySalesSummary extends StatelessWidget {
  const MonthlySalesSummary({
    super.key,
    required this.loadStatistics,
    required this.loadGarzaTotals,
    required this.month,
    required this.pageController,
    required this.mode,
    required this.onModeChanged,
    required this.canViewPreviousMonth,
    required this.showingPreviousMonth,
    required this.onToggleMonth,
    this.horizontal = false,
  });
  final Future<CtrlResponse> loadStatistics;
  final Future<CtrlResponse> loadGarzaTotals;
  final DateTime month;
  final PageController pageController;
  final TabSwitcherAlignStates mode;
  final ValueChanged<TabSwitcherAlignStates> onModeChanged;
  final bool canViewPreviousMonth;
  final bool showingPreviousMonth;
  final VoidCallback onToggleMonth;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final statistics = context.watch<StatisticsController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    if (horizontal) return _buildHorizontal(context, statistics);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: IsselTabSwitcher(
                state: mode,
                leftText: 'Método',
                rightText: 'Garzas',
                onChanged: onModeChanged,
              ),
            ),
            IsselPill(
              text: DateFormat('MMMM', 'es').format(month),
              color: colorScheme.surface,
            ),
          ],
        ),
        Expanded(
          child: SizedBox(
            width: 300,
            child: Column(
              spacing: 10,
              children: [
                Expanded(
                  child: PageView(
                    controller: pageController,
                    children: [
                      //* Estadisticas por método
                      FutureBuilder(
                        future: loadStatistics,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                              ],
                            );
                          }

                          if (!snapshot.data!.success) {
                            return Center(child: Text(snapshot.data!.message!));
                          }

                          return Column(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: StatisticGarzaContainer(
                                  asset: AppAssets.cash,
                                  title: "Efectivo",
                                  total: statistics.statistics!.cashTotal,
                                  liters: statistics.statistics!.cashLiters,
                                ),
                              ),
                              Expanded(
                                child: StatisticGarzaContainer(
                                  asset: AppAssets.card,
                                  title: "Tarjeta",
                                  total: statistics.statistics!.cardTotal,
                                  liters: statistics.statistics!.cardLiters,
                                ),
                              ),
                              Expanded(
                                child: StatisticGarzaContainer(
                                  asset: AppAssets.credit,
                                  title: "Credito",
                                  total: statistics.statistics!.creditTotal,
                                  liters: statistics.statistics!.creditLiters,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      //* Estadisticas por garza
                      FutureBuilder(
                        future: loadGarzaTotals,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                                Expanded(
                                  child: IsselShimmer(width: 300, height: 150),
                                ),
                              ],
                            );
                          }

                          if (!snapshot.data!.success) {
                            return Center(child: Text(snapshot.data!.message!));
                          }

                          return Column(
                            spacing: 10,
                            children: [
                              Text(
                                "Solo apareceran las estadisticas de las garzas que despacharon agua.",
                                style: textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              ...List.generate(4, (index) {
                                final garzaNumber = index + 1;
                                final garza = _findGarzaTotal(
                                  statistics,
                                  garzaNumber,
                                );

                                return Expanded(
                                  child: StatisticGarzaContainer_2(
                                    asset: AppAssets.waterTank,
                                    title:
                                        garza?.garzaTitle ??
                                        "Garza $garzaNumber",
                                    total: garza?.totalAmount ?? 0,
                                    expectedTotal: garza?.expectedAmount ?? 0,
                                    liters: garza?.totalLiters ?? 0,
                                    expectedLiters: garza?.expectedLiters ?? 0,
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (canViewPreviousMonth)
                  IsselButton(
                    height: 50,
                    text: showingPreviousMonth
                        ? "Ver mes actual"
                        : "Ver mes anterior",
                    onTap: onToggleMonth,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    StatisticsController statistics,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final methodColumns = constraints.maxWidth >= 840
              ? 3
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          final garzaColumns = constraints.maxWidth >= 1160
              ? 4
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          final textScale = MediaQuery.textScalerOf(context).scale(22) / 22;
          final methodHeight = 164.0 * textScale;
          final garzaHeight = 188.0 * textScale;
          final height = mode == TabSwitcherAlignStates.left
              ? (3 / methodColumns).ceil() * methodHeight +
                    ((3 / methodColumns).ceil() - 1) * 12
              : (4 / garzaColumns).ceil() * garzaHeight +
                    ((4 / garzaColumns).ceil() - 1) * 12;

          Widget grid(List<Widget> cards, int columns, double cardHeight) =>
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width:
                          (constraints.maxWidth - (columns - 1) * 12) / columns,
                      height: cardHeight,
                      child: card,
                    ),
                ],
              );

          Widget page(Future<CtrlResponse> future, Widget Function() content) =>
              FutureBuilder<CtrlResponse>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return IsselShimmer(width: double.infinity, height: height);
                  }
                  if (snapshot.data?.success != true) {
                    return Center(
                      child: Text(
                        snapshot.data?.message ??
                            'No hay estadísticas disponibles',
                      ),
                    );
                  }
                  return content();
                },
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _buildHorizontalHeader(context, constraints.maxWidth),
              SizedBox(
                height: height,
                child: PageView(
                  controller: pageController,
                  children: [
                    page(loadStatistics, () {
                      final data = statistics.statistics;
                      if (data == null) {
                        return const Center(
                          child: Text('No hay estadísticas disponibles'),
                        );
                      }
                      return grid(
                        [
                          MonthlyPaymentCard(
                            icon: Icons.payments_outlined,
                            title: 'Efectivo',
                            total: data.cashTotal,
                            liters: data.cashLiters,
                          ),
                          MonthlyPaymentCard(
                            icon: Icons.credit_card_outlined,
                            title: 'Tarjeta',
                            total: data.cardTotal,
                            liters: data.cardLiters,
                          ),
                          MonthlyPaymentCard(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Crédito',
                            total: data.creditTotal,
                            liters: data.creditLiters,
                          ),
                        ],
                        methodColumns,
                        methodHeight,
                      );
                    }),
                    page(
                      loadGarzaTotals,
                      () => grid(
                        [
                          for (var number = 1; number <= 4; number++)
                            MonthlyGarzaCard(
                              title:
                                  _findGarzaTotal(
                                    statistics,
                                    number,
                                  )?.garzaTitle ??
                                  'Garza $number',
                              total:
                                  _findGarzaTotal(
                                    statistics,
                                    number,
                                  )?.totalAmount ??
                                  0,
                              expectedTotal:
                                  _findGarzaTotal(
                                    statistics,
                                    number,
                                  )?.expectedAmount ??
                                  0,
                              liters:
                                  _findGarzaTotal(
                                    statistics,
                                    number,
                                  )?.totalLiters ??
                                  0,
                              expectedLiters:
                                  _findGarzaTotal(
                                    statistics,
                                    number,
                                  )?.expectedLiters ??
                                  0,
                            ),
                        ],
                        garzaColumns,
                        garzaHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalHeader(BuildContext context, double width) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(22) / 22;
    final stackControls = width < 520 * textScale;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text('Resumen mensual', style: theme.textTheme.titleMedium),
        Text(
          DateFormat('MMMM yyyy', 'es').format(month),
          style: theme.textTheme.labelLarge?.copyWith(color: colors.outline),
        ),
      ],
    );
    final selector = IsselTabSwitcher(
      state: mode,
      height: 44 * textScale,
      color: colors.surfaceContainer,
      leftText: 'Método',
      rightText: 'Garzas',
      onChanged: onModeChanged,
    );
    final monthButton = IsselButton(
      width: stackControls ? width : 212 * textScale,
      height: 44 * textScale,
      color: colors.surfaceContainer,
      textColor: colors.primary,
      text: showingPreviousMonth ? 'Ver mes actual' : 'Ver mes anterior',
      onTap: onToggleMonth,
    );

    if (width >= 900 * textScale) {
      return Row(
        spacing: 12,
        children: [
          Expanded(child: heading),
          SizedBox(width: 280 * textScale, child: selector),
          if (canViewPreviousMonth) monthButton,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Row(
          spacing: 16,
          children: [
            Expanded(child: heading),
            if (canViewPreviousMonth && !stackControls) monthButton,
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: stackControls ? width : 280 * textScale,
            child: selector,
          ),
        ),
        if (canViewPreviousMonth && stackControls) monthButton,
      ],
    );
  }

  GarzaTotalEntity? _findGarzaTotal(
    StatisticsController statistics,
    int garzaNumber,
  ) {
    final totals =
        statistics.monthlyGarzaTotalEntity?.totals ??
        const <GarzaTotalEntity>[];

    for (final total in totals) {
      if (total.garzaNumber == garzaNumber) {
        return total;
      }
    }

    return null;
  }
}
