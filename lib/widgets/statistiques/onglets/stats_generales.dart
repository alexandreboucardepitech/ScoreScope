import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/stats/stats_generales_data.dart';
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
        title: 'Matchs vus',
        value: data.matchsVus.toString(),
        icon: Icons.sports,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Buts vus',
        value: data.butsVus.toString(),
        icon: Icons.sports_soccer,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Équipes les plus vues',
        items: data.equipesLesPlusVues,
        emptyStateText: 'Aucune équipe',
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Compétitions les plus suivies',
        items: data.competitionsLesPlusSuivies,
        emptyStateText: 'Aucune compétition',
        user: user,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'Joueurs les plus vus marquer',
        items: data.meilleursButeurs,
        emptyStateText: 'Aucun buteur',
        user: user,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Buteurs différents',
        value: data.nbButeursDifferents.toString(),
        icon: Icons.person,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Équipes différentes vues',
        value: data.nbEquipesDifferentes.toString(),
        icon: Icons.shield,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Compétitions différentes vues',
        value: data.nbCompetitionsDifferentes.toString(),
        icon: Icons.emoji_events,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Moy. buts / match',
        value: data.moyenneButsParMatch.toStringAsFixed(1),
        icon: Icons.show_chart,
      ),
      buildSimpleStatCardOrListTile(
        showCards: showCards,
        title: 'Moy. des notes données',
        value: data.moyenneNotes.toStringAsFixed(1),
        icon: Icons.star,
      ),
      buildPodiumCardOrListTile(
        showCards: showCards,
        title: 'MVP les plus voté',
        items: data.mvpsLesPlusVotes,
        emptyStateText: 'Aucun MVP',
        user: user,
      ),
    ];

    return buildGridOrList(
      statsWidgets: statsWidgets,
      graphWidgets: const [],
      showCards: showCards,
    );
  }
}
