import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsEquipesOnglet extends StatelessWidget {
  final bool showCards;
  const StatsEquipesOnglet({super.key, this.showCards = true});

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les plus vues',
        items: const [],
        emptyStateText: 'Aucune équipe',
      ),
      buildSimpleStatCardOrListTile(
          showCards: showCards,
          title: 'Équipes différentes vues',
          value: '42',
          icon: Icons.groups),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les plus vues gagner',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les vues perdre',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Buts marqués',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Buts encaissés',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(title: 'Répartition des matchs par équipe'),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
