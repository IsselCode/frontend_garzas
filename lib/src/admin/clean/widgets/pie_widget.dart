import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/src/admin/clean/entities/cash_register_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/summary_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/select_payment_method_widget.dart';
import '../../../../core/app/consts.dart';
import 'indicator_widget.dart';

class PieChartSample2 extends StatefulWidget {
  final CashRegisterEntity cut;
  final List<SummaryEntity> summaries;

  const PieChartSample2({
    super.key,
    required this.cut,
    required this.summaries,
  });

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  PaymentMethod paymentMethod = PaymentMethod.cash;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final chartSize = _chartSizeForWidth(screenWidth);
    final centerSpaceRadius = chartSize * 0.2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 30,
      children: [
        Container(
          width: chartSize,
          height: chartSize,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: centerSpaceRadius,
              sections: showingSections(chartSize),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectPaymentMethodWidget(
                    color: Colors.green.withAlpha(60),
                    image: AppAssets.cash,
                    selected: paymentMethod == PaymentMethod.cash,
                    onTap: () {
                      paymentMethod = PaymentMethod.cash;
                      pageController.animateToPage(
                        0,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.bounceInOut,
                      );
                      setState(() {});
                    },
                  ),
                  SelectPaymentMethodWidget(
                    image: AppAssets.card,
                    color: Colors.blue.withAlpha(60),
                    selected: paymentMethod == PaymentMethod.card,
                    onTap: () {
                      paymentMethod = PaymentMethod.card;
                      pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.bounceInOut,
                      );
                      setState(() {});
                    },
                  ),
                  SelectPaymentMethodWidget(
                    color: colorScheme.onSurface.withAlpha(60),
                    splashColor: Colors.white,
                    image: AppAssets.check,
                    selected: paymentMethod == PaymentMethod.check,
                    onTap: () {
                      paymentMethod = PaymentMethod.check;
                      pageController.animateToPage(
                        2,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.bounceInOut,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 144,
                width: double.infinity,
                child: PageView(
                  controller: pageController,
                  children: [
                    Indicator(
                      potableLiters: widget.summaries
                          .where((element) => element.value == 1)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      potableGallons: widget.summaries
                          .where((element) => element.value == 2)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      pozoLiters: widget.summaries
                          .where((element) => element.value == 3)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      pozoGallons: widget.summaries
                          .where((element) => element.value == 4)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                    ),
                    Indicator(
                      potableLiters: widget.summaries
                          .where((element) => element.value == 5)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      potableGallons: widget.summaries
                          .where((element) => element.value == 6)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      pozoLiters: widget.summaries
                          .where((element) => element.value == 7)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      pozoGallons: widget.summaries
                          .where((element) => element.value == 8)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                    ),
                    Indicator(
                      potableLiters: widget.summaries
                          .where((element) => element.value == 9)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      potableGallons: widget.summaries
                          .where((element) => element.value == 10)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      pozoLiters: widget.summaries
                          .where((element) => element.value == 11)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                      pozoGallons: widget.summaries
                          .where((element) => element.value == 12)
                          .map((e) => e.totalAmount)
                          .firstWhere((element) => true, orElse: () => 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _chartSizeForWidth(double width) {
    if (width >= 1800) return 440;
    if (width >= 1500) return 340;
    if (width >= 1200) return 240;
    return 280;
  }

  List<PieChartSectionData> showingSections(double chartSize) {
    final baseRadius = chartSize * 0.25;
    final touchedRadius = chartSize * 0.285;
    final baseFontSize = chartSize * 0.057;
    final touchedFontSize = chartSize * 0.089;

    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? touchedFontSize : baseFontSize;
      final radius = isTouched ? touchedRadius : baseRadius;
      const shadows = [Shadow(color: Colors.black, blurRadius: 8)];
      return switch (i) {
        0 => PieChartSectionData(
          color: Colors.green,
          value: widget.cut.cashTotal,
          title: "\$${widget.cut.cashTotal.toStringAsFixed(2)}",
          radius: radius,
          badgePositionPercentageOffset: 1.1,
          titlePositionPercentageOffset: 0.4,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        ),
        1 => PieChartSectionData(
          color: Colors.blue,
          value: widget.cut.cardTotal,
          title: "\$${widget.cut.cardTotal.toStringAsFixed(2)}",
          radius: radius,
          badgePositionPercentageOffset: 1.1,
          titlePositionPercentageOffset: 0.4,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        ),
        2 => PieChartSectionData(
          color: Colors.white,
          value: widget.cut.checkTotal,
          title: "\$${widget.cut.checkTotal.toStringAsFixed(2)}",
          radius: radius,
          badgePositionPercentageOffset: 1.1,
          titlePositionPercentageOffset: 0.4,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        ),
        _ => throw StateError('Invalid'),
      };
    });
  }
}