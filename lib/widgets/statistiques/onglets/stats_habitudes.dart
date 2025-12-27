import 'package:flutter/material.dart';
import 'package:scorescope/widgets/statistiques/graph_card.dart';
import 'package:scorescope/widgets/statistiques/podium_card.dart';
import 'package:scorescope/widgets/statistiques/simple_stat_card.dart';

class StatsHabitudesOnglet extends StatelessWidget {
  const StatsHabitudesOnglet({super.key});

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
            title: 'MVP les plus votés',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun MVP',
          ),
          SimpleStatCard(title: 'Note moyenne', value: '7.4', icon: Icons.star),
          PodiumCard(
            title: 'Matchs les mieux notés',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun match',
          ),
          GraphCard(
            title: 'Types de visionnage',
          ),
          PodiumCard(
            title: 'Matchs les + commentés',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun match',
          ),
          PodiumCard(
            title: 'Matchs les + réactions',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun match',
          ),
          PodiumCard(
            title: 'Jour le + actif',
            items: const [],
            labelExtractor: (_) => '',
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucune donnée',
          ),
          GraphCard(
            title: 'Matchs par jour',
          ),
        ],
      ),
    );
  }
}
