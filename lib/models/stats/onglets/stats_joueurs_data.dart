import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/graph/stat_value_duo.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsJoueursData {
  final List<PodiumEntry<Joueur>> meilleursButeurs;
  final List<PodiumEntry<Joueur>> meilleursPasseurs;
  final List<PodiumEntry<Joueur>> meilleursGAs;
  final List<PodiumEntry<Joueur>> titularisations;

  final List<PodiumEntry<Joueur>> mvpsLesPlusVotes;
  final List<PodiumEntry<Joueur>> meilleursButeursUnMatch;

  final List<StatValueDuo> butsMvpParJoueur;

  const StatsJoueursData({
    required this.meilleursButeurs,
    required this.meilleursPasseurs,
    required this.meilleursGAs,
    required this.titularisations,
    required this.mvpsLesPlusVotes,
    required this.meilleursButeursUnMatch,
    required this.butsMvpParJoueur,
  });
}
