import 'package:flutter/material.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

enum StatsLoadingPhase {
  idle,
  fetchingMatchIds,
  fetchingMatchData,
  fetchingEntities,
  assemblingModels,
  ready,
  error,
}

class StatsLoadingState {
  final StatsLoadingPhase phase;
  final String? errorMessage;
  final List<String> matchIds;
  final int matchModelIdsLoaded;
  final int entitiesLoaded;
  final int entitiesTotal;
  final List<MatchModelId> matchModelIds;
  final List<MatchUserData> matchUserData;
  final Map<String, Equipe> equipeCache;
  final Map<String, Competition> competitionCache;
  final Map<String, Joueur> joueurCache;
  final List<MatchModel> matchModels;
  final String userId;
  final bool onlyPublic;
  final DateTimeRange? dateRange;

  const StatsLoadingState({
    required this.phase,
    required this.userId,
    required this.onlyPublic,
    required this.dateRange,
    this.errorMessage,
    this.matchIds = const [],
    this.matchModelIdsLoaded = 0,
    this.entitiesLoaded = 0,
    this.entitiesTotal = 0,
    this.matchModelIds = const [],
    this.matchUserData = const [],
    this.equipeCache = const {},
    this.competitionCache = const {},
    this.joueurCache = const {},
    this.matchModels = const [],
  });

  factory StatsLoadingState.initial({
    required String userId,
    required bool onlyPublic,
    required DateTimeRange? dateRange,
  }) {
    return StatsLoadingState(
      phase: StatsLoadingPhase.idle,
      userId: userId,
      onlyPublic: onlyPublic,
      dateRange: dateRange,
    );
  }

  bool get isLoading =>
      phase != StatsLoadingPhase.ready &&
      phase != StatsLoadingPhase.error &&
      phase != StatsLoadingPhase.idle;

  bool get isReady => phase == StatsLoadingPhase.ready;

  int get matchIdsTotal => matchIds.length;

  String get loadingLabel {
    switch (phase) {
      case StatsLoadingPhase.idle:
        return translate.enAttente;
      case StatsLoadingPhase.fetchingMatchIds:
        return translate.recuperationDesMatchs;
      case StatsLoadingPhase.fetchingMatchData:
        return translate.chargementDesMatchsXSurX(
            matchModelIdsLoaded.toString(), matchIdsTotal.toString());
      case StatsLoadingPhase.fetchingEntities:
        return translate.chargementDesEquipesEtDesJoueurs;
      case StatsLoadingPhase.assemblingModels:
        return translate.preparationDesStatistiques;
      case StatsLoadingPhase.ready:
        return translate.pret;
      case StatsLoadingPhase.error:
        return translate.erreur +
            " : " +
            (errorMessage ?? 'Une erreur inconnue est survenue');
    }
  }

  StatsLoadingState copyWith({
    StatsLoadingPhase? phase,
    String? errorMessage,
    String? userId,
    bool? onlyPublic,
    DateTimeRange? dateRange,
    List<String>? matchIds,
    int? matchModelIdsLoaded,
    int? entitiesLoaded,
    int? entitiesTotal,
    List<MatchModelId>? matchModelIds,
    List<MatchUserData>? matchUserData,
    Map<String, Equipe>? equipeCache,
    Map<String, Competition>? competitionCache,
    Map<String, Joueur>? joueurCache,
    List<MatchModel>? matchModels,
  }) {
    return StatsLoadingState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      onlyPublic: onlyPublic ?? this.onlyPublic,
      dateRange: dateRange ?? this.dateRange,
      matchIds: matchIds ?? this.matchIds,
      matchModelIdsLoaded: matchModelIdsLoaded ?? this.matchModelIdsLoaded,
      entitiesLoaded: entitiesLoaded ?? this.entitiesLoaded,
      entitiesTotal: entitiesTotal ?? this.entitiesTotal,
      matchModelIds: matchModelIds ?? this.matchModelIds,
      matchUserData: matchUserData ?? this.matchUserData,
      equipeCache: equipeCache ?? this.equipeCache,
      competitionCache: competitionCache ?? this.competitionCache,
      joueurCache: joueurCache ?? this.joueurCache,
      matchModels: matchModels ?? this.matchModels,
    );
  }
}
