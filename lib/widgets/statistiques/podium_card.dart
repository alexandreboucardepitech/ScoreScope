import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class PodiumCard<T> extends StatelessWidget {
  final String title;
  final List<T> items;

  final String Function(T) labelExtractor;
  final num Function(T) valueExtractor;
  final String Function(T)? imageExtractor;

  final Color? accentColor;

  final String emptyStateText;

  const PodiumCard({
    super.key,
    required this.title,
    required this.items,
    required this.labelExtractor,
    required this.valueExtractor,
    this.imageExtractor,
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

  /// ───────────────── TITLE ─────────────────

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: ColorPalette.textSecondary(context),
      ),
    );
  }

  /// ───────────────── CONTENT SWITCH ─────────────────

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

  /// ───────────────── EMPTY STATE ─────────────────

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
              maxLines: 2,
              textAlign: TextAlign.center,
              emptyStateText,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────── SINGLE (HERO) ─────────────────

  Widget _buildSingle(BuildContext context, T item, Color accent, bool large) {
    final singleRow = Row(
      children: [
        if (imageExtractor != null)
          CircleAvatar(
            radius: large ? 32 : 28,
            backgroundImage: AssetImage(imageExtractor!(item)),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labelExtractor(item),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildValueChip(context, valueExtractor(item), accent,
                  large: large),
            ],
          ),
        ),
      ],
    );
    if (large) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            singleRow,
          ],
        ),
      );
    } else {
      return singleRow;
    }
  }

  /// ───────────────── DUO ─────────────────

  Widget _buildDuo(BuildContext context, List<T> duo, Color accent) {
    final first = duo[0];
    final second = duo[1];

    return Column(
      children: [
        _buildSingle(context, first, accent, false),
        Divider(color: ColorPalette.border(context)),
        _buildSecondaryRow(context, 2, second),
      ],
    );
  }

  /// ───────────────── PODIUM (3) ─────────────────

  Widget _buildPodium(BuildContext context, List<T> podium, Color accent) {
    final first = podium[0];

    return Column(
      children: [
        Row(
          children: [
            if (imageExtractor != null)
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(imageExtractor!(first)),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    labelExtractor(first),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildValueChip(context, valueExtractor(first), accent),
                ],
              ),
            ),
          ],
        ),
        Divider(
          color: ColorPalette.border(context),
          height: 12,
        ),
        _buildSecondaryRow(context, 2, podium[1]),
        if (podium.length > 2) _buildSecondaryRow(context, 3, podium[2]),
      ],
    );
  }

  /// ───────────────── SECONDARY ROW ─────────────────

  Widget _buildSecondaryRow(BuildContext context, int index, T item) {
    return Row(
      children: [
        Text(
          '$index.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: index == 2 ? Colors.grey : Colors.brown,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            labelExtractor(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
        Text(
          valueExtractor(item).toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorPalette.textPrimary(context),
            height: 0.9,
          ),
        ),
      ],
    );
  }

  /// ───────────────── VALUE CHIP ─────────────────

  Widget _buildValueChip(
    BuildContext context,
    num value,
    Color accent, {
    bool large = false,
  }) {
    final textColor = accent.computeLuminance() > 0.5
        ? ColorPalette.textPrimaryLight
        : ColorPalette.textPrimaryDark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          fontSize: large ? 20 : 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
