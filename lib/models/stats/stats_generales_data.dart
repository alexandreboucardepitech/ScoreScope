import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsGeneralesData {
  final int matchsVus;
  final int butsVus;
  final double moyenneButsParMatch;

  final int nbButeursDifferents;
  final int nbEquipesDifferentes;
  final int nbCompetitionsDifferentes;
  final double moyenneNotes;

  final List<PodiumEntry<Equipe>> equipesLesPlusVues;
  final List<PodiumEntry<Competition>> competitionsLesPlusSuivies;
  final List<PodiumEntry<Joueur>> meilleursButeurs;
  final List<PodiumEntry<Joueur>> mvpsLesPlusVotes;

  const StatsGeneralesData({
    required this.matchsVus,
    required this.butsVus,
    required this.moyenneButsParMatch,
    required this.nbButeursDifferents,
    required this.nbEquipesDifferentes,
    required this.nbCompetitionsDifferentes,
    required this.moyenneNotes,
    required this.equipesLesPlusVues,
    required this.competitionsLesPlusSuivies,
    required this.meilleursButeurs,
    required this.mvpsLesPlusVotes,
  });
}
