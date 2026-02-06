import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class PodiumListItem<T> extends StatelessWidget {
  final String title;
  final List<PodiumEntry> items;

  final Color? accentColor;
  final String emptyStateText;

  const PodiumListItem({
    super.key,
    required this.title,
    required this.items,
    this.accentColor,
    this.emptyStateText = 'Aucune donnée disponible',
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? ColorPalette.accent(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: ColorPalette.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          _buildContent(context, accent),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accent) {
    if (items.isEmpty) {
      return _buildEmpty(context);
    }

    if (items.length == 1) {
      return _buildSingle(context, items.first, accent);
    }

    return _buildRow(context, items.take(3).toList(), accent);
  }

  Widget _buildEmpty(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.bar_chart_outlined,
          color: ColorPalette.textSecondary(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            emptyStateText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingle(
    BuildContext context,
    PodiumEntry podiumEntry,
    Color accent,
  ) {
    return podiumEntry.item.buildPodiumRow(
      context: context,
      podium: PodiumContext(
        rank: 1,
        value: podiumEntry.value,
        accent: accent,
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<PodiumEntry> podium,
    Color accent,
  ) {
    final first = podium[0];
    final second = podium.length > 1 ? podium[1] : null;
    final third = podium.length > 2 ? podium[2] : null;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: first.item.buildPodiumRow(
            context: context,
            podium: PodiumContext(
              rank: 1,
              value: first.value,
              accent: accent,
            ),
          ),
        ),
        _verticalDivider(context),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              if (second != null)
                Expanded(
                  child: second.item.buildPodiumRow(
                    context: context,
                    podium: PodiumContext(
                      rank: 2,
                      value: second.value,
                      accent: accent,
                    ),
                  ),
                ),
              if (second != null && third != null)
                _verticalDivider(context, height: 20),
              if (third != null)
                Expanded(
                  child: third.item.buildPodiumRow(
                    context: context,
                    podium: PodiumContext(
                      rank: 3,
                      value: third.value,
                      accent: accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(BuildContext context, {double height = 24}) {
    return Container(
      width: 1,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: ColorPalette.border(context),
    );
  }
}
