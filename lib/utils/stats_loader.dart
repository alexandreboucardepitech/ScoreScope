import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/day_podium_displayable.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';

class StatsLoader {
  const StatsLoader._(); // empêche l'instanciation

  static Future<Map<Joueur, int>> getMeilleursButeurs(
      List<String> matchsVusId) async {
    Map<Joueur, int> uniqueButeursId = {};
    for (final matchId in matchsVusId) {
      final MatchModel? match =
          await RepositoryProvider.matchRepository.fetchMatchById(matchId);
      if (match == null) continue;
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
      List<String> matchsVusId) async {
    Map<Joueur, int> uniqueJoueursId = {};
    for (final matchId in matchsVusId) {
      final MatchModel? match =
          await RepositoryProvider.matchRepository.fetchMatchById(matchId);
      if (match == null) continue;
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
      List<String> matchsVusId) async {
    Map<Equipe, int> uniqueEquipesId = {};
    for (final matchId in matchsVusId) {
      final MatchModel? match =
          await RepositoryProvider.matchRepository.fetchMatchById(matchId);
      if (match == null) continue;
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
      List<String> matchsVusId) async {
    Map<Competition, int> uniqueCompetitionsId = {};
    for (final matchId in matchsVusId) {
      final MatchModel? match =
          await RepositoryProvider.matchRepository.fetchMatchById(matchId);
      if (match == null) continue;
      uniqueCompetitionsId[match.competition] =
          (uniqueCompetitionsId[match.competition] ?? 0) + 1;
    }
    final sortedEntries = uniqueCompetitionsId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
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

  static List<num> getPourcentageVictoireDomExt(
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
      return [0, 0, 0];
    }

    return [
      (victoiresDomicile / totalMatchs) * 100,
      (nuls / totalMatchs) * 100,
      (victoiresExterieur / totalMatchs) * 100,
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
    List<String> matchsVusId,
  ) async {
    final Map<Joueur, int> bestGoalsPerMatchByPlayer = {};

    for (final matchId in matchsVusId) {
      final MatchModel? match =
          await RepositoryProvider.matchRepository.fetchMatchById(matchId);
      if (match == null) continue;

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
}
