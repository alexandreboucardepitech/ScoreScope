import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
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
}) {
  if (showCards) {
    return SimpleStatCard(
      title: title,
      value: value,
      icon: icon,
    );
  } else {
    return SimpleStatListItem(
      title: title,
      value: value,
      icon: icon,
    );
  }
}

Widget buildPodiumCardOrListTile<T>({
  required bool showCards,
  required String title,
  required List<PodiumEntry> items,
  String Function(T)? imageExtractor,
  required String emptyStateText,
  required AppUser user,
}) {
  if (showCards) {
    return PodiumCard<T>(
      title: title,
      items: items,
      emptyStateText: emptyStateText,
      user: user,
    );
  } else {
    return PodiumListItem<T>(
      title: title,
      items: items,
      emptyStateText: emptyStateText,
      user: user,
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
      child: CustomScrollView(
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => statsWidgets[index],
              childCount: statsWidgets.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
          ),
          if (graphWidgets.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Divider(height: 48),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: graphWidgets[index],
                ),
                childCount: graphWidgets.length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...statsWidgets.map(
            (widget) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: widget,
            ),
          ),
          if (graphWidgets.isNotEmpty) ...[
            const Divider(height: 32),
            const SizedBox(height: 12),
            ...graphWidgets.map(
              (widget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
