import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsJoueursData {
  final List<PodiumEntry<Joueur>> meilleursButeurs;
  final List<PodiumEntry<Joueur>> titularisations;

  final List<PodiumEntry<Joueur>> mvpsLesPlusVotes;
  final List<PodiumEntry<Joueur>> meilleursButeursUnMatch;

  final List<StatValue> butsParJoueur;

  const StatsJoueursData({
    required this.meilleursButeurs,
    required this.titularisations,
    required this.mvpsLesPlusVotes,
    required this.meilleursButeursUnMatch,
    required this.butsParJoueur,
  });
}
