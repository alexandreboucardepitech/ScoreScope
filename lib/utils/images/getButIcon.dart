import 'package:flutter/material.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

Icon getButIcon(String joueurId, MatchModel match, BuildContext context) {
  String type = "normal";
  for (But but in match.butsEquipeDomicile) {
    if (but.buteur.id == joueurId) {
      if (but.typeBut == TypeBut.normal) {
        // dès qu'on trouve un but normal, il prend le dessus
        return Icon(
          Icons.sports_soccer,
          size: 10,
          color: ColorPalette.textPrimary(context),
        );
      } else if (but.typeBut == TypeBut.owngoal) {
        type = "owngoal";
      } else if (but.typeBut == TypeBut.penalty) {
        type = "penalty";
      }
    }
  }

  switch (type) {
    case "owngoal":
      return Icon(
        Icons.sports_soccer,
        size: 10,
        color: Colors.red,
      );
    case "penalty":
      return Icon(
        Icons.sports_soccer,
        size: 10,
        color: ColorPalette.textPrimary(context),
      );
    case "normal":
    default:
      return Icon(
        Icons.sports_soccer,
        size: 10,
        color: ColorPalette.textPrimary(context),
      );
  }
}
