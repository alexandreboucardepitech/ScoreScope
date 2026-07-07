import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class TimeLineChart extends StatefulWidget {
  final List<TimeStatValue> values;

  // Affiche ou non le bandeau "Mois : X matchs regardés (+delta)" en haut.
  // Par défaut à true pour ne rien changer à l'usage existant (onglet
  // stats).
  final bool showHeader;

  // Version resserrée : police plus petite, trait plus fin, et un label de
  // mois sur trois (on garde toujours le premier et le dernier). Toutes les
  // valeurs restent affichées dans les deux modes — seule la taille change.
  // Pensé pour un affichage sur une portion de largeur (ex: 2/3 d'une carte)
  // plutôt que pleine largeur. Déclaratif plutôt que mesuré au runtime, pour
  // rester compatible avec IntrinsicHeight côté appelant.
  final bool compact;

  const TimeLineChart({
    super.key,
    required this.values,
    this.showHeader = true,
    this.compact = false,
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
      short: false,
    );

    final compact = widget.compact;
    final monthLabelFontSize = compact ? 9.0 : 10.0;
    final dotValueFontSize = compact ? 11.0 : 18.0;
    final selectedDotRadius = compact ? 5.0 : 7.0;
    final normalDotRadius = compact ? 3.5 : 5.0;
    final barWidth = compact ? 2.0 : 3.0;
    final labelInterval = compact ? 3 : 1;

    // Marge de respiration au-dessus du point le plus haut : sans ça, le
    // pic touche le bord supérieur du graphique (et son étiquette de valeur,
    // dessinée au-dessus du point, peut être coupée).
    final maxValue = widget.values
        .map((v) => v.value)
        .fold<num>(0, (a, b) => a > b ? a : b);
    final chartMaxY = maxValue <= 0 ? 1.0 : maxValue.toDouble() * 1.25;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showHeader) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    translate.matchsRegardes,
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
            ),
            const SizedBox(height: 24),
          ] else
            // Marge de respiration en haut quand le bandeau est masqué,
            // pour que le point le plus haut ne touche pas le bord.
            SizedBox(height: compact ? 14 : 20),

          // 🔹 Graphique
          SizedBox(
            height: compact ? 110 : 140,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: chartMaxY,
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

                        final isFirstOrLast =
                            index == 0 || index == widget.values.length - 1;
                        if (labelInterval > 1 &&
                            index % labelInterval != 0 &&
                            !isFirstOrLast) {
                          return const SizedBox.shrink();
                        }

                        final date = widget.values[index].period;
                        String label = _monthLabel(date.month, true);

                        label = _displayYear(
                          values: widget.values,
                          label: label,
                          index: index,
                          short: true,
                          onlyFirstMonth: true,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: monthLabelFontSize,
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
                    barWidth: barWidth,
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
                          fontSize: dotValueFontSize,
                          selectedRadius: selectedDotRadius,
                          normalRadius: normalDotRadius,
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
    var months = [
      translate.janvier,
      translate.fevrier,
      translate.mars,
      translate.avril,
      translate.mai,
      translate.juin,
      translate.juillet,
      translate.aout,
      translate.septembre,
      translate.octobre,
      translate.novembre,
      translate.decembre,
    ];
    var shortMonths = [
      translate.jan,
      translate.fev,
      translate.mar,
      translate.avr,
      translate.mai,
      translate.juin,
      translate.juillet,
      translate.aout,
      translate.sep,
      translate.oct,
      translate.nov,
      translate.dec,
    ];
    return short ? shortMonths[month - 1] : months[month - 1];
  }

  String _displayYear({
    required List<TimeStatValue> values,
    required String label,
    required int index,
    required bool short,
    bool onlyFirstMonth = false,
  }) {
    if (values.isEmpty) return label;

    final firstYear = values.first.period.year;
    final hasMultipleYears = values.any((v) => v.period.year != firstYear);

    if (!hasMultipleYears) return label;

    if (onlyFirstMonth && values[index].period.month != 1) return label;

    final year = values[index].period.year;
    return short ? '$label ${year.toString().substring(2)}' : '$label $year';
  }
}

class MatchCountDotPainter extends FlDotPainter {
  final bool isSelected;
  final num value;
  final Color color;
  final Color textColor;
  final double fontSize;
  final double selectedRadius;
  final double normalRadius;

  MatchCountDotPainter({
    required this.isSelected,
    required this.value,
    required this.color,
    required this.textColor,
    this.fontSize = 18,
    this.selectedRadius = 7.0,
    this.normalRadius = 5.0,
  });

  @override
  void draw(
    Canvas canvas,
    FlSpot spot,
    Offset offsetInCanvas,
  ) {
    final dotRadius = isSelected ? selectedRadius : normalRadius;

    final paint = Paint()..color = color;
    canvas.drawCircle(offsetInCanvas, dotRadius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          fontSize: isSelected ? fontSize : fontSize * 0.85,
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
  List<Object?> get props => [
        isSelected,
        value,
        color,
        textColor,
        fontSize,
        selectedRadius,
        normalRadius,
      ];
}
