// reaction_row.dart
import 'package:flutter/material.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class ReactionRow extends StatelessWidget {
  final MatchUserData matchUserData;
  final String? currentUserId;
  final Future<void> Function(String emoji) onToggle;
  final bool loading;

  const ReactionRow({
    required this.matchUserData,
    required this.onToggle,
    this.currentUserId,
    this.loading = false,
    super.key,
  });

  bool _currentUserReactedWith(String emoji) {
    if (currentUserId == null) return false;
    final Map<String, List<String>> userMap =
        matchUserData.reactionsUserToEmojiMap();
    return userMap[currentUserId!]?.contains(emoji) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // counts: emoji -> count
    final counts = matchUserData.countsReactions();

    // default emojis always shown first
    final List<String> defaultEmojis = ['🔥', '😮', '😭', '👀'];

    // Build default entries with current counts (0 if absent)
    final List<MapEntry<String, int>> defaultEntries =
        defaultEmojis.map((e) => MapEntry(e, counts[e] ?? 0)).toList();

    // custom emojis (those present in counts but not in defaults)
    final Set<String> defaultsSet = defaultEmojis.toSet();
    final customEntries = counts.keys
        .where((k) => !defaultsSet.contains(k))
        .map((k) => MapEntry(k, counts[k] ?? 0))
        .toList();

    customEntries.sort((a, b) => b.value.compareTo(a.value));

    final entries = <MapEntry<String, int>>[
      ...defaultEntries,
      ...customEntries,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final e in entries)
                    _ReactionChip(
                      emoji: e.key,
                      // now pass the real count
                      count: e.value,
                      // active only if current user reacted with this emoji
                      active: _currentUserReactedWith(e.key),
                      onTap: () => onToggle(e.key),
                    ),
                  // plus button (open picker later)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Ajouter réaction (à implémenter)')));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: ColorPalette.border(context)),
                        ),
                        child: const Icon(Icons.add, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading) const SizedBox(width: 12),
          if (loading)
            const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  const _ReactionChip({
    required this.emoji,
    required this.count,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const emojiFontSize = 16.0;

    final bg = active
        ? ColorPalette.accent(context)
        : ColorPalette.tileBackground(context);
    final borderColor =
        active ? ColorPalette.accent(context) : ColorPalette.border(context);

    final countWidget = count == 0
        ? Text('+',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: ColorPalette.textSecondary(context),
            ))
        : Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active
                  ? ColorPalette.textPrimary(context)
                  : ColorPalette.textSecondary(context),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: emojiFontSize)),
            const SizedBox(width: 6),
            countWidget,
          ]),
        ),
      ),
    );
  }
}
