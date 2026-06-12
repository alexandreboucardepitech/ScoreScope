import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/stats/stats_loader.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

Future<List<PodiumEntry<T>>> loadOneStatForOneUser<T extends PodiumDisplayable>(
  String userId,
  String statToLoad,
) async {
  final List<String> matchsVusIds = await RepositoryProvider.userRepository
      .getUserMatchsRegardesId(userId: userId, onlyPublic: true);

  final List<MatchModel> matchsVusModels =
      await StatsLoader.getMatchModelsFromIds(matchsVusIds);

  final List<MatchUserData> matchsVusUser = await RepositoryProvider
      .userRepository
      .fetchUserAllMatchUserData(userId: userId, onlyPublic: true);

  if (statToLoad == translate.equipesLesPlusVues) {
    final map = await StatsLoader.getEquipesLesPlusVues(matchsVusModels);
    final result = await StatsLoader.getPodiumFromMap<Equipe>(map);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.competitionsLesPlusSuivies) {
    final map = await StatsLoader.getCompetitionsLesPlusVues(matchsVusModels);
    final result = await StatsLoader.getPodiumFromMap<Competition>(map);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.joueursLesPlusVusMarquer) {
    final map = await StatsLoader.getMeilleursButeurs(matchsVusModels);
    final result = await StatsLoader.getPodiumFromMap<Joueur>(map);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.mvpLesPlusVotes) {
    final result =
        await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchsVusUser);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.plusGrosScore) {
    final result = StatsLoader.getBiggestScoresMatch(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.plusGrosEcart) {
    final result = StatsLoader.getBiggestScoreDifferenceMatch(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.equipesLesPlusVuesGagner) {
    final result =
        await StatsLoader.getEquipesLesPlusVuesGagner(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.equipesLesPlusVuesPerdre) {
    final result =
        await StatsLoader.getEquipesLesPlusVuesPerdre(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.butsMarques) {
    final result =
        await StatsLoader.getEquipesLesPlusVuesMarquer(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.butsEncaisses) {
    final result =
        await StatsLoader.getEquipesLesPlusVuesEncaisser(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.titularisations) {
    final map = await StatsLoader.getTitularisations(matchsVusModels);
    final result = await StatsLoader.getPodiumFromMap<Joueur>(map);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.recordDeButsSurUnMatch) {
    final map = await StatsLoader.getMeilleursButeursUnMatch(matchsVusModels);
    final result = await StatsLoader.getPodiumFromMap<Joueur>(map);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.butsParCompetition) {
    final result = await StatsLoader.getButsParCompetition(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.moyButsMatch) {
    final result =
        await StatsLoader.getMoyenneButsParMatchParCompetition(matchsVusModels);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.matchsLesMieuxNotes) {
    final result =
        await StatsLoader.getMatchsMieuxNotes(matchsVusUser: matchsVusUser);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.matchsLesCommentes) {
    final result =
        await StatsLoader.getMatchsPlusCommentes(matchsVusUser: matchsVusUser);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.matchsLesReactions) {
    final result =
        await StatsLoader.getMatchsPlusReactions(matchsVusUser: matchsVusUser);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else if (statToLoad == translate.joursAvecLePlusDeMatchsVus) {
    final result = await StatsLoader.getJoursAvecLePlusDeMatchs(
        matchsVusUser: matchsVusUser);
    return result.map((e) => e as PodiumEntry<T>).toList();
  } else {
    return [];
  }
}
