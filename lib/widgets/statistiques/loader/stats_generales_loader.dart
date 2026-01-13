import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/stats_generales_data.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_generales.dart';

class StatsGeneralesLoader extends StatefulWidget {
  final bool showCards;

  const StatsGeneralesLoader({
    super.key,
    required this.showCards,
  });

  @override
  State<StatsGeneralesLoader> createState() => _StatsGeneralesLoaderState();
}

class _StatsGeneralesLoaderState extends State<StatsGeneralesLoader> {
  late Future<StatsGeneralesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadStatsGenerales();
  }

  Future<StatsGeneralesData> _loadStatsGenerales() async {
    // ⛔ TEMPORAIRE
    // Plus tard :
    // return statsRepository.fetchStatsGenerales();

    await Future.delayed(const Duration(milliseconds: 600));

    return const StatsGeneralesData(
      matchsVus: 128,
      butsVus: 342,
      moyenneButsParMatch: 2.7,
      nbButeursDifferents: 58,
      nbEquipesDifferentes: 42,
      nbCompetitionsDifferentes: 12,
      moyenneNotes: 7.4,
      equipesLesPlusVues: [],
      competitionsLesPlusSuivies: [],
      meilleursButeurs: [],
      mvpsLesPlusVotes: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StatsGeneralesData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur lors du chargement des statistiques',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final data = snapshot.data!;
        return StatsGeneralesOnglet(
          showCards: widget.showCards,
          data: data,
        );
      },
    );
  }
}
