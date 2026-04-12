import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/utils/string/get_pos_from_string.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class TeamsList extends StatefulWidget {
  final MatchModel match;
  final Function selectPlayer;
  final Joueur? initialUserVote;
  final Joueur? currentUserVote;

  const TeamsList({
    super.key,
    required this.match,
    required this.selectPlayer,
    required this.initialUserVote,
    required this.currentUserVote,
  });

  @override
  State<TeamsList> createState() => _TeamsListState();
}

class _TeamsListState extends State<TeamsList> {
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

  Widget _playerTile(Joueur joueur, VoidCallback onTap) {
    final isUserVote = widget.currentUserVote != null &&
        widget.currentUserVote!.id == joueur.id;
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
                      color:
                          ColorPalette.buttonSecondary(context).withAlpha(10),
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
                CachedNetworkImage(
                  imageUrl: joueur.picture,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
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
                      const SizedBox(width: 6),
                      Text(
                        getNbVotesWithUserVote(
                          match: widget.match,
                          joueur: joueur,
                          initialUserVote: widget.initialUserVote,
                          currentUserVote: widget.currentUserVote,
                        ).toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
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

  List<MatchJoueur> getJoueursTriesParNombreDeVotes(
      List<MatchJoueur> joueurs, MatchModel match) {
    List<MatchJoueur> newList = List<MatchJoueur>.from(joueurs);
    newList.removeWhere((player) => player.hasPlayed == false);
    newList.sort((a, b) {
      // tri par nombre de votes
      if ((a.joueur != null ? match.getNbVotesById(a.joueur!.id) : 0) >
          (b.joueur != null ? match.getNbVotesById(b.joueur!.id) : 0)) {
        return -1;
      }
      if ((b.joueur != null ? match.getNbVotesById(b.joueur!.id) : 0) >
          (a.joueur != null ? match.getNbVotesById(a.joueur!.id) : 0)) {
        return 1;
      }

      // si pas de grid on fait avec la pos
      if (a.grid == null || b.grid == null) {
        if (b.pos == null) {
          return -1;
        }
        if (a.pos == null) {
          return 1;
        }
        final positions = ["G", "D", "M", "A"];
        if (positions.indexOf(a.pos!) < positions.indexOf(b.pos!)) {
          return -1;
        }
        if (positions.indexOf(b.pos!) < positions.indexOf(a.pos!)) {
          return 1;
        }
      }

      // tri par grid principale
      if (a.grid != null && b.grid != null) {
        if (getPosFromString(a.grid!, true) > getPosFromString(b.grid!, true)) {
          return 1;
        }
        if (getPosFromString(b.grid!, true) > getPosFromString(a.grid!, true)) {
          return -1;
        }

        // tri par grid secondaire
        if (getPosFromString(a.grid!, false) >
            getPosFromString(b.grid!, false)) {
          return 1;
        }
        if (getPosFromString(b.grid!, false) >
            getPosFromString(a.grid!, false)) {
          return -1;
        }
      }

      return -1; // par défaut
    });
    return newList;
  }

  Widget _buildHeader(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MatchJoueur> joueursDomicileTries = getJoueursTriesParNombreDeVotes(
            widget.match.joueursEquipeDomicile, widget.match)
        .where((j) => j.joueur != null)
        .toList();

    List<MatchJoueur> joueursExterieurTries = getJoueursTriesParNombreDeVotes(
            widget.match.joueursEquipeExterieur, widget.match)
        .where((j) => j.joueur != null)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HOME TEAM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(widget.match.equipeDomicile.nom, context),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: joueursDomicileTries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final player = joueursDomicileTries[index];
                    return _playerTile(
                      player.joueur!,
                      () => widget.selectPlayer(player.joueur!),
                    );
                  },
                ),
              ],
            ),
          ),

          /// DIVIDER
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: ColorPalette.surface(context),
          ),

          /// AWAY TEAM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(widget.match.equipeExterieur.nom, context),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: joueursExterieurTries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final player = joueursExterieurTries[index];
                    return _playerTile(
                      player.joueur!,
                      () => widget.selectPlayer(player.joueur!),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
