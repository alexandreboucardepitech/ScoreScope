import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/stats/onglets/stats_generales_data.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/build_card_or_list_tile.dart';

class StatsGeneralesOnglet extends StatelessWidget {
  final bool showCards;
  final StatsGeneralesData data;
  final AppUser user;

  const StatsGeneralesOnglet({
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
        title: translate.butsVus,
        value: data.butsVus.toString(),
        icon: Icons.sports_soccer,
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
        title: translate.competitionsLesPlusSuivies,
        items: data.competitionsLesPlusSuivies,
        emptyStateText: translate.aucuneCompetition,
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.joueursLesPlusVusMarquer,
        items: data.meilleursButeurs,
        emptyStateText: translate.aucunButeur,
        user: user,
        logoBackground: false,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.buteursDifferents,
        value: data.nbButeursDifferents.toString(),
        icon: Icons.person,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.equipesDifferentesVues,
        value: data.nbEquipesDifferentes.toString(),
        icon: Icons.shield,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.competitionsDifferentesVues,
        value: data.nbCompetitionsDifferentes.toString(),
        icon: Icons.emoji_events,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.moyButsMatch,
        value: roundSmart(data.moyenneButsParMatch),
        icon: Icons.show_chart,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: translate.moyDesNotesDonnees,
        value: roundSmart(data.moyenneNotes),
        icon: Icons.star,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: translate.mvpLesPlusVotes,
        items: data.mvpsLesPlusVotes,
        emptyStateText: translate.aucunMvp,
        user: user,
        logoBackground: false,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: const [],
      showCards: showCards,
    );
  }
}
