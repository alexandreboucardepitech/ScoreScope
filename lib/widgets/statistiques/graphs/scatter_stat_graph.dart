import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/stat_value_duo.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class _Cluster {
  final num valueX;
  final num valueY;
  final List<StatValueDuo> members;

  const _Cluster({
    required this.valueX,
    required this.valueY,
    required this.members,
  });

  int get count => members.length;

  double radius(bool isTouched) {
    final base = 5.0 + 3.0 * sqrt(count.toDouble());
    return isTouched ? base + 3 : base;
  }
}

class ScatterStatGraph extends StatefulWidget {
  final List<StatValueDuo> values;
  final String labelX;
  final String labelY;

  const ScatterStatGraph({
    super.key,
    required this.values,
    this.labelX = 'Buts',
    this.labelY = 'MVPs',
  });

  @override
  State<ScatterStatGraph> createState() => _ScatterStatGraphState();
}

class _ScatterStatGraphState extends State<ScatterStatGraph> {
  int? touchedIndex;

  List<_Cluster> _buildClusters(List<StatValueDuo> values) {
    final Map<String, List<StatValueDuo>> map = {};
    for (final v in values) {
      final key = '${v.valueX}_${v.valueY}';
      map.putIfAbsent(key, () => []).add(v);
    }
    return map.entries
        .map((e) => _Cluster(
              valueX: e.value.first.valueX,
              valueY: e.value.first.valueY,
              members: e.value,
            ))
        .toList();
  }

  bool _isIsolated(
    _Cluster cluster,
    List<_Cluster> allClusters,
    double axisMaxX,
    double axisMaxY,
  ) {
    const double threshold = 0.15;
    final nx = cluster.valueX / axisMaxX;
    final ny = cluster.valueY / axisMaxY;

    for (final other in allClusters) {
      if (other == cluster) continue;
      final ox = other.valueX / axisMaxX;
      final oy = other.valueY / axisMaxY;
      final dist = sqrt(pow(nx - ox, 2) + pow(ny - oy, 2));
      if (dist < threshold) return false;
    }
    return true;
  }

  bool showLabelFunction(
    int spotIndex,
    List<_Cluster> clusters,
    double axisMaxX,
    double axisMaxY,
  ) {
    if (spotIndex >= clusters.length) return false;
    final cluster = clusters[spotIndex];
    return cluster.count == 1 &&
        _isIsolated(cluster, clusters, axisMaxX, axisMaxY);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) return const SizedBox(height: 240);

    final maxX = widget.values.map((v) => v.valueX.toDouble()).reduce(max);
    final maxY = widget.values.map((v) => v.valueY.toDouble()).reduce(max);
    final axisMaxX = (maxX * 1.18).ceilToDouble();
    final axisMaxY = (maxY * 1.18).ceilToDouble();

    final clusters = _buildClusters(widget.values);
    final touched = touchedIndex != null ? clusters[touchedIndex!] : null;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: ScatterChart(
              ScatterChartData(
                minX: 0,
                maxX: axisMaxX,
                minY: 0,
                maxY: axisMaxY,
                scatterSpots: List.generate(clusters.length, (i) {
                  final cluster = clusters[i];
                  final isTouched = i == touchedIndex;

                  final color = cluster.members.first.color != null
                      ? fromHex(cluster.members.first.color!)
                      : ColorPalette.accent(context);

                  return ScatterSpot(
                    cluster.valueX.toDouble(),
                    cluster.valueY.toDouble(),
                    dotPainter: FlDotCirclePainter(
                      radius: cluster.radius(isTouched),
                      color: color,
                      strokeWidth: isTouched ? 2 : 1,
                      strokeColor: ColorPalette.textPrimaryDark,
                    ),
                  );
                }),
                scatterLabelSettings: ScatterLabelSettings(
                  showLabel: true,
                  getLabelTextStyleFunction: (spotIndex, spot) => TextStyle(
                    fontSize: 10,
                    color: ColorPalette.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                  getLabelFunction: (spotIndex, spot) {
                    if ((spotIndex >= clusters.length) ||
                        showLabelFunction(
                                spotIndex, clusters, axisMaxX, axisMaxY) ==
                            false) return '';
                    final cluster = clusters[spotIndex];
                    return cluster.members.first.label;
                  },
                ),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    setState(() {
                      touchedIndex = response?.touchedSpot?.spotIndex;
                    });
                  },
                  mouseCursorResolver: (_, __) => SystemMouseCursors.click,
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: ColorPalette.border(context).withOpacity(0.4),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: ColorPalette.border(context).withOpacity(0.4),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      widget.labelY,
                      style: TextStyle(
                        fontSize: 10,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),
                    axisNameSize: 16,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _niceInterval(axisMaxY),
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox();
                        }
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorPalette.textSecondary(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      widget.labelX,
                      style: TextStyle(
                        fontSize: 10,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),
                    axisNameSize: 16,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: _niceInterval(axisMaxX),
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: ColorPalette.textSecondary(context),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: touched != null
              ? _InfoPanel(
                  key: ValueKey('${touched.valueX}_${touched.valueY}'),
                  cluster: touched,
                  labelX: widget.labelX,
                  labelY: widget.labelY,
                )
              : _Hint(),
        ),
      ],
    );
  }

  double _niceInterval(double max) {
    if (max <= 5) return 1;
    if (max <= 12) return 2;
    if (max <= 25) return 5;
    return (max / 4).ceilToDouble();
  }
}

class _InfoPanel extends StatelessWidget {
  final _Cluster cluster;
  final String labelX;
  final String labelY;

  const _InfoPanel({
    super.key,
    required this.cluster,
    required this.labelX,
    required this.labelY,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: cluster.count == 1
          ? Row(
              children: [
                if (cluster.members.first.color != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: fromHex(cluster.members.first.color!),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  cluster.members.first.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorPalette.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${cluster.valueX.toInt()} ${labelX}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorPalette.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '·',
                  style: TextStyle(color: ColorPalette.textSecondary(context)),
                ),
                const SizedBox(width: 4),
                Text(
                  '${cluster.valueY.toInt()} ${labelY}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorPalette.textSecondary(context),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '${cluster.valueX.toInt()} ${labelX} · ${cluster.valueY.toInt()} ${labelY}',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: cluster.members.map((m) {
                    final color = m.color != null
                        ? fromHex(m.color!)
                        : ColorPalette.textSecondary(context);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorPalette.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

class _Hint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Center(
        child: Text(
          'Appuie sur un point pour voir le joueur',
          style: TextStyle(
            fontSize: 11,
            color: ColorPalette.textSecondary(context).withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
