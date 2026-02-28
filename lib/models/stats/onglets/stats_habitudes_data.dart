import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/day_podium_displayable.dart';

class StatsHabitudesData {
  final List<PodiumEntry<Joueur>> mvpsLesPlusVotes;
  final double moyenneNotes;

  final List<PodiumEntry<MatchModel>> matchsMieuxNotes;
  final List<PodiumEntry<MatchModel>> matchsPlusCommentes;
  final List<PodiumEntry<MatchModel>> matchsPlusReactions;

  final List<PodiumEntry<DayPodiumDisplayable>> joursLePlusDeMatchs;

  final List<StatValue> typeVisionnage;
  final List<TimeStatValue> matchsVusParMois;

  const StatsHabitudesData({
    required this.mvpsLesPlusVotes,
    required this.moyenneNotes,
    required this.matchsMieuxNotes,
    required this.matchsPlusCommentes,
    required this.matchsPlusReactions,
    required this.joursLePlusDeMatchs,
    required this.typeVisionnage,
    required this.matchsVusParMois,
  });
}
