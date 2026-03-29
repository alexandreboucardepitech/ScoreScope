import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

int getNbVotesWithUserVote(
    {required MatchModel match,
    required Joueur joueur,
    Joueur? initialUserVote,
    Joueur? currentUserVote}) {
  int nbVotes = match.getNbVotesById(joueur.id);
  if (joueur == initialUserVote) nbVotes--;
  if (joueur == currentUserVote) nbVotes++;
  return nbVotes;
}

Widget playerTile({
  required Joueur joueur,
  required VoidCallback onTap,
  required bool isUserVote,
  required BuildContext context,
  required MatchModel match,
  Joueur? initialUserVote,
  Joueur? currentUserVote,
}) {
  int nbButs = match.getPlayerNbButs(joueur.id);
  int nbPassesDe = match.getPlayerNbPassesDe(joueur.id);
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: isUserVote
          ? BoxDecoration(
              color: ColorPalette.surface(context).withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: ColorPalette.buttonSecondary(context).withAlpha(10),
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ],
              border: Border.all(
                color: ColorPalette.border(context).withAlpha(38),
              ),
            )
          : null,
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'avatar-${joueur.id}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorPalette.pictureBackground(context),
                  backgroundImage: joueur.picture.startsWith('http')
                      ? NetworkImage(joueur.picture) as ImageProvider
                      : AssetImage(joueur.picture),
                ),
              ),
              const SizedBox(height: 6),
              if (isUserVote)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorPalette.surface(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: ColorPalette.accent(context),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Voté',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorPalette.textAccent(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  joueur.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.emoji_events,
                        size: 16, color: ColorPalette.accent(context)),
                    const SizedBox(width: 4),
                    Text(
                      getNbVotesWithUserVote(
                              match: match,
                              joueur: joueur,
                              initialUserVote: initialUserVote,
                              currentUserVote: currentUserVote)
                          .toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),
                    Spacer(),
                    if (nbButs > 0) ...[
                      Icon(
                        Icons.sports_soccer,
                        size: 16,
                        color: ColorPalette.accent(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        nbButs.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (nbPassesDe > 0) ...[
                      Icon(
                        Icons.adjust,
                        size: 16,
                        color: ColorPalette.accent(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        nbPassesDe.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
