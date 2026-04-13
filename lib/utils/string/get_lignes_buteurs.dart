import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/joueur.dart';

class ButeurLine {
  final Joueur joueur;
  final String nomJoueur;

  ButeurLine({
    required this.joueur,
    required this.nomJoueur,
  });
}

List<ButeurLine> getLignesButeurs({
  required List<But> buts,
  required bool domicile,
  bool fullName = true,
}) {
  Map<Joueur, List<String>> butsMap = {};

  for (But but in buts) {
    final minute = but.minute ?? "-1";

    if (!butsMap.containsKey(but.buteur)) {
      butsMap[but.buteur] = [];
    }

    if (minute != "-1") {
      String suffix = "";

      if (but.typeBut == TypeBut.owngoal) {
        suffix = " (CSC)";
      } else if (but.typeBut == TypeBut.penalty) {
        suffix = " (Pen)";
      }

      butsMap[but.buteur]!.add("$minute'$suffix");
    }
  }

  return butsMap.entries.map((e) {
    final joueur = e.key;
    final minutesList = e.value;

    String display;

    if (minutesList.isEmpty) {
      display = fullName ? joueur.fullName : joueur.shortName;
    } else {
      final minutes = minutesList.join(", ");
      final name = fullName ? joueur.fullName : joueur.shortName;

      display = domicile ? "$name $minutes" : "$minutes $name";
    }

    return ButeurLine(
      joueur: joueur,
      nomJoueur: display,
    );
  }).toList();
}
