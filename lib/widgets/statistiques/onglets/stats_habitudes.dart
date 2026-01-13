import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsHabitudesOnglet extends StatelessWidget {
  final bool showCards;
  const StatsHabitudesOnglet({super.key, this.showCards = true});

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'MVP les plus votés',
        items: const [],
        emptyStateText: 'Aucun MVP',
      ),
      buildSimpleStatCardOrListTile(
          showCards: showCards,
          title: 'Note moyenne',
          value: '7.4',
          icon: Icons.star),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Matchs les mieux notés',
        items: const [],
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Matchs les + commentés',
        items: const [],
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Matchs les + réactions',
        items: const [],
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Jours avec le plus de matchs vus',
        items: const [],
        emptyStateText: 'Aucune donnée',
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(title: 'Types de visionnage'),
      GraphCard(title: 'Matchs par jour'),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
