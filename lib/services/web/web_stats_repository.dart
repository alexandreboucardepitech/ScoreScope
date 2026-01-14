import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/stats/stats_competitions_data.dart';
import 'package:scorescope/models/stats/stats_equipes_data.dart';
import 'package:scorescope/models/stats/stats_generales_data.dart';
import 'package:scorescope/models/stats/stats_habitudes_data.dart';
import 'package:scorescope/models/stats/stats_joueurs_data.dart';
import 'package:scorescope/models/stats/stats_matchs_data.dart';
import 'package:scorescope/services/repositories/i_stats_repository.dart';
import 'package:scorescope/services/web/web_app_user_repository.dart';
import 'package:scorescope/utils/stats_loader.dart';

class WebStatsRepository implements IStatsRepository {
  @override
  Future<StatsGeneralesData> fetchStatsGenerales(
      String userId, bool onlyPublic) async {
    List<String> matchsVus = await WebAppUserRepository()
        .getUserMatchsRegardesId(userId, onlyPublic);

    int nbButsVus =
        await WebAppUserRepository().getUserNbButs(userId, onlyPublic);

    List<MatchUserData> matchsVusUser = await WebAppUserRepository()
        .fetchUserAllMatchUserData(userId, onlyPublic);

    Map<Joueur, int> buteursDifferents =
        await StatsLoader.getMeilleursButeurs(matchsVus);
    Map<Equipe, int> equipesDifferentes =
        await StatsLoader.getEquipesLesPlusVues(matchsVus);
    Map<Competition, int> competitionsDifferentes =
        await StatsLoader.getCompetitionsLesPlusVues(matchsVus);

    return StatsGeneralesData(
      matchsVus: matchsVus.length,
      butsVus: nbButsVus,
      moyenneButsParMatch:
          matchsVus.isNotEmpty ? nbButsVus / matchsVus.length : 0,
      nbButeursDifferents: buteursDifferents.length,
      nbEquipesDifferentes: equipesDifferentes.length,
      nbCompetitionsDifferentes: competitionsDifferentes.length,
      moyenneNotes:
          await StatsLoader.getMoyenneNotes(matchsVusUser: matchsVusUser),
      meilleursButeurs: StatsLoader.getPodiumFromMap<Joueur>(buteursDifferents),
      equipesLesPlusVues:
          StatsLoader.getPodiumFromMap<Equipe>(equipesDifferentes),
      competitionsLesPlusSuivies:
          StatsLoader.getPodiumFromMap<Competition>(competitionsDifferentes),
      mvpsLesPlusVotes:
          await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchsVusUser),
    );
  }

  @override
  Future<StatsMatchsData> fetchStatsMatchs(
      String userId, bool onlyPublic) async {
    List<String> matchsVus = await WebAppUserRepository()
        .getUserMatchsRegardesId(userId, onlyPublic);

    int nbButsVus =
        await WebAppUserRepository().getUserNbButs(userId, onlyPublic);

    List<MatchModel> matchsVusModels =
        await StatsLoader.getMatchModelsFromIds(matchsVus);
    return StatsMatchsData(
        matchsVus: matchsVus.length,
        moyenneButsParMatch:
            matchsVus.isNotEmpty ? nbButsVus / matchsVus.length : 0,
        biggestScores: StatsLoader.getBiggestScoresMatch(matchsVusModels),
        biggestScoresDifference:
            StatsLoader.getBiggestScoreDifferenceMatch(matchsVusModels),
        moyenneDiffButsParMatch:
            StatsLoader.getMoyenneDifferenceButsParMatch(matchsVusModels),
        pourcentageVictoireDomExt:
            StatsLoader.getPourcentageVictoireDomExt(matchsVusModels),
        pourcentageClubsInternationaux: [50, 50]); // TODO: plus tard
  }

  @override
  Future<StatsEquipesData> fetchStatsEquipes(
      String userId, bool onlyPublic) async {
    List<String> matchsVus = await WebAppUserRepository()
        .getUserMatchsRegardesId(userId, onlyPublic);
    Map<Equipe, int> equipesDifferentes =
        await StatsLoader.getEquipesLesPlusVues(matchsVus);

    List<MatchModel> matchsVusModels =
        await StatsLoader.getMatchModelsFromIds(matchsVus);

    return StatsEquipesData(
      equipesLesPlusVues:
          StatsLoader.getPodiumFromMap<Equipe>(equipesDifferentes),
      nbEquipesDifferentes: equipesDifferentes.length,
      equipesLesPlusVuesGagner:
          StatsLoader.getEquipesLesPlusVuesGagner(matchsVusModels),
      equipesLesPlusVuesPerdre:
          StatsLoader.getEquipesLesPlusVuesPerdre(matchsVusModels),
      equipesPlusDeButsMarques:
          StatsLoader.getEquipesLesPlusVuesMarquer(matchsVusModels),
      equipesPlusDeButsEncaisses:
          StatsLoader.getEquipesLesPlusVuesEncaisser(matchsVusModels),
    );
  }

  @override
  Future<StatsJoueursData> fetchStatsJoueurs(
      String userId, bool onlyPublic) async {
    List<String> matchsVus = await WebAppUserRepository()
        .getUserMatchsRegardesId(userId, onlyPublic);

    Map<Joueur, int> buteursDifferents =
        await StatsLoader.getMeilleursButeurs(matchsVus);

    Map<Joueur, int> titularisations =
        await StatsLoader.getTitularisations(matchsVus);

    List<MatchUserData> matchsVusUser = await WebAppUserRepository()
        .fetchUserAllMatchUserData(userId, onlyPublic);

    Map<Joueur, int> meilleursButeursUnMatch =
        await StatsLoader.getMeilleursButeurs(matchsVus);

    return StatsJoueursData(
        meilleursButeurs:
            StatsLoader.getPodiumFromMap<Joueur>(buteursDifferents),
        titularisations: StatsLoader.getPodiumFromMap<Joueur>(titularisations),
        mvpsLesPlusVotes:
            await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchsVusUser),
        meilleursButeursUnMatch:
            StatsLoader.getPodiumFromMap<Joueur>(meilleursButeursUnMatch));
  }

  @override
  Future<StatsCompetitionsData> fetchStatsCompetitions(
      String userId, bool onlyPublic) async {
    List<String> matchsVus = await WebAppUserRepository()
        .getUserMatchsRegardesId(userId, onlyPublic);
    List<MatchModel> matchsVusModels =
        await StatsLoader.getMatchModelsFromIds(matchsVus);

    Map<Competition, int> competitionsDifferentes =
        await StatsLoader.getCompetitionsLesPlusVues(matchsVus);

    return StatsCompetitionsData(
        competitionsLesPlusSuivies:
            StatsLoader.getPodiumFromMap<Competition>(competitionsDifferentes),
        nbCompetitionsDifferentes: competitionsDifferentes.length,
        butsParCompetition: StatsLoader.getButsParCompetition(matchsVusModels),
        competitionsMoyButs:
            StatsLoader.getMoyenneButsParMatchParCompetition(matchsVusModels));
  }

  @override
  Future<StatsHabitudesData> fetchStatsHabitudes(
      String userId, bool onlyPublic) async {
    List<MatchUserData> matchsVusUser = await WebAppUserRepository()
        .fetchUserAllMatchUserData(userId, onlyPublic);

    return StatsHabitudesData(
      mvpsLesPlusVotes:
          await StatsLoader.getMvpsLesPlusVotes(matchsVusUser: matchsVusUser),
      moyenneNotes:
          await StatsLoader.getMoyenneNotes(matchsVusUser: matchsVusUser),
      matchsMieuxNotes:
          await StatsLoader.getMatchsMieuxNotes(matchsVusUser: matchsVusUser),
      matchsPlusCommentes: await StatsLoader.getMatchsPlusCommentes(
          matchsVusUser: matchsVusUser),
      matchsPlusReactions: await StatsLoader.getMatchsPlusReactions(
          matchsVusUser: matchsVusUser),
      joursLePlusDeMatchs:
          StatsLoader.getJoursAvecLePlusDeMatchs(matchsVusUser: matchsVusUser),
    );
  }
}
