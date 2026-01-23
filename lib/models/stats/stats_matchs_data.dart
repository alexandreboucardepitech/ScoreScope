import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsMatchsData {
  final int matchsVus;
  final double moyenneButsParMatch;

  final List<PodiumEntry<MatchModel>> biggestScores;
  final List<PodiumEntry<MatchModel>> biggestScoresDifference;
  final num moyenneDiffButsParMatch;

  final List<StatValue> pourcentageVictoireDomExt;
  final List<StatValue> pourcentageClubsInternationaux;

  const StatsMatchsData({
    required this.matchsVus,
    required this.moyenneButsParMatch,
    required this.biggestScores,
    required this.biggestScoresDifference,
    required this.moyenneDiffButsParMatch,
    required this.pourcentageVictoireDomExt,
    required this.pourcentageClubsInternationaux,
  });
}
