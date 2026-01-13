import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsMatchsOnglet extends StatelessWidget {
  final bool showCards;

  const StatsMatchsOnglet({
    super.key,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Matchs vus',
        value: '128',
        icon: Icons.sports,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Moy. buts / match',
        value: '2.7',
        icon: Icons.bar_chart,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Plus gros score',
        items: const [],
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Plus gros écart',
        items: const [],
        emptyStateText: 'Aucun match',
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Diff. buts moyenne',
        value: '1.3',
        icon: Icons.compare_arrows,
      ),
    ];

    final graphWidgets = <Widget>[
      const GraphCard(title: 'Résultats (domicile / nul / extérieur)'),
      const GraphCard(title: 'Clubs vs Internationaux'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCards)
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: statsWidgets,
            )
          else
            Column(
              children: statsWidgets
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: w,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 16),
          Column(
            children: graphWidgets
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: w,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
