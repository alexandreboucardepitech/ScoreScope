import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';
import 'package:scorescope/utils/ui/stats_color_palette.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class SplitBarChart extends StatelessWidget {
  final List<StatValue> values;

  const SplitBarChart({
    super.key,
    required this.values,
  });

  bool get useStatsPalette => values.any((v) => v.color == null);

  Color _getColor(int index, StatValue v) {
    if (!useStatsPalette && v.color != null) {
      return fromHex(v.color!);
    }
    return StatsColorPalette
        .statsColors[index % StatsColorPalette.statsColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (sum, v) => sum + v.value.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: ColorPalette.surfaceSecondary(context),
            ),
            child: Row(
              children: List.generate(values.length, (i) {
                final v = values[i];

                return Expanded(
                  flex: (v.value / total * 1000).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColor(i, v),
                      border: i == values.length - 1
                          ? null
                          : Border(
                              right: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                                width: 1,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(values.length, (i) {
              final v = values[i];
              final percent = (v.value / total * 100).round();

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getColor(i, v),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${v.label} $percent%',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
