import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/stats_competitions_data.dart';
import 'package:scorescope/models/stats/stats_equipes_data.dart';
import 'package:scorescope/models/stats/stats_habitudes_data.dart';
import 'package:scorescope/models/stats/stats_joueurs_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_competitions.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_equipes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_generales.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_habitudes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_joueurs.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_matchs.dart';
import 'package:scorescope/models/stats/stats_generales_data.dart';
import 'package:scorescope/models/stats/stats_matchs_data.dart';

enum StatsOnglet {
  generales,
  matchs,
  equipes,
  joueurs,
  competitions,
  habitudes,
}

class StatsLoaderWidget extends StatefulWidget {
  final bool showCards;
  final bool onlyPublicMatches;
  final DateTimeRange? dateRange;
  final StatsOnglet onglet;

  const StatsLoaderWidget({
    super.key,
    required this.showCards,
    required this.onlyPublicMatches,
    required this.dateRange,
    required this.onglet,
  });

  @override
  State<StatsLoaderWidget> createState() => _StatsLoaderWidgetState();
}

class _StatsLoaderWidgetState extends State<StatsLoaderWidget> {
  late Future<dynamic> _future;

  @override
  void didUpdateWidget(covariant StatsLoaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.onlyPublicMatches != widget.onlyPublicMatches) {
      _future = _loadStats();
    }

    if (oldWidget.dateRange != widget.dateRange) {
      _future = _loadStats();
    }
  }

  @override
  void initState() {
    super.initState();
    _future = _loadStats();
  }

  Future<dynamic> _loadStats() async {
    final currentUser =
        await RepositoryProvider.userRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    switch (widget.onglet) {
      case StatsOnglet.generales:
        return RepositoryProvider.statsRepository.fetchStatsGenerales(
            currentUser.uid, widget.onlyPublicMatches, widget.dateRange);
      case StatsOnglet.matchs:
        return RepositoryProvider.statsRepository.fetchStatsMatchs(
            currentUser.uid, widget.onlyPublicMatches, widget.dateRange);
      case StatsOnglet.equipes:
        return RepositoryProvider.statsRepository.fetchStatsEquipes(
            currentUser.uid, widget.onlyPublicMatches, widget.dateRange);
      case StatsOnglet.joueurs:
        return RepositoryProvider.statsRepository.fetchStatsJoueurs(
            currentUser.uid, widget.onlyPublicMatches, widget.dateRange);
      case StatsOnglet.competitions:
        return RepositoryProvider.statsRepository.fetchStatsCompetitions(
            currentUser.uid, widget.onlyPublicMatches, widget.dateRange);
      case StatsOnglet.habitudes:
        return RepositoryProvider.statsRepository.fetchStatsHabitudes(
            currentUser.uid, widget.onlyPublicMatches, widget.dateRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur lors du chargement des statistiques',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final data = snapshot.data;
        switch (widget.onglet) {
          case StatsOnglet.generales:
            return StatsGeneralesOnglet(
              showCards: widget.showCards,
              data: data as StatsGeneralesData,
            );
          case StatsOnglet.matchs:
            return StatsMatchsOnglet(
              showCards: widget.showCards,
              data: data as StatsMatchsData,
            );
          case StatsOnglet.equipes:
            return StatsEquipesOnglet(
              showCards: widget.showCards,
              data: data as StatsEquipesData,
            );
          case StatsOnglet.joueurs:
            return StatsJoueursOnglet(
              showCards: widget.showCards,
              data: data as StatsJoueursData,
            );
          case StatsOnglet.competitions:
            return StatsCompetitionsOnglet(
              showCards: widget.showCards,
              data: data as StatsCompetitionsData,
            );
          case StatsOnglet.habitudes:
            return StatsHabitudesOnglet(
              showCards: widget.showCards,
              data: data as StatsHabitudesData,
            );
        }
      },
    );
  }
}
