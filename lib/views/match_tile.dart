import 'package:flutter/material.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/joueur.dart';
import '../models/match.dart';

class MatchTile extends StatelessWidget {
  final Match match;
  const MatchTile({required this.match, super.key});

  List<String> getLignesButeurs(List<But> buts, bool domicile) {
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
        return e.key.fullName;
      }
      final minutes = minutesList.map((m) => "${m}'").join(", ");
      return domicile ? "${e.key.fullName} $minutes" : "$minutes ${e.key.fullName}";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).secondaryHeaderColor,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              // Logo ligue
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: SizedBox(
                  width: 30,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      'assets/competitions/ligue1.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Équipe domicile
              Expanded(
                child: Align(
                  alignment: Alignment
                      .centerRight, // alignement à droite vers le score
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      match.equipeDomicile.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),

              // Score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Équipe extérieur
              Expanded(
                child: Align(
                  alignment:
                      Alignment.centerLeft, // alignement à gauche vers le score
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      match.equipeExterieur.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: getLignesButeurs(
                        match.butsEquipeDomicile,
                        true,
                      ).map((line) => Text(line)).toList(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.directional(end: 20, start: 20),
                    child: Icon(Icons.sports_soccer, size: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: getLignesButeurs(
                        match.butsEquipeExterieur,
                        false,
                      ).map((line) => Text(line)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
