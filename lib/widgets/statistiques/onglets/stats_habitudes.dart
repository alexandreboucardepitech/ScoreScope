import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/onglets/stats_habitudes_data.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsHabitudesOnglet extends StatelessWidget {
  final bool showCards;
  final StatsHabitudesData data;
  final AppUser user;

  const StatsHabitudesOnglet({
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
        title: translate.mvpLesPlusVotes,
        items: data.mvpsLesPlusVotes,
        emptyStateText: translate.aucunMvp,
        user: user,
        logoBackground: false,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.moyDesNotesDonnees,
        value: roundSmart(data.moyenneNotes),
        icon: Icons.star,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.matchsLesMieuxNotes,
        items: data.matchsMieuxNotes,
        emptyStateText: translate.aucunMatch,
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.matchsLesCommentes,
        items: data.matchsPlusCommentes.isNotEmpty &&
                data.matchsPlusCommentes[0].value != 0
            ? data.matchsPlusCommentes
            : [],
        emptyStateText: translate.aucunMatch,
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.matchsLesReactions,
        items: data.matchsPlusReactions.isNotEmpty &&
                data.matchsPlusReactions[0].value != 0
            ? data.matchsPlusReactions
            : [],
        emptyStateText: translate.aucunMatch,
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.joursAvecLePlusDeMatchsVus,
        items: data.joursLePlusDeMatchs,
        emptyStateText: translate.aucuneDonnee,
        user: user,
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: translate.typesDeVisionnage,
        type: GraphType.pie,
        values: data.typeVisionnage,
        pourcentage: true,
      ),
      GraphCard(
        title: translate.nombreDeMatchsVusParMois,
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
