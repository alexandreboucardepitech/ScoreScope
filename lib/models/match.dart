import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/equipe.dart';

class Match {
  final Equipe equipeDomicile;
  final Equipe equipeExterieur;
  final String competition;
  final DateTime date;
  final int scoreEquipeDomicile;
  final int scoreEquipeExterieur;
  final List<But> butsEquipeDomicile;
  final List<But> butsEquipeExterieur;

  Match({
    required this.equipeDomicile,
    required this.equipeExterieur,
    required this.competition,
    required this.date,
    required this.scoreEquipeDomicile,
    required this.scoreEquipeExterieur,
    required this.butsEquipeDomicile,
    required this.butsEquipeExterieur,
  });
}