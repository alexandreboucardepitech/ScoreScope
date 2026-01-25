import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/stats_equipes_data.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsEquipesOnglet extends StatelessWidget {
  final bool showCards;
  final StatsEquipesData data;

  const StatsEquipesOnglet({
    super.key,
    required this.data,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Équipes différentes vues',
        value: data.nbEquipesDifferentes.toString(),
        icon: Icons.shield,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les plus vues',
        items: data.equipesLesPlusVues,
        emptyStateText: 'Aucune équipe',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les plus vues gagner',
        items: data.equipesLesPlusVuesGagner,
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les vues perdre',
        items: data.equipesLesPlusVuesPerdre,
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Buts marqués',
        items: data.equipesPlusDeButsMarques,
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Buts encaissés',
        items: data.equipesPlusDeButsEncaisses,
        emptyStateText: 'Aucune donnée',
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: 'Répartition des matchs par équipe',
        type: GraphType.pie,
        values: data.matchsVusParEquipe,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
