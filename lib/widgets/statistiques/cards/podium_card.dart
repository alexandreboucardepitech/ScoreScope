import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class PodiumCard<T> extends StatelessWidget {
  final String title;
  final List<PodiumEntry> items;

  final Color? accentColor;
  final String emptyStateText;

  const PodiumCard({
    super.key,
    required this.title,
    required this.items,
    this.accentColor,
    this.emptyStateText = 'Aucune donnée disponible',
  });

  @override
  Widget build(BuildContext context) {
    final colorAccent = accentColor ?? ColorPalette.accent(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 4),
          _buildContent(context, colorAccent),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: ColorPalette.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accent) {
    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    if (items.length == 1) {
      return _buildSingle(context, items.first, accent, true);
    }

    if (items.length == 2) {
      return _buildDuo(context, items.take(2).toList(), accent);
    }

    return _buildPodium(context, items.take(3).toList(), accent);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: ColorPalette.accent(context),
            ),
            Text(
              emptyStateText,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingle(
    BuildContext context,
    PodiumEntry podiumEntry,
    Color accent,
    bool large,
  ) {
    final content = podiumEntry.item.buildPodiumCard(
      context: context,
      podium: PodiumContext(
        rank: 1,
        value: podiumEntry.value,
        accent: accent,
      ),
    );

    if (large) {
      return Expanded(
        child: Center(child: content),
      );
    }

    return content;
  }

  Widget _buildDuo(
    BuildContext context,
    List<PodiumEntry> duo,
    Color accent,
  ) {
    return Column(
      children: [
        duo[0].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 1,
                value: duo[0].value,
                accent: accent,
              ),
            ),
        Divider(color: ColorPalette.border(context)),
        duo[1].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 2,
                value: duo[1].value,
                accent: accent,
              ),
            ),
      ],
    );
  }

  Widget _buildPodium(
    BuildContext context,
    List<PodiumEntry> podium,
    Color accent,
  ) {
    return Column(
      children: [
        podium[0].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 1,
                value: podium[0].value,
                accent: accent,
              ),
            ),
        Divider(
          color: ColorPalette.border(context),
          height: 12,
        ),
        podium[1].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 2,
                value: podium[1].value,
                accent: accent,
              ),
            ),
        if (podium.length > 2)
          podium[2].item.buildPodiumCard(
                context: context,
                podium: PodiumContext(
                  rank: 3,
                  value: podium[2].value,
                  accent: accent,
                ),
              ),
      ],
    );
  }
}
