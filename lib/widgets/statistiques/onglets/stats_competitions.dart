import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/stats_competitions_data.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsCompetitionsOnglet extends StatelessWidget {
  final bool showCards;
  final StatsCompetitionsData data;

  const StatsCompetitionsOnglet({
    super.key,
    required this.data,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Compétitions les plus vues',
        items: data.competitionsLesPlusSuivies,
        emptyStateText: 'Aucune compétition',
      ),
      buildSimpleStatCardOrListTile(
          showCards: showCards,
          title: 'Compétitions différentes vues',
          value: data.nbCompetitionsDifferentes.toString(),
          icon: Icons.emoji_events),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Buts par compétition',
        items: data.butsParCompetition,
        emptyStateText: 'Aucune donnée',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Moy. buts / match',
        items: data.competitionsMoyButs,
        emptyStateText: 'Aucune donnée',
      ),
    ];
    final graphWidgets = <Widget>[
      GraphCard(
        title: 'Répartition par compétition',
        type: GraphType.pie,
        values: data.pourcentageMatchsCompetitions,
        pourcentage: true,
      ),
      GraphCard(
        title: 'Types de compétitions',
        type: GraphType.splitBar,
        values: data.typesCompetitions,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
