import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
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

  // ───────────────── CONTENT SWITCH ─────────────────

  Widget _buildContent(BuildContext context, Color accent) {
    if (items.isEmpty) {
      return _buildEmpty(context);
    }

    if (items.length == 1) {
      return _buildSingle(context, items.first, accent);
    }

    if (items.length == 2) {
      return _buildRow(context, items.take(2).toList(), accent);
    }

    return _buildRow(context, items.take(3).toList(), accent);
  }

  // ───────────────── EMPTY ─────────────────

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

  // ───────────────── SINGLE (FULL WIDTH HERO) ─────────────────

  Widget _buildSingle(
      BuildContext context, PodiumEntry podiumEntry, Color accent) {
    return Row(
      children: [
        if (podiumEntry.item.displayImage != null)
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(podiumEntry.item.displayImage!),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            podiumEntry.item.displayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
        _buildValueChip(context, podiumEntry.value, accent),
      ],
    );
  }

  // ───────────────── ROW (2 / 3 ITEMS) ─────────────────

  Widget _buildRow(
      BuildContext context, List<PodiumEntry> podium, Color accent) {
    return Row(
      children: [
        _buildFirst(context, podium.first, accent),
        for (int i = 1; i < podium.length; i++) ...[
          _verticalDivider(context),
          _buildSecondary(context, podium[i]),
        ],
      ],
    );
  }

  // ───────────────── FIRST ─────────────────

  Widget _buildFirst(
      BuildContext context, PodiumEntry podiumEntry, Color accent) {
    return Expanded(
      flex: 4,
      child: Row(
        children: [
          if (podiumEntry.item.displayImage != null)
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(podiumEntry.item.displayImage!),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              podiumEntry.item.displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _buildValueChip(context, podiumEntry.value, accent),
        ],
      ),
    );
  }

  // ───────────────── SECONDARY ─────────────────

  Widget _buildSecondary(BuildContext context, PodiumEntry podiumEntry) {
    return Expanded(
      flex: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              podiumEntry.item.displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            podiumEntry.value.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── VALUE CHIP ─────────────────

  Widget _buildValueChip(BuildContext context, num value, Color accent) {
    final textColor = accent.computeLuminance() > 0.5
        ? ColorPalette.textPrimaryLight
        : ColorPalette.textPrimaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // ───────────────── DIVIDER ─────────────────

  Widget _verticalDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: ColorPalette.border(context),
    );
  }
}
