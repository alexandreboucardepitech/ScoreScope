import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

String initiales(Joueur j) {
  final p = j.prenom.trim();
  final n = j.nom.trim();
  final ip = p.isNotEmpty ? p[0].toUpperCase() : '';
  final iname = n.isNotEmpty ? n[0].toUpperCase() : '';
  final res = (ip + iname);
  return res.isEmpty ? '?' : res;
}

Widget buildAvatar({
  Joueur? player,
  double radius = 28,
  required BuildContext context,
}) {
  final picture = player?.picture;
  if (picture != null && picture.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorPalette.pictureBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: picture.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: picture,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                )
              : Image.asset(
                  picture,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                ),
        ),
      ),
    );
  } else if (player != null) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorPalette.pictureBackground(context),
      child: Text(
        initiales(player),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary(context),
        ),
      ),
    );
  } else {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorPalette.pictureBackground(context),
      child: Icon(Icons.person, color: ColorPalette.accent(context)),
    );
  }
}
