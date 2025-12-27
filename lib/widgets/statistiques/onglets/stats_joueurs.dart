import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/widgets/statistiques/podium_card.dart';

class StatsJoueursOnglet extends StatelessWidget {
  const StatsJoueursOnglet({super.key});

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
          PodiumCard<Joueur>(
            title: 'Buteurs les plus vus',
            items: const [],
            labelExtractor: (j) => j.shortName,
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun joueur',
          ),
          PodiumCard<Joueur>(
            title: 'Titularisations',
            items: const [],
            labelExtractor: (j) => j.shortName,
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun joueur',
          ),
          PodiumCard<Joueur>(
            title: 'MVP les plus votés',
            items: const [],
            labelExtractor: (j) => j.shortName,
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun MVP',
          ),
          PodiumCard<Joueur>(
            title: 'Record de buts sur un match',
            items: const [],
            labelExtractor: (j) => j.shortName,
            valueExtractor: (_) => 0,
            emptyStateText: 'Aucun record',
          ),
        ],
      ),
    );
  }
}
