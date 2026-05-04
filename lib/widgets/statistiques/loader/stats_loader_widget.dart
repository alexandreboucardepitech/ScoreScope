import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/onglets/stats_competitions_data.dart';
import 'package:scorescope/models/stats/onglets/stats_equipes_data.dart';
import 'package:scorescope/models/stats/onglets/stats_generales_data.dart';
import 'package:scorescope/models/stats/onglets/stats_habitudes_data.dart';
import 'package:scorescope/models/stats/onglets/stats_joueurs_data.dart';
import 'package:scorescope/models/stats/onglets/stats_matchs_data.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/utils/stats/stats_loader.dart';
import 'package:scorescope/utils/stats/stats_loading_state.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_competitions.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_equipes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_generales.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_habitudes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_joueurs.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_matchs.dart';

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
  final StatsOnglet onglet;
  final AppUser user;

  final StatsLoadingState? statsState;

  const StatsLoaderWidget({
    super.key,
    required this.showCards,
    required this.onglet,
    required this.user,
    required this.statsState,
  });

  @override
  State<StatsLoaderWidget> createState() => _StatsLoaderWidgetState();
}

class _StatsLoaderWidgetState extends State<StatsLoaderWidget> {
  Future<dynamic>? _computeFuture;
  StatsLoadingState? _lastComputedState;

  @override
  void initState() {
    super.initState();
    final state = widget.statsState;
    if (state != null && state.isReady) {
      _lastComputedState = state;
      _computeFuture = _computeStats(state);
    }
  }

  @override
  void didUpdateWidget(covariant StatsLoaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final state = widget.statsState;

    if (state != null &&
        state.isReady &&
        !identical(state, _lastComputedState)) {
      _lastComputedState = state;
      _computeFuture = _computeStats(state);
    }

    if (state != null && state.isLoading) {
      _computeFuture = null;
      _lastComputedState = null;
    }
  }

  Future<dynamic> _computeStats(StatsLoadingState state) {
    switch (widget.onglet) {
      case StatsOnglet.generales:
        return _computeGenerales(state);
      case StatsOnglet.matchs:
        return _computeMatchs(state);
      case StatsOnglet.equipes:
        return _computeEquipes(state);
      case StatsOnglet.joueurs:
        return _computeJoueurs(state);
      case StatsOnglet.competitions:
        return _computeCompetitions(state);
      case StatsOnglet.habitudes:
        return _computeHabitudes(state);
    }
  }

  Future<StatsGeneralesData> _computeGenerales(StatsLoadingState state) async {
    final matchModels = state.matchModels;
    final matchUserData = state.matchUserData;

    final nbButsVus = StatsLoader.getNbButsVus(matchsVusModels: matchModels);
    final buteursDifferents =
        await StatsLoader.getMeilleursButeurs(matchModels);
    final equipesDifferentes =
        await StatsLoader.getEquipesLesPlusVues(matchModels);
    final competitionsDifferentes =
        await StatsLoader.getCompetitionsLesPlusVues(matchModels);

    return StatsGeneralesData(
      matchsVus: matchModels.length,
      butsVus: nbButsVus,
      moyenneButsParMatch:
          matchModels.isNotEmpty ? nbButsVus / matchModels.length : 0,
      nbButeursDifferents: buteursDifferents.length,
      nbEquipesDifferentes: equipesDifferentes.length,
      nbCompetitionsDifferentes: competitionsDifferentes.length,
      moyenneNotes: StatsLoader.getMoyenneNotes(matchsVusUser: matchUserData),
      meilleursButeurs:
          await StatsLoader.getPodiumFromMap<Joueur>(buteursDifferents),
      equipesLesPlusVues:
          await StatsLoader.getPodiumFromMap<Equipe>(equipesDifferentes),
      competitionsLesPlusSuivies:
          await StatsLoader.getPodiumFromMap<Competition>(
              competitionsDifferentes),
      mvpsLesPlusVotes:
          await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchUserData),
    );
  }

  Future<StatsMatchsData> _computeMatchs(StatsLoadingState state) async {
    final matchModels = state.matchModels;

    final nbButsVus = StatsLoader.getNbButsVus(matchsVusModels: matchModels);

    return StatsMatchsData(
      matchsVus: matchModels.length,
      moyenneButsParMatch:
          matchModels.isNotEmpty ? nbButsVus / matchModels.length : 0,
      biggestScores: StatsLoader.getBiggestScoresMatch(matchModels),
      biggestScoresDifference:
          StatsLoader.getBiggestScoreDifferenceMatch(matchModels),
      moyenneDiffButsParMatch:
          StatsLoader.getMoyenneDifferenceButsParMatch(matchModels),
      pourcentageVictoireDomExt:
          StatsLoader.getPourcentageVictoireDomExt(matchModels),
      pourcentageClubsInternationaux: [
        StatValue(label: "Clubs", value: 50),
        StatValue(label: "International", value: 50),
      ],
    );
  }

  Future<StatsEquipesData> _computeEquipes(StatsLoadingState state) async {
    final matchModels = state.matchModels;

    final equipesDifferentes =
        await StatsLoader.getEquipesLesPlusVues(matchModels);

    final equipesLesPlusVuesGagner =
        await StatsLoader.getEquipesLesPlusVuesGagner(matchModels);

    return StatsEquipesData(
      equipesLesPlusVues:
          await StatsLoader.getPodiumFromMap<Equipe>(equipesDifferentes),
      nbEquipesDifferentes: equipesDifferentes.length,
      equipesLesPlusVuesGagner: equipesLesPlusVuesGagner,
      equipesLesPlusVuesPerdre:
          await StatsLoader.getEquipesLesPlusVuesPerdre(matchModels),
      equipesPlusDeButsMarques:
          await StatsLoader.getEquipesLesPlusVuesMarquer(matchModels),
      equipesPlusDeButsEncaisses:
          await StatsLoader.getEquipesLesPlusVuesEncaisser(matchModels),
      pourcentageVictoiresParEquipe:
          await StatsLoader.getPourcentageVictoiresParEquipe(
        equipesDifferentes: equipesDifferentes,
        equipesLesPlusVuesGagner: equipesLesPlusVuesGagner,
      ),
    );
  }

  Future<StatsJoueursData> _computeJoueurs(StatsLoadingState state) async {
    final matchModels = state.matchModels;
    final matchUserData = state.matchUserData;

    final buteursDifferents =
        await StatsLoader.getMeilleursButeurs(matchModels);
    final passeursDifferents =
        await StatsLoader.getMeilleursPasseurs(matchModels);
    final gAsDifferents = await StatsLoader.getMeilleursGAs(matchModels);
    final titularisations = await StatsLoader.getTitularisations(matchModels);
    final meilleursButeursUnMatch =
        await StatsLoader.getMeilleursButeursUnMatch(matchModels);

    final mvpsParJoueur = await StatsLoader.getMvpsLesPlusVotes(
      matchsVusUser: matchUserData,
      joueursCache: state.joueurCache,
    );

    Map<Joueur, int> mapMvpParJoueur = {};

    for (PodiumEntry<Joueur> podiumJoueur in mvpsParJoueur) {
      mapMvpParJoueur[podiumJoueur.item] = podiumJoueur.value.toInt();
    }

    return StatsJoueursData(
      meilleursButeurs:
          await StatsLoader.getPodiumFromMap<Joueur>(buteursDifferents),
      meilleursPasseurs:
          await StatsLoader.getPodiumFromMap<Joueur>(passeursDifferents),
      meilleursGAs: await StatsLoader.getPodiumFromMap<Joueur>(gAsDifferents),
      titularisations:
          await StatsLoader.getPodiumFromMap<Joueur>(titularisations),
      mvpsLesPlusVotes: mvpsParJoueur,
      meilleursButeursUnMatch:
          await StatsLoader.getPodiumFromMap<Joueur>(meilleursButeursUnMatch),
      butsMvpParJoueur: await StatsLoader.getButsEtMvpsParJoueur(
        butsParJoueur: buteursDifferents,
        mvpsParJoueur: mapMvpParJoueur,
        equipesCache: state.equipeCache,
      ),
    );
  }

  Future<StatsCompetitionsData> _computeCompetitions(
      StatsLoadingState state) async {
    final matchModels = state.matchModels;

    final competitionsDifferentes =
        await StatsLoader.getCompetitionsLesPlusVues(matchModels);

    return StatsCompetitionsData(
      competitionsLesPlusSuivies:
          await StatsLoader.getPodiumFromMap<Competition>(
              competitionsDifferentes),
      nbCompetitionsDifferentes: competitionsDifferentes.length,
      butsParCompetition: await StatsLoader.getButsParCompetition(matchModels),
      competitionsMoyButs:
          await StatsLoader.getMoyenneButsParMatchParCompetition(matchModels),
      pourcentageMatchsCompetitions:
          StatsLoader.getPourcentageMatchsCompetitions(matchModels),
      typesCompetitions: [
        StatValue(label: "Clubs", value: 50),
        StatValue(label: "International", value: 50),
      ],
    );
  }

  Future<StatsHabitudesData> _computeHabitudes(StatsLoadingState state) async {
    final matchUserData = state.matchUserData;

    final matchCache = {for (final m in state.matchModels) m.id: m};

    return StatsHabitudesData(
      mvpsLesPlusVotes:
          await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchUserData),
      moyenneNotes: StatsLoader.getMoyenneNotes(matchsVusUser: matchUserData),
      matchsMieuxNotes: await StatsLoader.getMatchsMieuxNotes(
        matchsVusUser: matchUserData,
        matchCache: matchCache,
      ),
      matchsPlusCommentes: await StatsLoader.getMatchsPlusCommentes(
        matchsVusUser: matchUserData,
        matchCache: matchCache,
      ),
      matchsPlusReactions: await StatsLoader.getMatchsPlusReactions(
        matchsVusUser: matchUserData,
        matchCache: matchCache,
      ),
      joursLePlusDeMatchs: await StatsLoader.getJoursAvecLePlusDeMatchs(
        matchsVusUser: matchUserData,
      ),
      typeVisionnage:
          await StatsLoader.getTypeVisionnage(matchsVusUser: matchUserData),
      matchsVusParMois:
          await StatsLoader.getMatchsVusParMois(matchsVusUser: matchUserData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.statsState;

    if (state == null || state.isLoading) {
      return _buildLoadingScreen(context, state);
    }

    if (state.phase == StatsLoadingPhase.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Erreur lors du chargement des statistiques.\n${state.errorMessage ?? ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: ColorPalette.textPrimary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return FutureBuilder<dynamic>(
      future: _computeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur lors du calcul des statistiques.',
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final data = snapshot.data;
        switch (widget.onglet) {
          case StatsOnglet.generales:
            return StatsGeneralesOnglet(
              showCards: widget.showCards,
              data: data as StatsGeneralesData,
              user: widget.user,
            );
          case StatsOnglet.matchs:
            return StatsMatchsOnglet(
              showCards: widget.showCards,
              data: data as StatsMatchsData,
              user: widget.user,
            );
          case StatsOnglet.equipes:
            return StatsEquipesOnglet(
              showCards: widget.showCards,
              data: data as StatsEquipesData,
              user: widget.user,
            );
          case StatsOnglet.joueurs:
            return StatsJoueursOnglet(
              showCards: widget.showCards,
              data: data as StatsJoueursData,
              user: widget.user,
            );
          case StatsOnglet.competitions:
            return StatsCompetitionsOnglet(
              showCards: widget.showCards,
              data: data as StatsCompetitionsData,
              user: widget.user,
            );
          case StatsOnglet.habitudes:
            return StatsHabitudesOnglet(
              showCards: widget.showCards,
              data: data as StatsHabitudesData,
              user: widget.user,
            );
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, StatsLoadingState? state) {
    final phase = state?.phase;
    final isMatchDataPhase = phase == StatsLoadingPhase.fetchingMatchData;
    final total = state?.matchIdsTotal ?? 0;
    final loaded = state?.matchModelIdsLoaded ?? 0;
    final progress = (total > 0 && isMatchDataPhase) ? loaded / total : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                color: ColorPalette.buttonPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              state?.loadingLabel ?? 'Chargement…',
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (isMatchDataPhase && total > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  color: ColorPalette.buttonPrimary(context),
                  backgroundColor: ColorPalette.surface(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$loaded / $total matchs',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorPalette.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
