import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsCompetitionsOnglet extends StatelessWidget {
  final bool showCards;
  const StatsCompetitionsOnglet({super.key, this.showCards = true});

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Compétitions les plus vues',
        items: const [],
        emptyStateText: 'Aucune compétition',
      ),
      buildSimpleStatCardOrListTile(
          showCards: showCards,
          title: 'Compétitions différentes vues',
          value: '12',
          icon: Icons.emoji_events),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Buts par compétition',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Moy. buts / match',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
    ];
    final graphWidgets = <Widget>[
      GraphCard(title: 'Répartition par compétition'),
      GraphCard(title: 'Types de compétitions'),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
