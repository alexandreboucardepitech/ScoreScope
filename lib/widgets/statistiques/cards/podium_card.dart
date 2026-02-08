import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class PodiumCard<T> extends StatelessWidget {
  final String title;
  final List<PodiumEntry> items;
  final String emptyStateText;

  const PodiumCard({
    super.key,
    required this.title,
    required this.items,
    this.emptyStateText = 'Aucune donnée disponible',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("coucou test");
      },
      child: Container(
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
            _buildContent(context),
          ],
        ),
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

  Widget _buildContent(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    if (items.length == 1) {
      return _buildSingle(context, items.first, true);
    }

    if (items.length == 2) {
      return _buildDuo(context, items.take(2).toList());
    }

    return _buildPodium(context, items.take(3).toList());
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
    bool large,
  ) {
    final content = podiumEntry.item.buildPodiumCard(
      context: context,
      podium: PodiumContext(
        rank: 1,
        value: podiumEntry.value,
        color: podiumEntry.color,
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
  ) {
    return Column(
      children: [
        duo[0].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 1,
                value: duo[0].value,
                color: duo[0].color,
              ),
            ),
        Divider(color: ColorPalette.border(context)),
        duo[1].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 2,
                value: duo[1].value,
                color: duo[1].color,
              ),
            ),
      ],
    );
  }

  Widget _buildPodium(
    BuildContext context,
    List<PodiumEntry> podium,
  ) {
    return Column(
      children: [
        podium[0].item.buildPodiumCard(
              context: context,
              podium: PodiumContext(
                rank: 1,
                value: podium[0].value,
                color: podium[0].color,
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
                color: podium[1].color,
              ),
            ),
        if (podium.length > 2)
          podium[2].item.buildPodiumCard(
                context: context,
                podium: PodiumContext(
                  rank: 3,
                  value: podium[2].value,
                  color: podium[2].color,
                ),
              ),
      ],
    );
  }
}
