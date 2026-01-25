import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/day_podium_displayable.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';

class StatsLoader {
  const StatsLoader._(); // empêche l'instanciation

  static Future<Map<Joueur, int>> getMeilleursButeurs(
      List<MatchModel> matchsVusModels) async {
    Map<Joueur, int> uniqueButeursId = {};
    for (final match in matchsVusModels) {
      final List<But> butsDuMatch =
          match.butsEquipeDomicile + match.butsEquipeExterieur;
      for (var but in butsDuMatch) {
        uniqueButeursId[but.buteur] = (uniqueButeursId[but.buteur] ?? 0) + 1;
      }
    }
    final sortedEntries = uniqueButeursId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  static Future<Map<Joueur, int>> getTitularisations(
      List<MatchModel> matchsVusModels) async {
    Map<Joueur, int> uniqueJoueursId = {};
    for (final match in matchsVusModels) {
      final List<Joueur> joueursDuMatch =
          match.joueursEquipeDomicile + match.joueursEquipeExterieur;
      for (var joueur in joueursDuMatch) {
        uniqueJoueursId[joueur] = (uniqueJoueursId[joueur] ?? 0) + 1;
      }
    }
    final sortedEntries = uniqueJoueursId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  static Future<Map<Equipe, int>> getEquipesLesPlusVues(
      List<MatchModel> matchsVusModels) async {
    Map<Equipe, int> uniqueEquipesId = {};
    for (final match in matchsVusModels) {
      uniqueEquipesId[match.equipeDomicile] =
          (uniqueEquipesId[match.equipeDomicile] ?? 0) + 1;
      uniqueEquipesId[match.equipeExterieur] =
          (uniqueEquipesId[match.equipeExterieur] ?? 0) + 1;
    }
    final sortedEntries = uniqueEquipesId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  static Future<Map<Competition, int>> getCompetitionsLesPlusVues(
      List<MatchModel> matchsVusModels) async {
    Map<Competition, int> uniqueCompetitionsId = {};
    for (final match in matchsVusModels) {
      uniqueCompetitionsId[match.competition] =
          (uniqueCompetitionsId[match.competition] ?? 0) + 1;
    }
    final sortedEntries = uniqueCompetitionsId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  static int getNbButsVus({required List<MatchModel> matchsVusModels}) {
    if (matchsVusModels.isEmpty) return 0;
    int totalButs = 0;

    for (var match in matchsVusModels) {
      totalButs += match.scoreEquipeDomicile + match.scoreEquipeExterieur;
    }

    return totalButs;
  }

  static Future<double> getMoyenneNotes(
      {required List<MatchUserData> matchsVusUser}) async {
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

  static List<PodiumEntry<T>> getPodiumFromMap<T extends PodiumDisplayable>(
      Map<T, int> dataMap) {
    final podiumEntries = dataMap.entries
        .map((entry) => PodiumEntry<T>(item: entry.key, value: entry.value))
        .toList();

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
      {required List<MatchUserData> matchsVusUser}) async {
    Map<String, int> mvpsCount = {};
    List<PodiumEntry<Joueur>> mvpsPodium = [];
    for (final matchData in matchsVusUser) {
      if (matchData.mvpVoteId != null) {
        mvpsCount[matchData.mvpVoteId!] =
            (mvpsCount[matchData.mvpVoteId!] ?? 0) + 1;
      }
    }
    for (final entry in mvpsCount.entries) {
      final joueur =
          await RepositoryProvider.joueurRepository.fetchJoueurById(entry.key);
      if (joueur == null) continue;
      mvpsPodium.add(PodiumEntry<Joueur>(item: joueur, value: entry.value));
    }
    return mvpsPodium;
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

  static List<PodiumEntry<Equipe>> getEquipesLesPlusVuesGagner(
      List<MatchModel> matchsVusModels) {
    Map<Equipe, int> equipesVictoiresCount = {};
    for (final match in matchsVusModels) {
      Equipe? gagnant;
      if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
        gagnant = match.equipeDomicile;
      } else if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
        gagnant = match.equipeExterieur;
      }
      if (gagnant != null) {
        equipesVictoiresCount[gagnant] =
            (equipesVictoiresCount[gagnant] ?? 0) + 1;
      }
    }
    final podiumEntries = equipesVictoiresCount.entries
        .map(
            (entry) => PodiumEntry<Equipe>(item: entry.key, value: entry.value))
        .toList();
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<PodiumEntry<Equipe>> getEquipesLesPlusVuesPerdre(
      List<MatchModel> matchsVusModels) {
    Map<Equipe, int> equipesDefaitesCount = {};
    for (final match in matchsVusModels) {
      Equipe? perdant;
      if (match.scoreEquipeDomicile < match.scoreEquipeExterieur) {
        perdant = match.equipeDomicile;
      } else if (match.scoreEquipeDomicile > match.scoreEquipeExterieur) {
        perdant = match.equipeExterieur;
      }
      if (perdant != null) {
        equipesDefaitesCount[perdant] =
            (equipesDefaitesCount[perdant] ?? 0) + 1;
      }
    }
    final podiumEntries = equipesDefaitesCount.entries
        .map(
            (entry) => PodiumEntry<Equipe>(item: entry.key, value: entry.value))
        .toList();
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<PodiumEntry<Equipe>> getEquipesLesPlusVuesMarquer(
      List<MatchModel> matchsVusModels) {
    Map<Equipe, int> equipesButsCount = {};
    for (final match in matchsVusModels) {
      equipesButsCount[match.equipeDomicile] =
          (equipesButsCount[match.equipeDomicile] ?? 0) +
              match.butsEquipeDomicile.length;
      equipesButsCount[match.equipeExterieur] =
          (equipesButsCount[match.equipeExterieur] ?? 0) +
              match.butsEquipeExterieur.length;
    }
    final podiumEntries = equipesButsCount.entries
        .map(
            (entry) => PodiumEntry<Equipe>(item: entry.key, value: entry.value))
        .toList();
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<PodiumEntry<Equipe>> getEquipesLesPlusVuesEncaisser(
      List<MatchModel> matchsVusModels) {
    Map<Equipe, int> equipesButsCount = {};
    for (final match in matchsVusModels) {
      equipesButsCount[match.equipeExterieur] =
          (equipesButsCount[match.equipeExterieur] ?? 0) +
              match.butsEquipeDomicile.length;
      equipesButsCount[match.equipeDomicile] =
          (equipesButsCount[match.equipeDomicile] ?? 0) +
              match.butsEquipeExterieur.length;
    }
    final podiumEntries = equipesButsCount.entries
        .map(
            (entry) => PodiumEntry<Equipe>(item: entry.key, value: entry.value))
        .toList();
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static Future<Map<Joueur, int>> getMeilleursButeursUnMatch(
    List<MatchModel> matchsVus,
  ) async {
    final Map<Joueur, int> bestGoalsPerMatchByPlayer = {};

    for (final match in matchsVus) {
      final List<But> butsDuMatch =
          match.butsEquipeDomicile + match.butsEquipeExterieur;

      final Map<Joueur, int> goalsThisMatch = {};

      for (final but in butsDuMatch) {
        goalsThisMatch[but.buteur] = (goalsThisMatch[but.buteur] ?? 0) + 1;
      }

      for (final entry in goalsThisMatch.entries) {
        final joueur = entry.key;
        final goalsInThisMatch = entry.value;

        final currentBest = bestGoalsPerMatchByPlayer[joueur] ?? 0;
        if (goalsInThisMatch > currentBest) {
          bestGoalsPerMatchByPlayer[joueur] = goalsInThisMatch;
        }
      }
    }

    final sortedEntries = bestGoalsPerMatchByPlayer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  static List<PodiumEntry<Competition>> getButsParCompetition(
      List<MatchModel> matchsVusModels) {
    Map<Competition, int> competitionsButsCount = {};
    for (final match in matchsVusModels) {
      competitionsButsCount[match.competition] =
          (competitionsButsCount[match.competition] ?? 0) +
              match.butsEquipeDomicile.length +
              match.butsEquipeExterieur.length;
    }
    final podiumEntries = competitionsButsCount.entries
        .map((entry) =>
            PodiumEntry<Competition>(item: entry.key, value: entry.value))
        .toList();
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<PodiumEntry<Competition>> getMoyenneButsParMatchParCompetition(
    List<MatchModel> matchsVusModels,
  ) {
    final Map<Competition, int> totalButs = {};
    final Map<Competition, int> totalMatchs = {};

    for (final match in matchsVusModels) {
      final competition = match.competition;
      final butsDuMatch =
          match.butsEquipeDomicile.length + match.butsEquipeExterieur.length;

      totalButs[competition] = (totalButs[competition] ?? 0) + butsDuMatch;

      totalMatchs[competition] = (totalMatchs[competition] ?? 0) + 1;
    }

    final podiumEntries = totalButs.entries.map((entry) {
      final competition = entry.key;
      final buts = entry.value;
      final matchs = totalMatchs[competition]!;

      final moyenne = buts / matchs;

      return PodiumEntry<Competition>(
        item: competition,
        value: moyenne,
      );
    }).toList();

    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static Future<List<PodiumEntry<MatchModel>>> getMatchsMieuxNotes({
    required List<MatchUserData> matchsVusUser,
  }) async {
    final List<PodiumEntry<MatchModel>> podiumEntries = [];

    for (final matchUserData in matchsVusUser) {
      final note = matchUserData.note;
      if (note == null) continue;

      final MatchModel? match = await RepositoryProvider.matchRepository
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
  }) async {
    final List<PodiumEntry<MatchModel>> podiumEntries = [];

    for (final matchUserData in matchsVusUser) {
      final MatchModel? match = await RepositoryProvider.matchRepository
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
  }) async {
    final List<PodiumEntry<MatchModel>> podiumEntries = [];

    for (final matchUserData in matchsVusUser) {
      final MatchModel? match = await RepositoryProvider.matchRepository
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

  static List<PodiumEntry<DayPodiumDisplayable>> getJoursAvecLePlusDeMatchs(
      {required List<MatchUserData> matchsVusUser}) {
    final Map<DayPodiumDisplayable, int> matchsParJour = {};

    for (final matchUserData in matchsVusUser) {
      final watchedAt = matchUserData.watchedAt;
      if (watchedAt == null) continue;
      final day = DateTime(
        watchedAt.year,
        watchedAt.month,
        watchedAt.day,
      );
      final dayDisplayable = DayPodiumDisplayable(day);

      matchsParJour[dayDisplayable] = (matchsParJour[dayDisplayable] ?? 0) + 1;
    }
    final podiumEntries = matchsParJour.entries
        .map(
          (entry) => PodiumEntry<DayPodiumDisplayable>(
            item: entry.key,
            value: entry.value,
          ),
        )
        .toList();
    podiumEntries.sort((a, b) => b.value.compareTo(a.value));
    return podiumEntries;
  }

  static List<StatValue> getPourcentageMatchsCompetitions(
      List<MatchModel> matchsVusModels) {
    Map<Competition, int> competitionsCount = {};
    for (final match in matchsVusModels) {
      competitionsCount[match.competition] =
          (competitionsCount[match.competition] ?? 0) + 1;
    }

    final totalMatchs = matchsVusModels.length;
    if (totalMatchs == 0) {
      return [];
    }

    final statValues = competitionsCount.entries.map((entry) {
      final competition = entry.key;
      final count = entry.value;
      final percentage = (count / totalMatchs) * 100;

      return StatValue(
        label: competition.nom,
        value: percentage,
      );
    }).toList();

    statValues.sort((a, b) => b.value.compareTo(a.value));
    return statValues;
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
      final watchedAt = match.watchedAt;
      if (watchedAt == null) continue;

      final monthKey = DateTime(
        watchedAt.year,
        watchedAt.month,
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
}
