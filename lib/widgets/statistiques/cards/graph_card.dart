import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/statistiques/graphs/time_line_chart.dart';
import 'package:scorescope/widgets/statistiques/graphs/pie_stat_graph.dart';
import 'package:scorescope/widgets/statistiques/graphs/split_bar_chart.dart';

class GraphCard extends StatelessWidget {
  final String title;
  final GraphType type;
  final dynamic values;
  final bool pourcentage;

  const GraphCard({
    super.key,
    required this.title,
    required this.type,
    required this.values,
    this.pourcentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _GraphRenderer(
            type: type,
            values: values,
            pourcentage: pourcentage,
          ),
        ],
      ),
    );
  }
}

class _GraphRenderer extends StatelessWidget {
  final GraphType type;
  final dynamic values;
  final bool pourcentage;

  const _GraphRenderer({
    required this.type,
    required this.values,
    required this.pourcentage,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case GraphType.pie:
        return PieStatGraph(
          values: values as List<StatValue>,
          pourcentage: pourcentage,
        );
      case GraphType.splitBar:
        return SplitBarChart(values: values as List<StatValue>);
      case GraphType.timeLine:
        return TimeLineChart(values: values as List<TimeStatValue>);
    }
  }
}
