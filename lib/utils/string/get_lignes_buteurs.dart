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
      butsMap[but.buteur]!.add(minute);
    }
  }

  return butsMap.entries.map((e) {
    final joueur = e.key;
    final minutesList = e.value;

    String display;

    if (minutesList.isEmpty) {
      display = fullName ? joueur.fullName : joueur.shortName;
    } else {
      final minutes = minutesList.map((m) => "$m'").join(", ");
      display = domicile
          ? "${fullName ? joueur.fullName : joueur.shortName} $minutes"
          : "$minutes ${fullName ? joueur.fullName : joueur.shortName}";
    }

    return ButeurLine(
      joueur: joueur,
      nomJoueur: display,
    );
  }).toList();
}
