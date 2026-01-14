import 'package:scorescope/models/stats/stats_competitions_data.dart';
import 'package:scorescope/models/stats/stats_equipes_data.dart';
import 'package:scorescope/models/stats/stats_habitudes_data.dart';
import 'package:scorescope/models/stats/stats_joueurs_data.dart';
import 'package:scorescope/models/stats/stats_matchs_data.dart';
import 'package:scorescope/models/stats/stats_generales_data.dart';
import 'package:scorescope/services/repositories/i_stats_repository.dart';

class MockStatsRepository implements IStatsRepository {
  @override
  Future<StatsGeneralesData> fetchStatsGenerales(
      String userId, bool onlyPublic) {
    // TODO: implement fetchStatsGenerales
    throw UnimplementedError();
  }

  @override
  Future<StatsMatchsData> fetchStatsMatchs(String userId, bool onlyPublic) {
    // TODO: implement fetchStatsMatchs
    throw UnimplementedError();
  }

  @override
  Future<StatsEquipesData> fetchStatsEquipes(String userId, bool onlyPublic) {
    // TODO: implement fetchStatsEquipes
    throw UnimplementedError();
  }

  @override
  Future<StatsJoueursData> fetchStatsJoueurs(String userId, bool onlyPublic) {
    // TODO: implement fetchStatsJoueurs
    throw UnimplementedError();
  }

  @override
  Future<StatsCompetitionsData> fetchStatsCompetitions(String userId, bool onlyPublic) {
    // TODO: implement fetchStatsCompetitions
    throw UnimplementedError();
  }

  @override
  Future<StatsHabitudesData> fetchStatsHabitudes(String userId, bool onlyPublic) {
    // TODO: implement fetchStatsHabitudes
    throw UnimplementedError();
  }
}
