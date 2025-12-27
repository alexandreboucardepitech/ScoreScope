import 'package:flutter/material.dart';
import 'package:scorescope/widgets/statistiques/graph_card.dart';
import 'package:scorescope/widgets/statistiques/podium_card.dart';
import 'package:scorescope/widgets/statistiques/simple_stat_card.dart';

class StatsEquipesOnglet extends StatelessWidget {
  const StatsEquipesOnglet({super.key});

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
          PodiumCard(
            title: 'Équipes les plus vues',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune équipe',
          ),
          SimpleStatCard(
              title: 'Équipes différentes', value: '42', icon: Icons.groups),
          PodiumCard(
            title: 'Équipes les + gagnantes',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          PodiumCard(
            title: 'Équipes les + perdantes',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          PodiumCard(
            title: 'Buts marqués',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          PodiumCard(
            title: 'Buts encaissés',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          GraphCard(
            title: 'Répartition des matchs par équipe',
          ),
        ],
      ),
    );
  }
}
