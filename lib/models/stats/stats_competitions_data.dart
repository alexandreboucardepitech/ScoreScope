import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsCompetitionsData {
  final List<PodiumEntry<Competition>> competitionsLesPlusSuivies;
  final int nbCompetitionsDifferentes;

  final List<PodiumEntry<Competition>> butsParCompetition;
  final List<PodiumEntry<Competition>> competitionsMoyButs;

  const StatsCompetitionsData({
    required this.competitionsLesPlusSuivies,
    required this.nbCompetitionsDifferentes,
    required this.butsParCompetition,
    required this.competitionsMoyButs,
  });
}
