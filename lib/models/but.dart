import 'package:scorescope/models/joueur.dart';

class But {
  final Joueur buteur;
  final String minute; // pas un int pour le temps additionel

  But({
    required this.buteur,
    required this.minute,
  });
}