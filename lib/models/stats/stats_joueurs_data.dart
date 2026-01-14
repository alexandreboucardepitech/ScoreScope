import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsJoueursData {
  final List<PodiumEntry<Joueur>> meilleursButeurs;
  final List<PodiumEntry<Joueur>> titularisations;

  final List<PodiumEntry<Joueur>> mvpsLesPlusVotes;
  final List<PodiumEntry<Joueur>> meilleursButeursUnMatch;

  const StatsJoueursData({
    required this.meilleursButeurs,
    required this.titularisations,
    required this.mvpsLesPlusVotes,
    required this.meilleursButeursUnMatch,
  });
}
