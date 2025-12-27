import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/widgets/statistiques/podium_card.dart';
import 'package:scorescope/widgets/statistiques/simple_stat_card.dart';

class StatsGeneralesOnglet extends StatelessWidget {
  const StatsGeneralesOnglet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          SimpleStatCard(
              title: 'Matchs vus', value: '128', icon: Icons.sports_soccer),
          SimpleStatCard(title: 'Buts vus', value: '342', icon: Icons.sports),
          PodiumCard(
            title: 'Équipes les plus vues',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune équipe',
          ),
          PodiumCard(
            title: 'Compétitions suivies',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune compétition',
          ),
          PodiumCard<Joueur>(
            title: 'Joueurs les plus vus marquer',
            items: const [],
            labelExtractor: (j) => j.shortName,
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun buteur',
          ),
          SimpleStatCard(
              title: 'Joueurs différents buteurs',
              value: '58',
              icon: Icons.person),
          SimpleStatCard(
              title: 'Équipes différentes vues',
              value: '42',
              icon: Icons.groups),
          SimpleStatCard(
              title: 'Compétitions différentes',
              value: '12',
              icon: Icons.emoji_events),
          SimpleStatCard(
              title: 'Moy. buts / match', value: '2.7', icon: Icons.bar_chart),
          SimpleStatCard(title: 'Moy. notes', value: '7.4', icon: Icons.star),
          PodiumCard(
            title: 'MVP le plus voté',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun MVP',
          ),
        ],
      ),
    );
  }
}
