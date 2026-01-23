import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';

class TimeLineChart extends StatelessWidget {
  final List<TimeStatValue> values;

  const TimeLineChart({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
            color: Theme.of(context).colorScheme.primary,
            spots: values.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.value.toDouble(),
              );
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
