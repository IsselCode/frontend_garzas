import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:frontend_garzas/src/admin/clean/entities/flow_meter_entity.dart';
import 'package:frontend_garzas/src/admin/controllers/flow_meter_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class _FlowMeterDescriptions {
  static const metered =
      'Litros detectados por el medidor durante el periodo. '
      'Se calcula sumando los incrementos entre lecturas consecutivas.';
  static const registered =
      'Litros medidos mientras exist\u00EDa una sesi\u00F3n de despacho asociada. '
      'Indica que el flujo estaba vinculado a un despacho, pero no garantiza '
      'que la venta haya terminado correctamente.';
  static const unregistered =
      'Litros medidos cuando no exist\u00EDa una sesi\u00F3n de despacho asociada. '
      'Pueden corresponder a flujo manual, consumo externo o una lectura sin '
      'vinculaci\u00F3n.';
  static const sold =
      'Los litros vendidos son el total de las ventas del periodo filtrado, convertido a litros y sin dividir por garza.';
}

enum _GarzaFilter { all, garza1, garza2, garza3, garza4 }

extension on _GarzaFilter {
  int? get number => switch (this) {
    _GarzaFilter.all => null,
    _GarzaFilter.garza1 => 1,
    _GarzaFilter.garza2 => 2,
    _GarzaFilter.garza3 => 3,
    _GarzaFilter.garza4 => 4,
  };
}

class LitersStatisticsView extends StatefulWidget {
  const LitersStatisticsView({super.key});

  @override
  State<LitersStatisticsView> createState() => _LitersStatisticsViewState();
}

class _LitersStatisticsViewState extends State<LitersStatisticsView> {
  late Future<CtrlResponse> _loadCurrentMonth;
  late Future<CtrlResponse> _loadChart;
  FlowMeterPeriod _selectedPeriod = FlowMeterPeriod.currentMonth;
  _GarzaFilter _selectedGarza = _GarzaFilter.all;

  @override
  void initState() {
    super.initState();
    final controller = context.read<FlowMeterController>();
    _loadCurrentMonth = controller.loadInitial();
    _loadChart = _loadCurrentMonth;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlowMeterController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: kWindowCaptionHeight + 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            const TextBackButton(),
            Expanded(
              child: FutureBuilder<CtrlResponse>(
                future: _loadCurrentMonth,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return IsselShimmer(
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }

                  final response = snapshot.data;
                  if (response == null || !response.success) {
                    return _ErrorMessage(
                      message:
                          response?.message ??
                          "No se pudieron cargar las estad\u00EDsticas",
                    );
                  }

                  final currentMonth = controller.currentMonth;
                  if (currentMonth == null) {
                    return const _ErrorMessage(
                      message: "No hay datos disponibles",
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      _MetricsWrap(metrics: currentMonth.metrics),
                      Expanded(child: _buildChartPanel(controller, theme)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPanel(FlowMeterController controller, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                _selectedPeriod.groupsByMonth
                    ? "Desglose mensual"
                    : "Desglose diario",
                style: theme.textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GarzaDropdown(
                    value: _selectedGarza,
                    onChanged: (garza) {
                      if (garza == null || garza == _selectedGarza) return;
                      setState(() => _selectedGarza = garza);
                    },
                  ),
                  _PeriodDropdown(
                    value: _selectedPeriod,
                    onChanged: (period) {
                      if (period == null || period == _selectedPeriod) return;
                      setState(() {
                        _selectedPeriod = period;
                        _loadChart = controller.loadPeriod(period);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const _ChartLegend(),
          Expanded(
            child: FutureBuilder<CtrlResponse>(
              future: _loadChart,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return IsselShimmer(
                    width: double.infinity,
                    height: double.infinity,
                  );
                }

                final response = snapshot.data;
                if (response == null || !response.success) {
                  return _ErrorMessage(
                    message:
                        response?.message ??
                        "No se pudieron cargar los datos del periodo",
                  );
                }

                final data = controller.chartData;
                if (data == null || data.chartDays.isEmpty) {
                  return const _ErrorMessage(
                    message: "No hay datos para el periodo seleccionado",
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LineChart(_buildLineChartData(data, colorScheme)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(
    FlowMeterRange data,
    ColorScheme colorScheme,
  ) {
    final days = List<FlowMeterDay>.of(data.chartDays)
      ..sort((a, b) => a.day.compareTo(b.day));
    final garzaNumber = _selectedGarza.number;
    final points = days.map((day) {
      final summaries = garzaNumber == null
          ? day.summaries
          : day.summaries.where(
              (summary) => summary.garzaNumber == garzaNumber,
            );
      return FlowMeterMetrics.fromSummaries(
        summaries,
        soldLiters: day.soldLiters,
      );
    }).toList();
    final allValues = points.expand(
      (metrics) => [
        metrics.meteredLiters,
        metrics.registeredLiters,
        metrics.unregisteredLiters,
        metrics.soldLiters,
      ],
    );
    final minValue = allValues.reduce(math.min);
    final maxValue = allValues.reduce(math.max);
    final minY = math.min(0, minValue).toDouble();
    final maxY = math.max(1, maxValue * 1.15).toDouble();
    final interval = ((maxY - minY) / 4).clamp(0.5, double.infinity).toDouble();
    final maxX = math.max(1, days.length - 1).toDouble();

    LineChartBarData line({
      required Color color,
      required double Function(FlowMeterMetrics) value,
      bool showArea = false,
      List<Color>? gradientColors,
    }) {
      return LineChartBarData(
        spots: [
          for (var index = 0; index < points.length; index++)
            FlSpot(index.toDouble(), value(points[index])),
        ],
        isCurved: true,
        gradient: LinearGradient(
          colors: gradientColors ?? [color.withAlpha(210), color],
        ),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: showArea,
          gradient: LinearGradient(
            colors: [color.withAlpha(45), color.withAlpha(0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    final isDark = colorScheme.brightness == Brightness.dark;
    final chartBackground = colorScheme.surface;
    final gridColor = colorScheme.outlineVariant.withAlpha(isDark ? 120 : 160);
    final axisLabelColor = colorScheme.onSurfaceVariant;
    final tooltipTextColor = colorScheme.onSurface;
    final labelStep = math.max(1, (days.length / 6).ceil());
    const fieldNames = [
      'Litros medidos',
      'Litros registrados',
      'Litros no registrados',
      'Litros vendidos',
    ];

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      backgroundColor: chartBackground,
      gridData: FlGridData(
        show: true,
        horizontalInterval: interval,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: gridColor, strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: gridColor, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 ||
                  index >= days.length ||
                  (index % labelStep != 0 && index != days.length - 1)) {
                return const SizedBox.shrink();
              }

              return SideTitleWidget(
                meta: meta,
                child: Text(
                  DateFormat(
                    _selectedPeriod.groupsByMonth ? 'MM/yy' : 'dd/MM',
                  ).format(days[index].day),
                  style: TextStyle(fontSize: 10, color: axisLabelColor),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            interval: interval,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
              child: Text(
                _formatYAxisValue(value),
                style: TextStyle(fontSize: 10, color: axisLabelColor),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: (barData, indicators) => indicators.map((
          index,
        ) {
          final lineColor =
              barData.gradient?.colors.first ?? barData.color ?? Colors.white;
          return TouchedSpotIndicatorData(
            FlLine(color: colorScheme.primary.withAlpha(160), strokeWidth: 1),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
                color: lineColor,
                strokeColor: colorScheme.surface,
                strokeWidth: 2,
              ),
            ),
          );
        }).toList(),
        touchTooltipData: LineTouchTooltipData(
          maxContentWidth: 360,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (spot) => colorScheme.surfaceContainerHighest,
          getTooltipItems: (spots) => spots.asMap().entries.map((entry) {
            final spot = entry.value;
            final day = days[spot.spotIndex].day;
            final fieldName = fieldNames[spot.barIndex];
            final date = entry.key == 0
                ? '${DateFormat(_selectedPeriod.groupsByMonth ? 'MM/yy' : 'dd-MM-yy').format(day)}\n'
                : '';
            return LineTooltipItem(
              '$date$fieldName: ${_formatAxisValue(spot.y)} L',
              TextStyle(
                color: tooltipTextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        line(
          color: colorScheme.primary,
          value: (metrics) => metrics.meteredLiters,
          showArea: true,
          gradientColors: const [Color(0xff27d3ff), Color(0xff19d39c)],
        ),
        line(
          color: Colors.green,
          value: (metrics) => metrics.registeredLiters,
          gradientColors: const [Color(0xff79e38c), Color(0xff20c997)],
        ),
        line(
          color: Colors.orange,
          value: (metrics) => metrics.unregisteredLiters,
          gradientColors: const [Color(0xffffc46b), Color(0xffff8a3d)],
        ),
        line(
          color: Colors.purple,
          value: (metrics) => metrics.soldLiters,
          gradientColors: const [Color(0xffd19aff), Color(0xff9b5de5)],
        ),
      ],
    );
  }

  String _formatAxisValue(double value) {
    return _formatNumberWithCommas(value);
  }

  String _formatYAxisValue(double value) {
    return _formatNumberWithCommas(value.roundToDouble());
  }
}

String _formatNumberWithCommas(double value) {
  if (!value.isFinite) return value.toString();

  final rawValue = value.toString();
  final negative = rawValue.startsWith('-');
  final unsignedValue = negative ? rawValue.substring(1) : rawValue;
  final parts = unsignedValue.split('.');
  final integerPart = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

  return '${negative ? '-' : ''}$integerPart$decimalPart';
}

class _MetricsWrap extends StatelessWidget {
  final FlowMeterMetrics metrics;

  const _MetricsWrap({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = <Widget>[
      _MetricCard(
        label: "Litros medidos",
        value: metrics.meteredLiters,
        icon: Icons.water_drop_outlined,
        color: colorScheme.primary,
        description: _FlowMeterDescriptions.metered,
      ),
      _MetricCard(
        label: "Litros registrados",
        value: metrics.registeredLiters,
        icon: Icons.fact_check_outlined,
        color: Colors.green,
        description: _FlowMeterDescriptions.registered,
      ),
      _MetricCard(
        label: "Litros no registrados",
        value: metrics.unregisteredLiters,
        icon: Icons.warning_amber_outlined,
        color: Colors.orange,
        description: _FlowMeterDescriptions.unregistered,
      ),
      _MetricCard(
        label: "Litros vendidos",
        value: metrics.soldLiters,
        icon: Icons.local_shipping_outlined,
        color: Colors.purple,
        description: _FlowMeterDescriptions.sold,
      ),
    ];

    return SizedBox(
      height: 108,
      child: Row(
        spacing: 10,
        children: [for (final card in cards) Expanded(child: card)],
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String description;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _descriptionOverlay;
  bool _isHovered = false;

  void _showDescriptionOverlay(double cardWidth) {
    if (_descriptionOverlay != null || !mounted) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    _descriptionOverlay = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: 1,
            heightFactor: 1,
            child: _MetricDescriptionOverlay(
              width: cardWidth,
              label: widget.label,
              description: widget.description,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
    overlay.insert(_descriptionOverlay!);
  }

  void _hideDescriptionOverlay() {
    _descriptionOverlay?.remove();
    _descriptionOverlay = null;
  }

  @override
  void dispose() {
    _hideDescriptionOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: 108,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _showDescriptionOverlay(constraints.maxWidth);
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hideDescriptionOverlay();
            },
            child: CompositedTransformTarget(
              link: _layerLink,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.color.withAlpha(18)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.color.withAlpha(_isHovered ? 180 : 70),
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withAlpha(45),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(widget.icon, color: widget.color, size: 20),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatNumberWithCommas(widget.value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricDescriptionOverlay extends StatelessWidget {
  final double width;
  final String label;
  final String description;
  final Color color;

  const _MetricDescriptionOverlay({
    required this.width,
    required this.label,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100),
        child: SizedBox(
          width: math.min(width, 310.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(245), color.withAlpha(205)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha(90)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(45),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GarzaDropdown extends StatelessWidget {
  final _GarzaFilter value;
  final ValueChanged<_GarzaFilter?> onChanged;

  const _GarzaDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_GarzaFilter>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(
              value: _GarzaFilter.all,
              child: Text("Todas las garzas"),
            ),
            DropdownMenuItem(
              value: _GarzaFilter.garza1,
              child: Text("Garza 1"),
            ),
            DropdownMenuItem(
              value: _GarzaFilter.garza2,
              child: Text("Garza 2"),
            ),
            DropdownMenuItem(
              value: _GarzaFilter.garza3,
              child: Text("Garza 3"),
            ),
            DropdownMenuItem(
              value: _GarzaFilter.garza4,
              child: Text("Garza 4"),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final FlowMeterPeriod value;
  final ValueChanged<FlowMeterPeriod?> onChanged;

  const _PeriodDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FlowMeterPeriod>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(
              value: FlowMeterPeriod.week,
              child: Text("Semana"),
            ),
            DropdownMenuItem(
              value: FlowMeterPeriod.currentMonth,
              child: Text("Mes actual"),
            ),
            DropdownMenuItem(
              value: FlowMeterPeriod.previousMonth,
              child: Text("\u00DAltimo mes"),
            ),
            DropdownMenuItem(
              value: FlowMeterPeriod.last12Months,
              child: Text("Últimos 12 meses"),
            ),
            DropdownMenuItem(
              value: FlowMeterPeriod.currentYear,
              child: Text("Año actual"),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: const [
        _LegendItem(label: "Medidos", color: Color(0xff27d3ff)),
        _LegendItem(label: "Registrados", color: Colors.green),
        _LegendItem(label: "No registrados", color: Colors.orange),
        _LegendItem(label: "Vendidos", color: Colors.purple),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IsselPill(
        text: message,
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
    );
  }
}
