import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class TeamStats {
  final int matchsJoues;
  final int butsMarques;
  final int butsEncaisses;
  final int differenceButs;
  final double noteMoyenneMatchs;
  final List<PodiumEntry<Joueur>> eluMvp;
  final List<StatValue> ratioVictoiresDefaites;

  final int userMatchsJoues;
  final int userButsMarques;
  final int userButsEncaisses;
  final int userDifferenceButs;
  final double userNoteMoyenneMatchs;
  final List<PodiumEntry<Joueur>> userEluMvp;
  final List<StatValue> userRatioVictoiresDefaites;

  TeamStats({
    required this.matchsJoues,
    required this.butsMarques,
    required this.butsEncaisses,
    required this.differenceButs,
    required this.eluMvp,
    required this.noteMoyenneMatchs,
    required this.ratioVictoiresDefaites,
    required this.userMatchsJoues,
    required this.userButsMarques,
    required this.userButsEncaisses,
    required this.userDifferenceButs,
    required this.userEluMvp,
    required this.userNoteMoyenneMatchs,
    required this.userRatioVictoiresDefaites,
  });
}
