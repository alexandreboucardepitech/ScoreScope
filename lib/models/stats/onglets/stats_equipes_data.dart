import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/stats/graph/stat_value_duo.dart';
import 'package:scorescope/models/stats/podium_entry.dart';

class StatsEquipesData {
  final List<PodiumEntry<Equipe>> equipesLesPlusVues;
  final int nbEquipesDifferentes;

  final List<PodiumEntry<Equipe>> equipesLesPlusVuesGagner;
  final List<PodiumEntry<Equipe>> equipesLesPlusVuesPerdre;

  final List<PodiumEntry<Equipe>> equipesPlusDeButsMarques;
  final List<PodiumEntry<Equipe>> equipesPlusDeButsEncaisses;

  final List<StatValueDuo> pourcentageVictoiresParEquipe;

  const StatsEquipesData({
    required this.equipesLesPlusVues,
    required this.nbEquipesDifferentes,
    required this.equipesLesPlusVuesGagner,
    required this.equipesLesPlusVuesPerdre,
    required this.equipesPlusDeButsMarques,
    required this.equipesPlusDeButsEncaisses,
    required this.pourcentageVictoiresParEquipe
  });
}
