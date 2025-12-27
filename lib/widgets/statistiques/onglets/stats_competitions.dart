import 'package:flutter/material.dart';
import 'package:scorescope/widgets/statistiques/graph_card.dart';
import 'package:scorescope/widgets/statistiques/podium_card.dart';
import 'package:scorescope/widgets/statistiques/simple_stat_card.dart';

class StatsCompetitionsOnglet extends StatelessWidget {
  const StatsCompetitionsOnglet({super.key});

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
            title: 'Compétitions les plus vues',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune compétition',
          ),
          SimpleStatCard(
              title: 'Compétitions différentes',
              value: '12',
              icon: Icons.emoji_events),
          PodiumCard(
            title: 'Buts par compétition',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          PodiumCard(
            title: 'Moy. buts / match',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          GraphCard(
            title: 'Répartition par compétition',
          ),
          GraphCard(
            title: 'Types de compétitions',
          ),
        ],
      ),
    );
  }
}
