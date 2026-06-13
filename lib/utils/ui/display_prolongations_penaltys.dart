import 'package:flutter/material.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

List<Widget> displayProlongationsPenaltys(
    {required MatchModel match,
    double fontSize = 14,
    required BuildContext context}) {
  return [
    if ((match.isFinished || match.isLive) && match.hasPenaltys)
      Text(
        '(' +
            match.penaltyEquipeDomicile.toString() +
            ' - ' +
            match.penaltyEquipeExterieur.toString() +
            ')',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textSecondary(context),
        ),
      ),
    if (match.isFinished &&
        match.hasPenaltys == false &&
        match.prolongations == true)
      Text(
        translate.ap,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textSecondary(context),
        ),
      ),
  ];
}
