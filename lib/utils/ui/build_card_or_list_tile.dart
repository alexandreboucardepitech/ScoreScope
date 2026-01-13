import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/widgets/statistiques/cards/podium_card.dart';
import 'package:scorescope/widgets/statistiques/cards/simple_stat_card.dart';
import 'package:scorescope/widgets/statistiques/list_item/podium_list_item.dart';
import 'package:scorescope/widgets/statistiques/list_item/simple_stat_list_item.dart';

Widget buildSimpleStatCardOrListTile({
  required bool showCards,
  required String title,
  required String value,
  required IconData icon,
  Color? accentColor,
}) {
  if (showCards) {
    return SimpleStatCard(
      title: title,
      value: value,
      icon: icon,
      accentColor: accentColor,
    );
  } else {
    return SimpleStatListItem(
      title: title,
      value: value,
      icon: icon,
      accentColor: accentColor,
    );
  }
}

Widget buildPodiumCardOrListTile<T>({
  required bool showCards,
  required String title,
  required List<PodiumEntry> items,
  String Function(T)? imageExtractor,
  required String emptyStateText,
  Color? accentColor,
}) {
  if (showCards) {
    return PodiumCard<T>(
      title: title,
      items: items,
      emptyStateText: emptyStateText,
      accentColor: accentColor,
    );
  } else {
    return PodiumListItem<T>(
      title: title,
      items: items,
      emptyStateText: emptyStateText,
      accentColor: accentColor,
    );
  }
}

Widget buildGridOrList({
  required List<Widget> statsWidgets,
  required List<Widget> graphWidgets,
  required bool showCards,
}) {
  if (showCards) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [...statsWidgets, ...graphWidgets],
      ),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...statsWidgets.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: w,
                )),
            if (graphWidgets.isNotEmpty) ...[
              const Divider(height: 32),
              ...graphWidgets.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: w,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
