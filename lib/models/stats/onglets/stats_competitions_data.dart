import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsCompetitionsData {
  final List<PodiumEntry<Competition>> competitionsLesPlusSuivies;
  final int nbCompetitionsDifferentes;

  final List<PodiumEntry<Competition>> butsParCompetition;
  final List<PodiumEntry<Competition>> competitionsMoyButs;

  final List<StatValue> pourcentageMatchsCompetitions;
  final List<StatValue> typesCompetitions;

  const StatsCompetitionsData({
    required this.competitionsLesPlusSuivies,
    required this.nbCompetitionsDifferentes,
    required this.butsParCompetition,
    required this.competitionsMoyButs,
    required this.pourcentageMatchsCompetitions,
    required this.typesCompetitions,
  });
}
