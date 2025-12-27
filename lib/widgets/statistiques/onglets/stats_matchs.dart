import 'package:flutter/material.dart';
import 'package:scorescope/widgets/statistiques/graph_card.dart';
import 'package:scorescope/widgets/statistiques/podium_card.dart';
import 'package:scorescope/widgets/statistiques/simple_stat_card.dart';

class StatsMatchsOnglet extends StatelessWidget {
  const StatsMatchsOnglet({super.key});

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
          SimpleStatCard(title: 'Matchs vus', value: '128', icon: Icons.sports),
          SimpleStatCard(
              title: 'Moy. buts / match', value: '2.7', icon: Icons.bar_chart),
          PodiumCard(
            title: 'Plus gros score',
            items: const [],
            labelExtractor: (_) => '6 - 3',
            valueExtractor: (_) => 1,
            emptyStateText: 'Aucun match',
          ),
          PodiumCard(
            title: 'Plus gros écart',
            items: const [],
            labelExtractor: (_) => '5 - 0',
            valueExtractor: (_) => 1,
            emptyStateText: 'Aucun match',
          ),
          SimpleStatCard(
              title: 'Diff. buts moyenne',
              value: '1.3',
              icon: Icons.compare_arrows),
          GraphCard(
            title: 'Résultats (domicile / nul / extérieur)',
          ),
          GraphCard(
            title: 'Clubs vs Internationaux',
          ),
        ],
      ),
    );
  }
}
