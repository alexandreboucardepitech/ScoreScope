import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/joueur.dart';

  List<String> getLignesButeurs({required List<But> buts, required bool domicile, bool fullName = true}) {
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
    final minutesList = e.value;
    if (minutesList.isEmpty) {
      return fullName ? e.key.fullName : e.key.shortName;
    }
    final minutes = minutesList.map((m) => "${m}'").join(", ");
    return domicile
        ? "${fullName ? e.key.fullName : e.key.shortName} $minutes"
        : "$minutes ${fullName ? e.key.fullName : e.key.shortName}";
  }).toList();
}
