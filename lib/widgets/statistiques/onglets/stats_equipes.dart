import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/stats/onglets/stats_equipes_data.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';

class StatsEquipesOnglet extends StatelessWidget {
  final bool showCards;
  final StatsEquipesData data;
  final AppUser user;

  const StatsEquipesOnglet({
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
        title: translate.equipesDifferentesVues,
        value: data.nbEquipesDifferentes.toString(),
        icon: Icons.shield,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.equipesLesPlusVues,
        items: data.equipesLesPlusVues,
        emptyStateText: translate.aucuneEquipe,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.equipesLesPlusVuesGagner,
        items: data.equipesLesPlusVuesGagner,
        emptyStateText: translate.aucuneDonnee,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.equipesLesPlusVuesPerdre,
        items: data.equipesLesPlusVuesPerdre,
        emptyStateText: translate.aucuneDonnee,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.butsMarques,
        items: data.equipesPlusDeButsMarques,
        emptyStateText: translate.aucuneDonnee,
        user: user,
        logoBackground: false,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.butsEncaisses,
        items: data.equipesPlusDeButsEncaisses,
        emptyStateText: translate.aucuneDonnee,
        user: user,
        logoBackground: false,
      ),
    ];

    final graphWidgets = <Widget>[
      GraphCard(
        title: translate.pourcentageDeVictoiresMin3MatchsVus,
        type: GraphType.scatter,
        values: data.pourcentageVictoiresParEquipe,
        labelX: translate.matchs,
        labelY: translate.pourcentageVictoires,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: graphWidgets,
      showCards: showCards,
    );
  }
}
