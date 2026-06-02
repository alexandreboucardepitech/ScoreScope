import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class ProfileScrolledTitle extends StatelessWidget {
  final String username;
  final String nbAmis;
  final String nbMatchs;
  final String nbButs;

  const ProfileScrolledTitle({
    super.key,
    required this.username,
    required this.nbAmis,
    required this.nbMatchs,
    required this.nbButs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            username,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              nbAmis,
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textPrimary(context),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              translate.amis,
              style: TextStyle(
                fontSize: 14,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              nbMatchs,
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textPrimary(context),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              translate.matchs,
              style: TextStyle(
                fontSize: 14,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              nbButs,
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textPrimary(context),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              translate.buts,
              style: TextStyle(
                fontSize: 14,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
