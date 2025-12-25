import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

Widget buildTeamLogo(BuildContext context, String? path,
    {required bool isFavorite, double size = 32}) {
  final logoWidget = SizedBox(
    width: size,
    height: size,
    child: path != null
        ? Image.asset(path, fit: BoxFit.contain)
        : Icon(Icons.shield, size: 20, color: ColorPalette.divider(context)),
  );

  if (!isFavorite) {
    return logoWidget;
  }

  return Stack(
    clipBehavior: Clip.none,
    children: [
      logoWidget,
      Positioned(
        bottom: -1,
        right: -1,
        child: Container(
          decoration: BoxDecoration(
            color: ColorPalette.background(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.star_rounded,
            size: 14,
            color: ColorPalette.accent(context),
          ),
        ),
      ),
    ],
  );
}
