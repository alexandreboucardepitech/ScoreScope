import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';
import 'package:scorescope/utils/ui/stats_color_palette.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class PieStatGraph extends StatefulWidget {
  final List<StatValue> values;
  final bool pourcentage;

  const PieStatGraph({
    super.key,
    required this.values,
    this.pourcentage = false,
  });

  @override
  State<PieStatGraph> createState() => _PieStatGraphState();
}

class _PieStatGraphState extends State<PieStatGraph> {
  int? touchedIndex;

  double get total => widget.values.fold(0, (sum, v) => sum + v.value);

  bool get useStatsPalette => widget.values.any((v) => v.color == null);

  Color _getColor(int index, StatValue v) {
    if (!useStatsPalette && v.color != null) {
      return fromHex(v.color!);
    }
    return StatsColorPalette
        .statsColors[index % StatsColorPalette.statsColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final sortedValues = [...widget.values]
      ..sort((a, b) => b.value.compareTo(a.value));

    final legendItems = sortedValues.take(3).toList();

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    centerSpaceRadius: 24,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          touchedIndex =
                              response?.touchedSection?.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: List.generate(widget.values.length, (i) {
                      final v = widget.values[i];
                      final percent = v.value / total * 100;
                      final isTouched = i == touchedIndex;
                      final color = _getColor(i, v);

                      return PieChartSectionData(
                        value: v.value.toDouble(),
                        color: color,
                        radius: isTouched ? 56 : 48,
                        title: percent >= 10 ? '${percent.round()}%' : '',
                        titleStyle: TextStyle(
                          color: color.computeLuminance() > 0.5
                              ? ColorPalette.textPrimaryLight
                              : ColorPalette.textPrimaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                ),
                if (touchedIndex != null &&
                    touchedIndex! >= 0 &&
                    touchedIndex! < widget.values.length)
                  Positioned(
                    top: 0,
                    child: _Tooltip(
                      entry: widget.values[touchedIndex!],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: legendItems.map((v) {
                final index = widget.values.indexOf(v);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getColor(index, v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          v.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorPalette.textPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.pourcentage
                            ? '${v.value.toStringAsFixed(0)}%'
                            : v.value.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  final StatValue entry;

  const _Tooltip({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ColorPalette.surface(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          '${entry.label} : ${entry.value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
