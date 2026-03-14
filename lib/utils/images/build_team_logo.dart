import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/details/team_details_page.dart';

Widget buildTeamLogo(
  BuildContext context,
  String? path, {
  String? equipeId,
  double size = 32,
  bool clickable = true,
  AppUser? user,
}) {
  bool isFavorite = false;
  if (user != null) {
    isFavorite = user.equipesPrefereesId.contains(equipeId);
  } else {
    isFavorite = RepositoryProvider
            .userRepository.currentUser?.equipesPrefereesId
            .contains(equipeId) ??
        false;
  }

  final logoWidget = SizedBox(
    width: size,
    height: size,
    child: path != null
        ? Image.network(path, fit: BoxFit.contain)
        : Icon(Icons.shield,
            size: size, color: ColorPalette.textPrimary(context)),
  );

  final clickableLogoWidget = InkWell(
    onTap: () {
      if (equipeId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailsPage(teamId: equipeId),
          ),
        );
      }
    },
    child: logoWidget,
  );

  if (!isFavorite) {
    return clickable ? clickableLogoWidget : logoWidget;
  }

  return Stack(
    clipBehavior: Clip.none,
    children: [
      clickable ? clickableLogoWidget : logoWidget,
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
            size: size / 3,
            color: ColorPalette.accent(context),
          ),
        ),
      ),
    ],
  );
}
