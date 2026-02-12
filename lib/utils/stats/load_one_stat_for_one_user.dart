import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/web/web_app_user_repository.dart';
import 'package:scorescope/utils/stats/stats_loader.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';

Future<List<PodiumEntry<T>>> loadOneStatForOneUser<T extends PodiumDisplayable>(
  String userId,
  String statToLoad,
) async {
  final List<String> matchsVusIds =
      await WebAppUserRepository().getUserMatchsRegardesId(userId: userId);

  final List<MatchModel> matchsVusModels =
      await StatsLoader.getMatchModelsFromIds(matchsVusIds);

  final List<MatchUserData> matchsVusUser =
      await WebAppUserRepository().fetchUserAllMatchUserData(userId: userId);

  switch (statToLoad) {
    case 'Équipes les plus vues':
      {
        final map = await StatsLoader.getEquipesLesPlusVues(matchsVusModels);
        final result = await StatsLoader.getPodiumFromMap<Equipe>(map);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Compétitions les plus suivies':
      {
        final map =
            await StatsLoader.getCompetitionsLesPlusVues(matchsVusModels);
        final result = await StatsLoader.getPodiumFromMap<Competition>(map);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Joueurs les plus vus marquer':
      {
        final map = await StatsLoader.getMeilleursButeurs(matchsVusModels);
        final result = await StatsLoader.getPodiumFromMap<Joueur>(map);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'MVP les plus voté':
      {
        final result =
            await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchsVusUser);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Plus gros score':
      {
        final result = StatsLoader.getBiggestScoresMatch(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Plus gros écart':
      {
        final result =
            StatsLoader.getBiggestScoreDifferenceMatch(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Équipes les plus vues gagner':
      {
        final result =
            await StatsLoader.getEquipesLesPlusVuesGagner(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Équipes les plus vues perdre':
      {
        final result =
            await StatsLoader.getEquipesLesPlusVuesPerdre(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Buts marqués':
      {
        final result =
            await StatsLoader.getEquipesLesPlusVuesMarquer(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Buts encaissés':
      {
        final result =
            await StatsLoader.getEquipesLesPlusVuesEncaisser(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Titularisations':
      {
        final map = await StatsLoader.getTitularisations(matchsVusModels);
        final result = await StatsLoader.getPodiumFromMap<Joueur>(map);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Record de buts sur un match':
      {
        final map =
            await StatsLoader.getMeilleursButeursUnMatch(matchsVusModels);
        final result = await StatsLoader.getPodiumFromMap<Joueur>(map);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Buts par compétition':
      {
        final result = await StatsLoader.getButsParCompetition(matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Moy. buts / match':
      {
        final result = await StatsLoader.getMoyenneButsParMatchParCompetition(
            matchsVusModels);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Matchs les mieux notés':
      {
        final result =
            await StatsLoader.getMatchsMieuxNotes(matchsVusUser: matchsVusUser);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Matchs les + commentés':
      {
        final result = await StatsLoader.getMatchsPlusCommentes(
            matchsVusUser: matchsVusUser);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Matchs les + réactions':
      {
        final result = await StatsLoader.getMatchsPlusReactions(
            matchsVusUser: matchsVusUser);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    case 'Jours avec le plus de matchs vus':
      {
        final result = await StatsLoader.getJoursAvecLePlusDeMatchs(
            matchsVusUser: matchsVusUser);
        return result.map((e) => e as PodiumEntry<T>).toList();
      }

    default:
      return [];
  }
}
