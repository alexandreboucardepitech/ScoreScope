import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/stats_matchs_data.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsMatchsOnglet extends StatelessWidget {
  final bool showCards;
  final StatsMatchsData data;

  const StatsMatchsOnglet({
    super.key,
    required this.data,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Matchs vus',
        value: data.matchsVus.toString(),
        icon: Icons.sports,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Moy. buts / match',
        value: data.moyenneButsParMatch.toStringAsFixed(1),
        icon: Icons.bar_chart,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Plus gros score',
        items: data.biggestScores,
        emptyStateText: 'Aucun match',
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Plus gros écart',
        items: data.biggestScoresDifference,
        emptyStateText: 'Aucun match',
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Diff. buts moyenne',
        value: data.moyenneDiffButsParMatch.toStringAsFixed(1),
        icon: Icons.compare_arrows,
      ),
    ];

    final graphWidgets = <Widget>[
      const GraphCard(title: 'Résultats (domicile / nul / extérieur)'),
      const GraphCard(title: 'Clubs vs Internationaux'),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
