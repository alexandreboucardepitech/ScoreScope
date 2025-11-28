import 'package:flutter/material.dart';
import 'package:scorescope/models/match_regarde_ami.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/string/get_reaction_emoji.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/match_details.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class MatchRegardeAmiCard extends StatelessWidget {
  final MatchRegardeAmi entry;
  const MatchRegardeAmiCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final friend = entry.friend;
    final md = entry.matchData;
    final MatchModel match = entry.match!;
    final String relativeTime =
        md.watchedAt != null ? timeago.format(md.watchedAt!, locale: 'fr') : '';

    const double avatarSize = 32;

    final home = match.equipeDomicile;
    final away = match.equipeExterieur;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MatchDetailsPage(match: match)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header au-dessus de la card
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileView(
                        user: friend,
                        onBackPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ColorPalette.border(context),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundColor: ColorPalette.pictureBackground(context),
                      backgroundImage: friend.photoUrl != null
                          ? NetworkImage(friend.photoUrl!)
                          : null,
                      child: friend.photoUrl == null
                          ? Text(
                              (friend.displayName?.isNotEmpty == true
                                  ? friend.displayName![0].toUpperCase()
                                  : '?'),
                              style: TextStyle(
                                color: ColorPalette.textPrimary(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        friend.displayName ?? 'Utilisateur',
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      if (relativeTime.isNotEmpty)
                        Text(
                          relativeTime,
                          style: TextStyle(
                            color: ColorPalette.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: ColorPalette.tileBackground(context),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                    border: Border.all(
                      color: ColorPalette.border(context),
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centrer verticalement
                    children: [
                      // Score et logos équipes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (home.logoPath != null)
                                  Image.asset(home.logoPath!,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.contain),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    home.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorPalette.textPrimary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Score au centre
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),
                          // Équipe Exterieur
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (away.logoPath != null)
                                  Image.asset(away.logoPath!,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.contain),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    away.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorPalette.textPrimary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: ColorPalette.border(context), height: 1),
                      const SizedBox(height: 12),
                      // Ligne avec les deux gros émojis
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  md.note != null
                                      ? getReactionEmoji(md.note!)
                                      : '😐',
                                  style: const TextStyle(fontSize: 36),
                                ),
                                Text(
                                  md.note != null
                                      ? '${md.note}/10'
                                      : 'Pas noté/10',
                                  style: TextStyle(
                                      color: ColorPalette.accent(context),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          // Séparateur vertical
                          Container(
                            width: 1,
                            height: 60,
                            color: ColorPalette.border(context),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  md.visionnageMatch.emoji.isNotEmpty
                                      ? md.visionnageMatch.emoji
                                      : '❓',
                                  style: const TextStyle(fontSize: 36),
                                ),
                                Text(
                                  md.visionnageMatch.label.isNotEmpty
                                      ? md.visionnageMatch.label
                                      : '?',
                                  style: TextStyle(
                                      color: ColorPalette.accent(context),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: ColorPalette.border(context), height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.how_to_vote,
                              size: 18,
                              color: ColorPalette.accentVariant(context)),
                          const SizedBox(width: 4),
                          Text(
                            'Vote pour MVP : ',
                            style: TextStyle(
                                color: ColorPalette.textPrimary(context),
                                fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                            child: Text(
                              entry.mvpName != null && entry.mvpName!.isNotEmpty
                                  ? entry.mvpName!
                                  : 'Pas de vote pour le MVP',
                              style: TextStyle(
                                color: entry.mvpName != null &&
                                        entry.mvpName!.isNotEmpty
                                    ? ColorPalette.accent(context)
                                    : ColorPalette.textSecondary(context),
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (md.favourite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(
                      Icons.star,
                      size: 24,
                      color: ColorPalette.accent(context),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
