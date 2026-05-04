import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/onglets/stats_joueurs_data.dart';
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
        title: 'Buteurs les plus vus',
        items: data.meilleursButeurs,
        emptyStateText: 'Aucun joueur',
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Passes décisives',
        items: data.meilleursPasseurs,
        emptyStateText: 'Aucun joueur',
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'G+A',
        items: data.meilleursGAs,
        emptyStateText: 'Aucun joueur',
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Titularisations',
        items: data.titularisations,
        emptyStateText: 'Aucun joueur',
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'MVP les plus votés',
        items: data.mvpsLesPlusVotes,
        emptyStateText: 'Aucun MVP',
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile<Joueur>(
        showCards: showCards,
        title: 'Record de buts sur un match',
        items: data.meilleursButeursUnMatch,
        emptyStateText: 'Aucun record',
        user: user,
        logoBackground: false,
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: 'Nombre de buts / votes MVP',
        type: GraphType.scatter,
        values: data.butsMvpParJoueur,
        labelX: 'Buts',
        labelY: 'Votes MVP',
      ),
    ];

    return buildGridOrList(
      statsWidgets: widgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
