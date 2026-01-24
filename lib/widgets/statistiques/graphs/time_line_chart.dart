import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class TimeLineChart extends StatefulWidget {
  final List<TimeStatValue> values;

  const TimeLineChart({
    super.key,
    required this.values,
  });

  @override
  State<TimeLineChart> createState() => _TimeLineChartState();
}

class _TimeLineChartState extends State<TimeLineChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndex = touchedIndex ?? widget.values.length - 1;
    final selected = widget.values[selectedIndex];

    final previous =
        selectedIndex > 0 ? widget.values[selectedIndex - 1] : null;

    final delta = previous != null ? selected.value - previous.value : null;

    final deltaColor = delta == null
        ? ColorPalette.textSecondary(context)
        : delta > 0
            ? ColorPalette.success(context)
            : delta < 0
                ? ColorPalette.error(context)
                : ColorPalette.textSecondary(context);

    String monthLabel = _monthLabel(selected.period.month, false);

    monthLabel = _displayYear(
        values: widget.values,
        label: monthLabel,
        index: selectedIndex,
        short: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$monthLabel : ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.textPrimary(context),
                ),
              ),
              Text(
                '${selected.value}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textAccent(context),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'matchs regardés',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorPalette.textAccent(context),
                ),
              ),
              const SizedBox(width: 6),
              if (delta != null)
                Text(
                  delta > 0 ? '+$delta' : '$delta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: deltaColor,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // 🔹 Graphique
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= widget.values.length) {
                          return const SizedBox.shrink();
                        }

                        final date = widget.values[index].period;
                        String label = _monthLabel(date.month, true);

                        label = _displayYear(
                          values: widget.values,
                          label: label,
                          index: index,
                          short: true,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorPalette.textPrimary(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  distanceCalculator: (touch, spot) {
                    final dx = touch.dx - spot.dx;
                    final dy = touch.dy - spot.dy;
                    return sqrt(dx * dx + dy * dy) * 0.3;
                  },
                  enabled: false,
                  touchCallback: (event, response) {
                    if (response?.lineBarSpots == null) return;
                    setState(() {
                      touchedIndex = response!.lineBarSpots!.first.spotIndex;
                    });
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: ColorPalette.accent(context),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isSelected = index == selectedIndex;
                        final value = widget.values[index].value;

                        return MatchCountDotPainter(
                          isSelected: isSelected,
                          value: value,
                          color: ColorPalette.accent(context),
                          textColor: ColorPalette.textAccent(context),
                        );
                      },
                    ),
                    spots: widget.values.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.value.toDouble(),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(int month, bool short) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    const shortMonths = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return short ? shortMonths[month - 1] : months[month - 1];
  }

  String _displayYear({
    required List<TimeStatValue> values,
    required String label,
    required int index,
    required bool short,
  }) {
    if (values.isEmpty) return label;

    final firstYear = values.first.period.year;
    for (final value in values) {
      if (value.period.year != firstYear) {
        return short
            ? '$label ${values[index].period.year.toString().substring(2)}'
            : '$label ${values[index].period.year}';
      }
    }
    return label;
  }
}

class MatchCountDotPainter extends FlDotPainter {
  final bool isSelected;
  final num value;
  final Color color;
  final Color textColor;

  MatchCountDotPainter({
    required this.isSelected,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  void draw(
    Canvas canvas,
    FlSpot spot,
    Offset offsetInCanvas,
  ) {
    final dotRadius = isSelected ? 7.0 : 5.0;

    final paint = Paint()..color = color;
    canvas.drawCircle(offsetInCanvas, dotRadius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      offsetInCanvas.dx - textPainter.width / 2,
      offsetInCanvas.dy - dotRadius - textPainter.height - 4,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  Size getSize(FlSpot spot) => const Size(40, 28);

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return t < 0.5 ? a : b;
  }

  @override
  Color get mainColor => color;

  @override
  List<Object?> get props => [isSelected, value, color, textColor];
}
