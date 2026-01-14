import 'package:scorescope/models/stats/stats_competitions_data.dart';
import 'package:scorescope/models/stats/stats_equipes_data.dart';
import 'package:scorescope/models/stats/stats_habitudes_data.dart';
import 'package:scorescope/models/stats/stats_joueurs_data.dart';
import 'package:scorescope/models/stats/stats_matchs_data.dart';
import 'package:scorescope/models/stats/stats_generales_data.dart';

abstract class IStatsRepository {
  Future<StatsGeneralesData> fetchStatsGenerales(
      String userId, bool onlyPublic);
  Future<StatsMatchsData> fetchStatsMatchs(String userId, bool onlyPublic);
  Future<StatsEquipesData> fetchStatsEquipes(String userId, bool onlyPublic);
  Future<StatsJoueursData> fetchStatsJoueurs(String userId, bool onlyPublic);
  Future<StatsCompetitionsData> fetchStatsCompetitions(
      String userId, bool onlyPublic);
  Future<StatsHabitudesData> fetchStatsHabitudes(
      String userId, bool onlyPublic);
}
