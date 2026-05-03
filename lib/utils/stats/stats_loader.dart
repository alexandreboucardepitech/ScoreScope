import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/graph/stat_value_duo.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/models/stats/player_stats.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/stats/team_stats.dart';
import 'package:scorescope/models/util/day_podium_displayable.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/utils/string/round_smart.dart';

class StatsLoader {
  const StatsLoader._(); // empêche l'instanciation

  static Future<Map<Joueur, int>> getMeilleursButeurs(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Joueur> joueurById = {};

    for (final match in matchsVusModels) {
      final List<But> butsDuMatch =
          match.butsEquipeDomicile + match.butsEquipeExterieur;
      for (var but in butsDuMatch) {
        if (but.typeBut == TypeBut.owngoal) continue;
        final id = but.buteur.id;
        countById[id] = (countById[id] ?? 0) + 1;
        joueurById[id] = but.buteur;
      }
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.map(
        (e) => MapEntry(joueurById[e.key]!, e.value),
      ),
    );
  }

  static Future<Map<Joueur, int>> getTitularisations(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Joueur> joueurById = {};

    for (final match in matchsVusModels) {
      List<MatchJoueur> joueursDuMatch =
          match.joueursEquipeDomicile + match.joueursEquipeExterieur;

      joueursDuMatch =
          joueursDuMatch.where((joueur) => joueur.hasPlayed == true).toList();

      for (var joueurMatch in joueursDuMatch) {
        if (joueurMatch.joueur != null) {
          final id = joueurMatch.joueur!.id;
          countById[id] = (countById[id] ?? 0) + 1;
          joueurById[id] = joueurMatch.joueur!;
        }
      }
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.map(
        (e) => MapEntry(joueurById[e.key]!, e.value),
      ),
    );
  }

  static Future<Map<Equipe, int>> getEquipesLesPlusVues(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Equipe> equipeById = {};

    for (final match in matchsVusModels) {
      countById[match.equipeDomicile.id] =
          (countById[match.equipeDomicile.id] ?? 0) + 1;
      countById[match.equipeExterieur.id] =
          (countById[match.equipeExterieur.id] ?? 0) + 1;
      equipeById[match.equipeDomicile.id] = match.equipeDomicile;
      equipeById[match.equipeExterieur.id] = match.equipeExterieur;
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.map(
        (e) => MapEntry(equipeById[e.key]!, e.value),
      ),
    );
  }

  static Future<Map<Competition, int>> getCompetitionsLesPlusVues(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Competition> competitionById = {};

    for (final match in matchsVusModels) {
      final id = match.competition.id;
      countById[id] = (countById[id] ?? 0) + 1;
      competitionById[id] = match.competition;
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.map(
        (e) => MapEntry(competitionById[e.key]!, e.value),
      ),
    );
  }

  static int getNbButsVus({required List<MatchModel> matchsVusModels}) {
    if (matchsVusModels.isEmpty) return 0;
    int totalButs = 0;

    for (var match in matchsVusModels) {
      totalButs += match.scoreEquipeDomicile + match.scoreEquipeExterieur;
    }

    return totalButs;
  }

  static double getMoyenneNotes({required List<MatchUserData> matchsVusUser}) {
    if (matchsVusUser.isEmpty) return 0;
    double totalNotes = 0;
    int countNotes = 0;
    for (final matchData in matchsVusUser) {
      if (matchData.note != null) {
        totalNotes += matchData.note!;
        countNotes++;
      }
    }
    return countNotes > 0 ? totalNotes / countNotes : 0;
  }

  static Future<List<PodiumEntry<T>>>
      getPodiumFromMap<T extends PodiumDisplayable>(
    Map<T, int> dataMap,
  ) async {
    final podiumEntries = await Future.wait(
      dataMap.entries.map((entry) async {
        final color = await entry.key.getColor();
        return PodiumEntry<T>(
          item: entry.key,
          value: entry.value,
          color: color,
        );
      }),
    );

    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static Future<List<StatValue>> getStatValueListFromMap<T>({
    required Map<T, int> dataMap,
    required String Function(T) getLabel,
    required Future<String?> Function(T) getColor,
  }) async {
    final statValues = <StatValue>[];

    for (final entry in dataMap.entries) {
      final color = await getColor(entry.key);
      statValues.add(StatValue(
        label: getLabel(entry.key),
        value: entry.value,
        color: color,
      ));
    }

    statValues.sort((a, b) => b.value.compareTo(a.value));
    return statValues;
  }

  static Future<List<PodiumEntry<Joueur>>> getMvpsLesPlusVotes(
      {required List<MatchUserData> matchsVusUser,
      Map<String, Joueur>? joueursCache}) async {
    Map<String, int> mvpsCount = {};

    for (final matchData in matchsVusUser) {
      if (matchData.mvpVoteId != null) {
        mvpsCount[matchData.mvpVoteId!] =
            (mvpsCount[matchData.mvpVoteId!] ?? 0) + 1;
      }
    }

    final podiumEntries = await Future.wait(
      mvpsCount.entries.map((entry) async {
        final joueur = joueursCache == null || joueursCache[entry.key] == null
            ? await RepositoryProvider.joueurRepository
                .fetchJoueurById(entry.key)
            : joueursCache[entry.key];
        if (joueur == null) return null;

        final color = await joueur.getColor();
        return PodiumEntry<Joueur>(
          item: joueur,
          value: entry.value,
          color: color,
        );
      }),
    );

    return podiumEntries.whereType<PodiumEntry<Joueur>>().toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static Future<List<MatchModel>> getMatchModelsFromIds(
      List<String> matchsVusId) async {
    List<MatchModel> matchsVusModels = [];
    for (final matchId in matchsVusId) {
      final MatchModel? match =
          await RepositoryProvider.matchRepository.fetchMatchById(matchId);
      if (match != null) {
        matchsVusModels.add(match);
      }
    }
    return matchsVusModels;
  }

  static List<PodiumEntry<MatchModel>> getBiggestScoresMatch(
      List<MatchModel> matchsVusModels) {
    final podiumEntries = matchsVusModels.map((match) {
      final totalGoals =
          match.butsEquipeDomicile.length + match.butsEquipeExterieur.length;
      return PodiumEntry<MatchModel>(item: match, value: totalGoals);
    }).toList();

    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<PodiumEntry<MatchModel>> getBiggestScoreDifferenceMatch(
      List<MatchModel> matchsVusModels) {
    final podiumEntries = matchsVusModels.map((match) {
      final goalDifference =
          (match.butsEquipeDomicile.length - match.butsEquipeExterieur.length)
              .abs();
      return PodiumEntry<MatchModel>(item: match, value: goalDifference);
    }).toList();

    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static double getMoyenneDifferenceButsParMatch(
      List<MatchModel> matchsVusModels) {
    if (matchsVusModels.isEmpty) return 0.0;
    double totalDiffButs = 0.0;

    for (final match in matchsVusModels) {
      final diffButs =
          (match.butsEquipeDomicile.length - match.butsEquipeExterieur.length)
              .abs();
      totalDiffButs += diffButs;
    }

    return totalDiffButs / matchsVusModels.length;
  }

  static List<StatValue> getPourcentageVictoireDomExt(
      List<MatchModel> matchsVusModels) {
    int victoiresDomicile = 0;
    int nuls = 0;
    int victoiresExterieur = 0;

    for (final match in matchsVusModels) {
      if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
        victoiresDomicile++;
      } else if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
        victoiresExterieur++;
      } else {
        nuls++;
      }
    }

    final totalMatchs = matchsVusModels.length;
    if (totalMatchs == 0) {
      return [
        StatValue(label: "Domicile", value: 0),
        StatValue(label: "Nuls", value: 0),
        StatValue(label: "Extérieur", value: 0),
      ];
    }

    return [
      StatValue(
          label: "Domicile", value: (victoiresDomicile / totalMatchs) * 100),
      StatValue(label: "Nuls", value: (nuls / totalMatchs) * 100),
      StatValue(
          label: "Extérieur", value: (victoiresExterieur / totalMatchs) * 100),
    ];
  }

  static Future<List<PodiumEntry<Equipe>>> getEquipesLesPlusVuesGagner(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Equipe> equipeById = {};

    for (final match in matchsVusModels) {
      Equipe? gagnant;
      if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
        gagnant = match.equipeDomicile;
      } else if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
        gagnant = match.equipeExterieur;
      }

      if (gagnant != null) {
        countById[gagnant.id] = (countById[gagnant.id] ?? 0) + 1;
        equipeById[gagnant.id] = gagnant;
      }
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final podiumEntries = await Future.wait(
      sortedEntries.map((e) async {
        final equipe = equipeById[e.key]!;
        final color = await equipe.getColor();
        return PodiumEntry<Equipe>(
          item: equipe,
          value: e.value,
          color: color,
        );
      }),
    );

    return podiumEntries;
  }

  static Future<List<PodiumEntry<Equipe>>> getEquipesLesPlusVuesPerdre(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Equipe> equipeById = {};

    for (final match in matchsVusModels) {
      Equipe? perdant;
      if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
        perdant = match.equipeDomicile;
      } else if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
        perdant = match.equipeExterieur;
      }

      if (perdant != null) {
        countById[perdant.id] = (countById[perdant.id] ?? 0) + 1;
        equipeById[perdant.id] = perdant;
      }
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final podiumEntries = await Future.wait(
      sortedEntries.map((e) async {
        final equipe = equipeById[e.key]!;
        final color = await equipe.getColor();
        return PodiumEntry<Equipe>(
          item: equipe,
          value: e.value,
          color: color,
        );
      }),
    );

    return podiumEntries;
  }

  static Future<List<PodiumEntry<Equipe>>> getEquipesLesPlusVuesMarquer(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Equipe> equipeById = {};

    for (final match in matchsVusModels) {
      countById[match.equipeDomicile.id] =
          (countById[match.equipeDomicile.id] ?? 0) +
              match.butsEquipeDomicile.length;
      equipeById[match.equipeDomicile.id] = match.equipeDomicile;

      countById[match.equipeExterieur.id] =
          (countById[match.equipeExterieur.id] ?? 0) +
              match.butsEquipeExterieur.length;
      equipeById[match.equipeExterieur.id] = match.equipeExterieur;
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final podiumEntries = await Future.wait(
      sortedEntries.map((e) async {
        final equipe = equipeById[e.key]!;
        final color = await equipe.getColor();
        return PodiumEntry<Equipe>(
          item: equipe,
          value: e.value,
          color: color,
        );
      }),
    );

    return podiumEntries;
  }

  static Future<List<PodiumEntry<Equipe>>> getEquipesLesPlusVuesEncaisser(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Equipe> equipeById = {};

    for (final match in matchsVusModels) {
      countById[match.equipeExterieur.id] =
          (countById[match.equipeExterieur.id] ?? 0) +
              match.butsEquipeDomicile.length;
      equipeById[match.equipeExterieur.id] = match.equipeExterieur;

      countById[match.equipeDomicile.id] =
          (countById[match.equipeDomicile.id] ?? 0) +
              match.butsEquipeExterieur.length;
      equipeById[match.equipeDomicile.id] = match.equipeDomicile;
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final podiumEntries = await Future.wait(
      sortedEntries.map((e) async {
        final equipe = equipeById[e.key]!;
        final color = await equipe.getColor();
        return PodiumEntry<Equipe>(
          item: equipe,
          value: e.value,
          color: color,
        );
      }),
    );

    return podiumEntries;
  }

  static Future<Map<Joueur, int>> getMeilleursButeursUnMatch(
    List<MatchModel> matchsVus,
  ) async {
    final Map<String, int> bestGoalsPerMatchByPlayerId = {};
    final Map<String, Joueur> joueurById = {};

    for (final match in matchsVus) {
      final List<But> butsDuMatch =
          match.butsEquipeDomicile + match.butsEquipeExterieur;

      final Map<String, int> goalsThisMatch = {};

      for (final but in butsDuMatch) {
        goalsThisMatch[but.buteur.id] =
            (goalsThisMatch[but.buteur.id] ?? 0) + 1;
        joueurById[but.buteur.id] = but.buteur;
      }

      for (final entry in goalsThisMatch.entries) {
        final joueurId = entry.key;
        final goalsInThisMatch = entry.value;

        final currentBest = bestGoalsPerMatchByPlayerId[joueurId] ?? 0;
        if (goalsInThisMatch > currentBest) {
          bestGoalsPerMatchByPlayerId[joueurId] = goalsInThisMatch;
        }
      }
    }

    final sortedEntries = bestGoalsPerMatchByPlayerId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.map(
        (e) => MapEntry(joueurById[e.key]!, e.value),
      ),
    );
  }

  static Future<List<PodiumEntry<Competition>>> getButsParCompetition(
      List<MatchModel> matchsVusModels) async {
    final Map<String, int> countById = {};
    final Map<String, Competition> competitionById = {};

    for (final match in matchsVusModels) {
      final id = match.competition.id;
      final butsDuMatch =
          match.butsEquipeDomicile.length + match.butsEquipeExterieur.length;
      countById[id] = (countById[id] ?? 0) + butsDuMatch;
      competitionById[id] = match.competition;
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final podiumEntries = await Future.wait(
      sortedEntries.map((e) async {
        final competition = competitionById[e.key]!;
        final color = await competition.getColor();
        return PodiumEntry<Competition>(
          item: competition,
          value: e.value,
          color: color,
        );
      }),
    );

    return podiumEntries;
  }

  static Future<List<PodiumEntry<Competition>>>
      getMoyenneButsParMatchParCompetition(
    List<MatchModel> matchsVusModels,
  ) async {
    final Map<String, int> totalButs = {};
    final Map<String, int> totalMatchs = {};
    final Map<String, Competition> competitionById = {};

    for (final match in matchsVusModels) {
      final id = match.competition.id;
      final butsDuMatch =
          match.butsEquipeDomicile.length + match.butsEquipeExterieur.length;

      totalButs[id] = (totalButs[id] ?? 0) + butsDuMatch;
      totalMatchs[id] = (totalMatchs[id] ?? 0) + 1;
      competitionById[id] = match.competition;
    }
    final podiumEntries = await Future.wait(
      totalButs.entries.map((e) async {
        final competition = competitionById[e.key]!;
        final moyenne = roundSmart(e.value / totalMatchs[e.key]!);
        final color = await competition.getColor();
        num value = num.parse(moyenne);

        return PodiumEntry<Competition>(
          item: competition,
          value: value,
          color: color,
        );
      }),
    );

    final sortedEntries = podiumEntries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries;
  }

  static Future<List<PodiumEntry<MatchModel>>> getMatchsMieuxNotes({
    required List<MatchUserData> matchsVusUser,
    Map<String, MatchModel>? matchCache,
  }) async {
    final List<PodiumEntry<MatchModel>> podiumEntries = [];

    for (final matchUserData in matchsVusUser) {
      final note = matchUserData.note;
      if (note == null) continue;

      final MatchModel? match = matchCache?[matchUserData.matchId] ??
          await RepositoryProvider.matchRepository
              .fetchMatchById(matchUserData.matchId);
      if (match == null) continue;

      podiumEntries.add(
        PodiumEntry<MatchModel>(
          item: match,
          value: note,
        ),
      );
    }
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static Future<List<PodiumEntry<MatchModel>>> getMatchsPlusCommentes({
    required List<MatchUserData> matchsVusUser,
    Map<String, MatchModel>? matchCache,
  }) async {
    final List<PodiumEntry<MatchModel>> podiumEntries = [];

    for (final matchUserData in matchsVusUser) {
      if (matchUserData.comments.isEmpty) continue;
      final MatchModel? match = matchCache?[matchUserData.matchId] ??
          await RepositoryProvider.matchRepository
              .fetchMatchById(matchUserData.matchId);
      if (match == null) continue;

      podiumEntries.add(
        PodiumEntry<MatchModel>(
          item: match,
          value: matchUserData.comments.length,
        ),
      );
    }
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static Future<List<PodiumEntry<MatchModel>>> getMatchsPlusReactions({
    required List<MatchUserData> matchsVusUser,
    Map<String, MatchModel>? matchCache,
  }) async {
    final List<PodiumEntry<MatchModel>> podiumEntries = [];

    for (final matchUserData in matchsVusUser) {
      if (matchUserData.reactions.isEmpty) continue;
      final MatchModel? match = matchCache?[matchUserData.matchId] ??
          await RepositoryProvider.matchRepository
              .fetchMatchById(matchUserData.matchId);
      if (match == null) continue;

      podiumEntries.add(
        PodiumEntry<MatchModel>(
          item: match,
          value: matchUserData.reactions.length,
        ),
      );
    }
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static Future<List<PodiumEntry<DayPodiumDisplayable>>>
      getJoursAvecLePlusDeMatchs(
          {required List<MatchUserData> matchsVusUser}) async {
    final Map<DayPodiumDisplayable, int> matchsParJour = {};

    for (final matchUserData in matchsVusUser) {
      final matchDate = matchUserData.matchDate;
      if (matchDate == null) continue;
      final day = DateTime(
        matchDate.year,
        matchDate.month,
        matchDate.day,
      );
      final dayDisplayable = DayPodiumDisplayable(day);

      matchsParJour[dayDisplayable] = (matchsParJour[dayDisplayable] ?? 0) + 1;
    }

    final podiumEntries = await Future.wait(
      matchsParJour.entries.map((entry) async {
        final color = await entry.key.getColor();
        return PodiumEntry<DayPodiumDisplayable>(
          item: entry.key,
          value: entry.value,
          color: color,
        );
      }),
    );

    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<StatValue> getPourcentageMatchsCompetitions(
      List<MatchModel> matchsVusModels) {
    final Map<String, int> countById = {};
    final Map<String, Competition> competitionById = {};

    for (final match in matchsVusModels) {
      final id = match.competition.id;
      countById[id] = (countById[id] ?? 0) + 1;
      competitionById[id] = match.competition;
    }

    final sortedEntries = countById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalMatchs = matchsVusModels.length;
    if (totalMatchs == 0) {
      return [];
    }

    sortedEntries.removeWhere((entry) => entry.value == 0);

    return sortedEntries.map((e) {
      final competition = competitionById[e.key]!;

      return StatValue(
        label: competition.nom,
        value: e.value,
      );
    }).toList();
  }

  static Future<List<StatValue>> getTypeVisionnage({
    required List<MatchUserData> matchsVusUser,
  }) async {
    int stade = 0;
    int tele = 0;
    int bar = 0;

    for (final matchUserData in matchsVusUser) {
      switch (matchUserData.visionnageMatch) {
        case VisionnageMatch.stade:
          stade++;
        case VisionnageMatch.tele:
          tele++;
        case VisionnageMatch.bar:
          bar++;
      }
    }
    final totalCount = stade + tele + bar;
    if (totalCount == 0) {
      return [
        StatValue(label: "Stade", value: 0),
        StatValue(label: "Télé", value: 0),
        StatValue(label: "Bar", value: 0),
      ];
    }

    return [
      StatValue(label: "Stade", value: (stade / totalCount) * 100),
      StatValue(label: "Télé", value: (tele / totalCount) * 100),
      StatValue(label: "Bar", value: (bar / totalCount) * 100),
    ];
  }

  static Future<List<TimeStatValue>> getMatchsVusParMois({
    required List<MatchUserData> matchsVusUser,
  }) async {
    if (matchsVusUser.isEmpty) {
      return [];
    }

    final Map<DateTime, int> matchsParMois = {};

    for (final match in matchsVusUser) {
      final matchDate = match.matchDate;
      if (matchDate == null) continue;

      final monthKey = DateTime(
        matchDate.year,
        matchDate.month,
        1,
      );

      matchsParMois[monthKey] = (matchsParMois[monthKey] ?? 0) + 1;
    }

    if (matchsParMois.isEmpty) {
      return [];
    }

    final sortedMonths = matchsParMois.keys.toList()..sort();

    final firstMonth = DateTime(
      sortedMonths.first.month > 1
          ? sortedMonths.first.year
          : sortedMonths.first.year - 1,
      sortedMonths.first.month > 1 ? sortedMonths.first.month - 1 : 12,
      1,
    );
    final lastMonth = sortedMonths.last;

    final List<TimeStatValue> result = [];

    DateTime currentMonth = firstMonth;
    int? previousValue;

    while (!currentMonth.isAfter(lastMonth)) {
      final value = matchsParMois[currentMonth] ?? 0;

      result.add(
        TimeStatValue(
          period: currentMonth,
          value: value,
          delta: previousValue,
        ),
      );

      previousValue = value;

      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
        1,
      );
    }

    return result;
  }

  static List<MatchModel> getMatchsJoueur(
    List<MatchModel> matchs,
    String joueurId,
  ) {
    List<MatchModel> matchsJoueur = [];
    bool matchAjoute = false;
    for (MatchModel matchModel in matchs) {
      matchAjoute = false;
      for (MatchJoueur matchJoueur in matchModel.joueursEquipeDomicile) {
        if (matchJoueur.joueur?.id == joueurId) {
          matchsJoueur.add(matchModel);
          matchAjoute = true;
          break;
        }
      }
      if (matchAjoute == false) {
        for (MatchJoueur matchJoueur in matchModel.joueursEquipeExterieur) {
          if (matchJoueur.joueur?.id == joueurId) {
            matchsJoueur.add(matchModel);
            break;
          }
        }
      }
    }
    return matchsJoueur;
  }

  static Future<PlayerStats> getPlayerStats(Joueur joueur) async {
    if (RepositoryProvider.userRepository.currentUser == null) {
      throw Exception("L'utilisateur n'est pas connecté");
    }
    final String userId = RepositoryProvider.userRepository.currentUser!.uid;
    String equipeId = joueur.equipeId;
    List<MatchModel> matchsEquipe =
        await RepositoryProvider.matchRepository.fetchTeamAllMatches(equipeId);
    if (joueur.equipeNationaleId != null) {
      matchsEquipe += await RepositoryProvider.matchRepository
          .fetchTeamAllMatches(joueur.equipeNationaleId!);
    }
    List<MatchModel> matchsJoueur = getMatchsJoueur(matchsEquipe, joueur.id);
    List<MatchModel> matchsEquipeVusUser =
        await RepositoryProvider.userRepository.fetchUserMatchsRegardes(
      userId: userId,
      onlyPublic: false,
      equipeId: equipeId,
    );
    if (joueur.equipeNationaleId != null) {
      matchsEquipeVusUser +=
          await RepositoryProvider.userRepository.fetchUserMatchsRegardes(
        userId: userId,
        onlyPublic: false,
        equipeId: joueur.equipeNationaleId,
      );
    }
    List<MatchModel> matchsJoueurVusUser = getMatchsJoueur(
      matchsEquipeVusUser,
      joueur.id,
    );
    final int matchsJoues = matchsJoueur.length;
    final int matchsVus = matchsJoueurVusUser.length;
    final int buts = matchsJoueur
        .map((match) => match.butsEquipeDomicile + match.butsEquipeExterieur)
        .expand((buts) => buts)
        .where((but) => but.buteur == joueur)
        .length;
    final int butsVus = matchsJoueurVusUser
        .map((match) => match.butsEquipeDomicile + match.butsEquipeExterieur)
        .expand((buts) => buts)
        .where((but) => but.buteur == joueur)
        .length;
    int eluMvp = 0;
    for (MatchModel match in matchsJoueur) {
      Joueur? mvp = await match.getMvp();
      if (mvp?.id == joueur.id) {
        eluMvp++;
      }
    }
    int eluMvpVu = 0;
    for (MatchModel match in matchsJoueurVusUser) {
      Joueur? mvp = await match.getMvp();
      if (mvp?.id == joueur.id) {
        eluMvpVu++;
      }
    }
    final int votesMvp = matchsJoueur.fold(
      0,
      (sum, match) =>
          sum + match.mvpVotes.values.where((id) => id == joueur.id).length,
    );
    final int votesMvpVus = matchsJoueurVusUser.fold(
      0,
      (sum, match) => sum + (match.mvpVotes[userId] == joueur.id ? 1 : 0),
    );
    return PlayerStats(
      butsMarques: buts,
      userButsMarques: butsVus,
      matchsJoues: matchsJoues,
      userMatchsJoues: matchsVus,
      eluMvp: eluMvp,
      userEluMvp: eluMvpVu,
      votesMvp: votesMvp,
      userVotesMvp: votesMvpVus,
    );
  }

  static Future<TeamStats> getTeamStats(Equipe equipe) async {
    if (RepositoryProvider.userRepository.currentUser == null) {
      throw Exception("L'utilisateur n'est pas connecté");
    }
    final String userId = RepositoryProvider.userRepository.currentUser!.uid;

    List<MatchModel> matchsEquipe =
        await RepositoryProvider.matchRepository.fetchTeamAllMatches(equipe.id);

    List<MatchModel> matchsEquipeVusUser =
        await RepositoryProvider.userRepository.fetchUserMatchsRegardes(
      userId: userId,
      onlyPublic: false,
      equipeId: equipe.id,
    );

    final matchIdsEquipe = matchsEquipeVusUser.map((match) => match.id).toSet();

    List<MatchUserData> matchsDataVusUser = await RepositoryProvider
        .userRepository
        .fetchUserAllMatchUserData(userId: userId);
    matchsDataVusUser = matchsDataVusUser
        .where((matchData) => matchIdsEquipe.contains(matchData.matchId))
        .toList();

    final int matchsJoues = matchsEquipe.length;
    final int matchsVus = matchsEquipeVusUser.length;
    final int butsMarques = matchsEquipe.fold(0, (total, match) {
      if (match.equipeDomicile.id == equipe.id) {
        return total + match.scoreEquipeDomicile;
      } else if (match.equipeExterieur.id == equipe.id) {
        return total + match.scoreEquipeExterieur;
      } else {
        return total;
      }
    });
    final int butsMarquesVus = matchsEquipeVusUser.fold(0, (total, match) {
      if (match.equipeDomicile.id == equipe.id) {
        return total + match.scoreEquipeDomicile;
      } else if (match.equipeExterieur.id == equipe.id) {
        return total + match.scoreEquipeExterieur;
      } else {
        return total;
      }
    });
    final int butsEncaisses = matchsEquipe.fold(0, (total, match) {
      if (match.equipeDomicile.id == equipe.id) {
        return total + match.scoreEquipeExterieur;
      } else if (match.equipeExterieur.id == equipe.id) {
        return total + match.scoreEquipeDomicile;
      } else {
        return total;
      }
    });
    final int butsEncaissesVus = matchsEquipeVusUser.fold(0, (total, match) {
      if (match.equipeDomicile.id == equipe.id) {
        return total + match.scoreEquipeExterieur;
      } else if (match.equipeExterieur.id == equipe.id) {
        return total + match.scoreEquipeDomicile;
      } else {
        return total;
      }
    });
    final int diffButs = matchsEquipe.fold(0, (total, match) {
      if (match.equipeDomicile.id == equipe.id) {
        return total + match.scoreEquipeDomicile - match.scoreEquipeExterieur;
      } else if (match.equipeExterieur.id == equipe.id) {
        return total + match.scoreEquipeExterieur - match.scoreEquipeDomicile;
      } else {
        return total;
      }
    });
    final int diffButsVus = matchsEquipeVusUser.fold(0, (total, match) {
      if (match.equipeDomicile.id == equipe.id) {
        return total + match.scoreEquipeDomicile - match.scoreEquipeExterieur;
      } else if (match.equipeExterieur.id == equipe.id) {
        return total + match.scoreEquipeExterieur - match.scoreEquipeDomicile;
      } else {
        return total;
      }
    });
    List<PodiumEntry<Joueur>> eluMvp =
        await getMvpsLesPlusVotesListeMatchs(matchs: matchsEquipe);
    List<PodiumEntry<Joueur>> eluMvpMatchsVusUser =
        await getMvpsLesPlusVotesListeMatchs(matchs: matchsEquipeVusUser);

    List<MatchModel> matchsAvecUneNote =
        matchsEquipe.where((match) => match.getNoteMoyenne() != -1).toList();

    double noteMoyenne = matchsAvecUneNote.isEmpty
        ? 0
        : matchsAvecUneNote
                .map((match) => match.getNoteMoyenne())
                .fold(0.0, (sum, note) => sum + note) /
            matchsAvecUneNote.length;
    double noteMoyenneMatchsUser =
        getMoyenneNotes(matchsVusUser: matchsDataVusUser);

    List<StatValue> ratioVictoiresDefaites =
        getPourcentageVictoireEquipe(matchsEquipe, equipe.id);
    List<StatValue> ratioVictoiresDefaitesVusUser =
        getPourcentageVictoireEquipe(matchsEquipeVusUser, equipe.id);

    return TeamStats(
      matchsJoues: matchsJoues,
      userMatchsJoues: matchsVus,
      butsMarques: butsMarques,
      userButsMarques: butsMarquesVus,
      butsEncaisses: butsEncaisses,
      userButsEncaisses: butsEncaissesVus,
      differenceButs: diffButs,
      userDifferenceButs: diffButsVus,
      noteMoyenneMatchs: noteMoyenne,
      userNoteMoyenneMatchs: noteMoyenneMatchsUser,
      eluMvp: eluMvp,
      userEluMvp: eluMvpMatchsVusUser,
      ratioVictoiresDefaites: ratioVictoiresDefaites,
      userRatioVictoiresDefaites: ratioVictoiresDefaitesVusUser,
    );
  }

  static Future<List<PodiumEntry<Joueur>>> getMvpsLesPlusVotesListeMatchs(
      {required List<MatchModel> matchs}) async {
    Map<String, int> mvpsCount = {};

    for (final matchData in matchs) {
      final mvp = await matchData.getMvp();
      if (mvp != null) {
        mvpsCount[mvp.id] = (mvpsCount[mvp.id] ?? 0) + 1;
      }
    }

    final podiumEntries = await Future.wait(
      mvpsCount.entries.map((entry) async {
        final joueur = await RepositoryProvider.joueurRepository
            .fetchJoueurById(entry.key);
        if (joueur == null) return null;

        final color = await joueur.getColor();
        return PodiumEntry<Joueur>(
          item: joueur,
          value: entry.value,
          color: color,
        );
      }),
    );

    return podiumEntries.whereType<PodiumEntry<Joueur>>().toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static List<StatValue> getPourcentageVictoireEquipe(
      List<MatchModel> matchsVusModels, String equipeId) {
    int victoires = 0;
    int nuls = 0;
    int defaites = 0;

    for (final match in matchsVusModels) {
      if (match.equipeDomicile.id == equipeId) {
        if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
          victoires++;
        } else if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
          defaites++;
        } else {
          nuls++;
        }
      } else if (match.equipeExterieur.id == equipeId) {
        if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
          defaites++;
        } else if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
          victoires++;
        } else {
          nuls++;
        }
      }
    }

    final totalMatchs = matchsVusModels.length;
    if (totalMatchs == 0) {
      return [
        StatValue(label: "Victoire", value: 0),
        StatValue(label: "Nuls", value: 0),
        StatValue(label: "Défaites", value: 0),
      ];
    }

    return [
      StatValue(label: "Victoires", value: (victoires / totalMatchs) * 100),
      StatValue(label: "Nuls", value: (nuls / totalMatchs) * 100),
      StatValue(label: "Défaites", value: (defaites / totalMatchs) * 100),
    ];
  }

  static Future<List<StatValueDuo>> getButsEtMvpsParJoueur({
    required Map<Joueur, int> butsParJoueur,
    required Map<Joueur, int> mvpsParJoueur,
    Map<String, Equipe>? equipesCache,
  }) async {
    final mvpParJoueurId = {
      for (final entry in mvpsParJoueur.entries) entry.key.id: entry.value
    };

    final result = <StatValueDuo>[];

    for (final entry in butsParJoueur.entries) {
      final joueur = entry.key;
      final nbButs = entry.value;
      final nbMvps = mvpParJoueurId[joueur.id];

      if (nbMvps == null || nbMvps == 0) continue;

      final equipe = equipesCache?[joueur.equipeId] ??
          await RepositoryProvider.equipeRepository
              .fetchEquipeById(joueur.equipeId);

      result.add(
        StatValueDuo(
          label: joueur.fullName,
          valueX: nbButs,
          valueY: nbMvps,
          color: equipe?.couleurPrincipale,
        ),
      );
    }

    result.sort((a, b) => b.valueX.compareTo(a.valueX));

    return result;
  }

  static List<StatValueDuo> getPourcentageVictoiresParEquipe({
    required Map<Equipe, int> equipesDifferentes,
    required List<PodiumEntry<Equipe>> equipesLesPlusVuesGagner,
  }) {
    final equipesTroisMatchJoues = Map<Equipe, int>.from(equipesDifferentes);
    equipesTroisMatchJoues.removeWhere((equipe, nbMatchs) => nbMatchs < 3);
    final result = equipesTroisMatchJoues
        .map((equipe, nbMatchs) {
          final entryGagnant = equipesLesPlusVuesGagner.firstWhere(
            (entry) => entry.item.id == equipe.id,
            orElse: () => PodiumEntry(
              item: equipe,
              value: 0,
              color: equipe.couleurPrincipale,
            ),
          );
          final pourcentageVictoires = (entryGagnant.value / nbMatchs) * 100;
          return MapEntry(
            equipe,
            StatValueDuo(
              label: equipe.nom,
              valueX: nbMatchs,
              valueY: pourcentageVictoires,
              color: entryGagnant.color,
            ),
          );
        })
        .values
        .toList();

    result.sort((a, b) => b.valueX.compareTo(a.valueX));

    return result;
  }
}
