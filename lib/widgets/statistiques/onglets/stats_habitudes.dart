import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/stats_habitudes_data.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsHabitudesOnglet extends StatelessWidget {
  final bool showCards;
  final StatsHabitudesData data;

  const StatsHabitudesOnglet({
    super.key,
    required this.data,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'MVP les plus votés',
        items: data.mvpsLesPlusVotes,
        emptyStateText: 'Aucun MVP',
      ),
      buildSimpleStatCardOrListTile(
          showCards: showCards,
          title: 'Note moyenne',
          value: data.moyenneNotes.toString(),
          icon: Icons.star),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Matchs les mieux notés',
        items: data.matchsMieuxNotes,
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Matchs les + commentés',
        items: data.matchsPlusCommentes,
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Matchs les + réactions',
        items: data.matchsPlusReactions,
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Jours avec le plus de matchs vus',
        items: data.joursLePlusDeMatchs,
        emptyStateText: 'Aucune donnée',
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: 'Types de visionnage',
        type: GraphType.pie,
        values: data.typeVisionnage,
        pourcentage: true,
      ),
      GraphCard(
        title: 'Nombre de matchs vus par mois',
        type: GraphType.timeLine,
        values: data.matchsVusParMois,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
