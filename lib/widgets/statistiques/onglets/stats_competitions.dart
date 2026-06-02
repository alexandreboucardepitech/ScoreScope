import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/onglets/stats_competitions_data.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsCompetitionsOnglet extends StatelessWidget {
  final bool showCards;
  final StatsCompetitionsData data;
  final AppUser user;

  const StatsCompetitionsOnglet({
    super.key,
    required this.data,
    this.showCards = true,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final statsWidgets = <Widget>[
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.competitionsLesPlusSuivies,
        items: data.competitionsLesPlusSuivies,
        emptyStateText: translate.aucuneCompetition,
        user: user,
      ),
      buildSimpleStatCardOrListTile(
          showCards: showCards,
          title: translate.competitionsDifferentesVues,
          value: data.nbCompetitionsDifferentes.toString(),
          icon: Icons.emoji_events),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.butsParCompetition,
        items: data.butsParCompetition,
        emptyStateText: translate.aucuneDonnee,
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.moyButsMatch,
        items: data.competitionsMoyButs,
        emptyStateText: translate.aucuneDonnee,
        user: user,
      ),
    ];
    final graphWidgets = <Widget>[
      GraphCard(
        title: translate.repartitionParCompetition,
        type: GraphType.pie,
        values: data.pourcentageMatchsCompetitions,
        pourcentage: true,
      ),
      // GraphCard(
      //   title: translate.typesDeCompetitions,
      //   type: GraphType.splitBar,
      //   values: data.typesCompetitions,
      // ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
