import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/onglets/stats_joueurs_data.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsJoueursOnglet extends StatelessWidget {
  final bool showCards;
  final StatsJoueursData data;
  final AppUser user;

  const StatsJoueursOnglet({
    super.key,
    required this.data,
    this.showCards = true,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: translate.buteursLesPlusVus,
        items: data.meilleursButeurs,
        emptyStateText: translate.aucunJoueur,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: translate.passesDecisives,
        items: data.meilleursPasseurs,
        emptyStateText: translate.aucunJoueur,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: translate.gA,
        items: data.meilleursGAs,
        emptyStateText: translate.aucunJoueur,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: translate.titularisations,
        items: data.titularisations,
        emptyStateText: translate.aucunJoueur,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: translate.mvpLesPlusVotes,
        items: data.mvpsLesPlusVotes,
        emptyStateText: translate.aucunMvp,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: translate.recordDeButsSurUnMatch,
        items: data.meilleursButeursUnMatch,
        emptyStateText: translate.aucuneDonnee,
        user: user,
        logoBackground: false,
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: translate.nombreDeButsVotesMvp,
        type: GraphType.scatter,
        values: data.butsMvpParJoueur,
        labelX: translate.buts,
        labelY: translate.votesMvp,
      ),
    ];

    return buildGridOrList(
      statsWidgets: widgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
