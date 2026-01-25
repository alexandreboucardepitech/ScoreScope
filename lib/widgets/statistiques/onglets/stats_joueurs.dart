import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/stats_joueurs_data.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsJoueursOnglet extends StatelessWidget {
  final bool showCards;
  final StatsJoueursData data;

  const StatsJoueursOnglet({
    super.key,
    required this.data,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Buteurs les plus vus',
        items: data.meilleursButeurs,
        emptyStateText: 'Aucun joueur',
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Titularisations',
        items: data.titularisations,
        emptyStateText: 'Aucun joueur',
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'MVP les plus votés',
        items: data.mvpsLesPlusVotes,
        emptyStateText: 'Aucun MVP',
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Record de buts sur un match',
        items: data.meilleursButeursUnMatch,
        emptyStateText: 'Aucun record',
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: 'Répartition des buts par joueur',
        type: GraphType.pie,
        values: data.butsParJoueur,
      ),
    ];

    return buildGridOrList(
      statsWidgets: widgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
