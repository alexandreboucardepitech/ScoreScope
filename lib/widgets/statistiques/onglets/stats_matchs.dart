import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/onglets/stats_matchs_data.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
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
        title: translate.matchsVus,
        value: data.matchsVus.toString(),
        icon: Icons.sports,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.moyButsMatch,
        value: roundSmart(data.moyenneButsParMatch),
        icon: Icons.show_chart,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.plusGrosScore,
        items: data.biggestScores,
        emptyStateText: translate.aucunMatch,
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.plusGrosEcart,
        items: data.biggestScoresDifference,
        emptyStateText: translate.aucunMatch,
        user: user,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.moyenneDifferenceButsMatch,
        value: roundSmart(data.moyenneDiffButsParMatch),
        icon: Icons.balance,
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: translate.resultatsDomicileNulExterieur,
        type: GraphType.splitBar,
        values: data.pourcentageVictoireDomExt,
      ),
      // caché en attendant que ce soit vraiment implémenté
      // GraphCard(
      //   title: translate.clubsVsInternationaux,
      //   type: GraphType.splitBar,
      //   values: data.pourcentageClubsInternationaux,
      // ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
