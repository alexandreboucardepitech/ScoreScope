import 'package:flutter/material.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/services/web/web_app_user_repository.dart';
import 'package:scorescope/utils/stats/stats_loading_state.dart';

class StatsDataLoader {
  static const int _batchSize = 20;

  final void Function(StatsLoadingState) onStateChanged;

  StatsLoadingState _state;

  StatsDataLoader({
    required String userId,
    required bool onlyPublic,
    required DateTimeRange? dateRange,
    required this.onStateChanged,
  }) : _state = StatsLoadingState.initial(
          userId: userId,
          onlyPublic: onlyPublic,
          dateRange: dateRange,
        );

  Future<void> load() async {
    try {
      await _phase1FetchMatchIds();
      await _phase2FetchMatchData();
      await _phase3FetchEntities();
      await _phase4AssembleModels();
    } catch (e, stackTrace) {
      debugPrint('[StatsDataLoader] Erreur : $e\n$stackTrace');
      _emit(_state.copyWith(
        phase: StatsLoadingPhase.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _phase1FetchMatchIds() async {
    _emit(_state.copyWith(phase: StatsLoadingPhase.fetchingMatchIds));

    final matchIds = await WebAppUserRepository().getUserMatchsRegardesId(
      userId: _state.userId,
      onlyPublic: _state.onlyPublic,
      dateRange: _state.dateRange,
    );

    _emit(_state.copyWith(matchIds: matchIds));
  }

  Future<void> _phase2FetchMatchData() async {
    _emit(_state.copyWith(phase: StatsLoadingPhase.fetchingMatchData));

    // Les deux fetchs sont lancés en parallèle.
    final results = await Future.wait([
      _fetchMatchModelIdsWithProgress(_state.matchIds),
      WebAppUserRepository().fetchUserAllMatchUserData(
        userId: _state.userId,
        onlyPublic: _state.onlyPublic,
        dateRange: _state.dateRange,
      ),
    ]);

    final matchModelIds = results[0] as List<MatchModelId>;
    final matchUserData = results[1] as List<MatchUserData>;

    _emit(_state.copyWith(
      matchModelIds: matchModelIds,
      matchUserData: matchUserData,
    ));
  }

  Future<void> _phase3FetchEntities() async {
    _emit(_state.copyWith(phase: StatsLoadingPhase.fetchingEntities));

    final equipeIds = _extractUniqueEquipeIds(_state.matchModelIds);
    final competitionIds = _extractUniqueCompetitionIds(_state.matchModelIds);
    final joueurIds =
        _extractUniqueJoueurIds(_state.matchModelIds, _state.matchUserData);

    debugPrint(
      '[StatsDataLoader] Entités à charger : '
      '${equipeIds.length} équipes, '
      '${competitionIds.length} compétitions, '
      '${joueurIds.length} joueurs',
    );

    final caches = await Future.wait([
      _fetchEquipes(equipeIds),
      _fetchCompetitions(competitionIds),
      _fetchJoueurs(joueurIds),
    ]);

    _emit(_state.copyWith(
      equipeCache: caches[0] as Map<String, Equipe>,
      competitionCache: caches[1] as Map<String, Competition>,
      joueurCache: caches[2] as Map<String, Joueur>,
    ));
  }

  Future<void> _phase4AssembleModels() async {
    _emit(_state.copyWith(phase: StatsLoadingPhase.assemblingModels));

    final matchModels = await _assembleMatchModels(
      matchModelIds: _state.matchModelIds,
      equipeCache: _state.equipeCache,
      competitionCache: _state.competitionCache,
      joueurCache: _state.joueurCache,
    );

    _emit(_state.copyWith(
      phase: StatsLoadingPhase.ready,
      matchModels: matchModels,
    ));
  }

  Future<List<MatchModelId>> _fetchMatchModelIdsWithProgress(
      List<String> ids) async {
    final results = <MatchModelId>[];
    int loaded = 0;

    for (int i = 0; i < ids.length; i += _batchSize) {
      final batch = ids.skip(i).take(_batchSize).toList();

      final batchResults = await Future.wait(
        batch.map((id) =>
            RepositoryProvider.matchRepository.fetchMatchModelIdById(id)),
      );

      for (final result in batchResults) {
        if (result != null) results.add(result);
      }

      loaded += batch.length;
      _emit(_state.copyWith(matchModelIdsLoaded: loaded));
    }

    return results;
  }

  Future<Map<String, Equipe>> _fetchEquipes(Set<String> ids) async {
    final entries = await Future.wait(
      ids.map((id) async {
        final equipe =
            await RepositoryProvider.equipeRepository.fetchEquipeById(id);
        return equipe != null ? MapEntry(id, equipe) : null;
      }),
    );
    return Map.fromEntries(entries.whereType<MapEntry<String, Equipe>>());
  }

  Future<Map<String, Competition>> _fetchCompetitions(Set<String> ids) async {
    final entries = await Future.wait(
      ids.map((id) async {
        final competition = await RepositoryProvider.competitionRepository
            .fetchCompetitionById(id);
        return competition != null ? MapEntry(id, competition) : null;
      }),
    );
    return Map.fromEntries(entries.whereType<MapEntry<String, Competition>>());
  }

  Future<Map<String, Joueur>> _fetchJoueurs(Set<String> ids) async {
    final entries = await Future.wait(
      ids.map((id) async {
        final joueur =
            await RepositoryProvider.joueurRepository.fetchJoueurById(id);
        return joueur != null ? MapEntry(id, joueur) : null;
      }),
    );
    return Map.fromEntries(entries.whereType<MapEntry<String, Joueur>>());
  }

  Set<String> _extractUniqueEquipeIds(List<MatchModelId> matchModelIds) {
    final ids = <String>{};
    for (final match in matchModelIds) {
      ids.add(match.equipeDomicileId);
      ids.add(match.equipeExterieurId);
    }
    return ids;
  }

  Set<String> _extractUniqueCompetitionIds(List<MatchModelId> matchModelIds) {
    return matchModelIds.map((m) => m.competitionId).toSet();
  }

  Set<String> _extractUniqueJoueurIds(
    List<MatchModelId> matchModelIds,
    List<MatchUserData> matchUserData,
  ) {
    final ids = <String>{};

    for (final match in matchModelIds) {
      for (final but in match.butsEquipeDomicileId) {
        ids.add(but.buteurId);
      }
      for (final but in match.butsEquipeExterieurId) {
        ids.add(but.buteurId);
      }
      for (final joueur in match.joueursEquipeDomicileId) {
        ids.add(joueur.joueurId);
      }
      for (final joueur in match.joueursEquipeExterieurId) {
        ids.add(joueur.joueurId);
      }
    }

    for (final userData in matchUserData) {
      if (userData.mvpVoteId != null) {
        ids.add(userData.mvpVoteId!);
      }
    }

    return ids;
  }

  Future<List<MatchModel>> _assembleMatchModels({
    required List<MatchModelId> matchModelIds,
    required Map<String, Equipe> equipeCache,
    required Map<String, Competition> competitionCache,
    required Map<String, Joueur> joueurCache,
  }) async {
    final futures = matchModelIds.map((matchId) async {
      final equipeDomicile = equipeCache[matchId.equipeDomicileId];
      final equipeExterieur = equipeCache[matchId.equipeExterieurId];
      final competition = competitionCache[matchId.competitionId];

      if (equipeDomicile == null ||
          equipeExterieur == null ||
          competition == null) {
        debugPrint(
            '[StatsDataLoader] Match ${matchId.id} ignoré : entité manquante');
        return null;
      }

      // Future.wait résout tous les buts et joueurs en parallèle pour ce match.
      final results = await Future.wait([
        Future.wait(
          matchId.butsEquipeDomicileId.map((butId) async {
            final buteur = joueurCache[butId.buteurId];
            if (buteur == null) return null;
            return await But.fromButId(butId, buteurDejaCharge: buteur);
          }),
        ),
        Future.wait(
          matchId.butsEquipeExterieurId.map((butId) async {
            final buteur = joueurCache[butId.buteurId];
            if (buteur == null) return null;
            return await But.fromButId(butId, buteurDejaCharge: buteur);
          }),
        ),
        Future.wait(
          matchId.joueursEquipeDomicileId.map((joueurMatchId) async {
            final joueur = joueurCache[joueurMatchId.joueurId];
            return await MatchJoueur.fromMatchJoueurId(joueurMatchId,
                joueurDejaCharge: joueur);
          }),
        ),
        Future.wait(
          matchId.joueursEquipeExterieurId.map((joueurMatchId) async {
            final joueur = joueurCache[joueurMatchId.joueurId];
            return await MatchJoueur.fromMatchJoueurId(joueurMatchId,
                joueurDejaCharge: joueur);
          }),
        ),
      ]);

      final butsEquipeDomicile = (results[0] as List).whereType<But>().toList();
      final butsEquipeExterieur =
          (results[1] as List).whereType<But>().toList();
      final joueursEquipeDomicile =
          (results[2] as List).whereType<MatchJoueur>().toList();
      final joueursEquipeExterieur =
          (results[3] as List).whereType<MatchJoueur>().toList();

      return MatchModel(
        id: matchId.id,
        status: matchId.status,
        liveMinute: matchId.liveMinute,
        extraTime: matchId.extraTime,
        saison: matchId.saison,
        equipeDomicile: equipeDomicile,
        equipeExterieur: equipeExterieur,
        competition: competition,
        date: matchId.date,
        refereeName: matchId.refereeName,
        stadiumName: matchId.stadiumName,
        scoreEquipeDomicile: matchId.scoreEquipeDomicile,
        scoreEquipeExterieur: matchId.scoreEquipeExterieur,
        butsEquipeDomicile: butsEquipeDomicile,
        butsEquipeExterieur: butsEquipeExterieur,
        joueursEquipeDomicile: joueursEquipeDomicile,
        joueursEquipeExterieur: joueursEquipeExterieur,
        mvpVotes: matchId.mvpVotes,
        notes: matchId.notes,
      );
    });

    final assembled =
        (await Future.wait(futures)).whereType<MatchModel>().toList();

    debugPrint(
      '[StatsDataLoader] Assemblage terminé : '
      '${assembled.length} / ${matchModelIds.length} matchs assemblés.',
    );

    return assembled;
  }

  void _emit(StatsLoadingState newState) {
    _state = newState;
    onStateChanged(newState);
  }
}
