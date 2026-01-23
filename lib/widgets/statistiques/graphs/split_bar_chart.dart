import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';

class SplitBarChart extends StatelessWidget {
  final List<StatValue> values;

  const SplitBarChart({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    double currentY = 0;

    return BarChart(
      BarChartData(
        maxY: 100,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: values.map((v) {
              final rod = BarChartRodData(
                fromY: currentY,
                toY: currentY + v.value.toDouble(),
                width: 20,
                color: v.color != null ? fromHex(v.color!) : Colors.grey,
              );
              currentY += v.value.toDouble();
              return rod;
            }).toList(),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
