import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';

class StatsJoueursOnglet extends StatelessWidget {
  final bool showCards;
  const StatsJoueursOnglet({super.key, this.showCards = true});

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Buteurs les plus vus',
        items: const [],
        emptyStateText: 'Aucun joueur',
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Titularisations',
        items: const [],
        emptyStateText: 'Aucun joueur',
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'MVP les plus votés',
        items: const [],
        emptyStateText: 'Aucun MVP',
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Record de buts sur un match',
        items: const [],
        emptyStateText: 'Aucun record',
      ),
    ];

    return buildGridOrList(
      statsWidgets: widgets,
      graphWidgets: [],
      showCards: showCards,
    );
  }
}
