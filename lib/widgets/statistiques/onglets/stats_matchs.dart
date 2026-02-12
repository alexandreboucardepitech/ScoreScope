import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/stats_matchs_data.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsMatchsOnglet extends StatelessWidget {
  final bool showCards;
  final StatsMatchsData data;
  final AppUser user;

  const StatsMatchsOnglet({
    super.key,
    required this.data,
    this.showCards = true,
    required this.user,
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
        icon: Icons.show_chart,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Plus gros score',
        items: data.biggestScores,
        emptyStateText: 'Aucun match',
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Plus gros écart',
        items: data.biggestScoresDifference,
        emptyStateText: 'Aucun match',
        user: user,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Moyenne différence buts / match',
        value: data.moyenneDiffButsParMatch.toStringAsFixed(1),
        icon: Icons.balance,
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: 'Résultats (domicile / nul / extérieur)',
        type: GraphType.splitBar,
        values: data.pourcentageVictoireDomExt,
      ),
      GraphCard(
        title: 'Clubs vs Internationaux',
        type: GraphType.splitBar,
        values: data.pourcentageClubsInternationaux,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
