import 'package:flutter/material.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/utils/handle_data/get_joueurs_tries_par_nombre_de_votes.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_details_tabs/player_tile.dart';
import '../../models/match.dart';
import '../../models/joueur.dart';

Future<Map<String, dynamic>?> showVoteBottomSheet({
  required BuildContext context,
  required MatchModel match,
  Joueur? initialUserVote,
  Joueur? preselectedPlayer,
}) {
  return showModalBottomSheet<Map<String, dynamic>?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorPalette.tileBackground(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => VoteBottomSheetContent(
      match: match,
      initialUserVote: initialUserVote,
      preselectedPlayer: preselectedPlayer,
    ),
  );
}

class VoteBottomSheetContent extends StatefulWidget {
  final MatchModel match;
  final Joueur? initialUserVote;
  final Joueur? preselectedPlayer;

  const VoteBottomSheetContent({
    super.key,
    required this.match,
    this.initialUserVote,
    this.preselectedPlayer,
  });

  @override
  State<VoteBottomSheetContent> createState() => _VoteBottomSheetContentState();
}

class _VoteBottomSheetContentState extends State<VoteBottomSheetContent> {
  Joueur? currentUserVote;

  @override
  void initState() {
    super.initState();
    currentUserVote = widget.preselectedPlayer ?? widget.initialUserVote;
  }

  void selectPlayer(Joueur p) => setState(() => currentUserVote = p);

  void _viderVote() => setState(() => currentUserVote = null);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;

    List<MatchJoueur> joueursDomicileTries = getJoueursTriesParNombreDeVotes(
        widget.match.joueursEquipeDomicile, widget.match);

    joueursDomicileTries =
        joueursDomicileTries.where((joueur) => joueur.joueur != null).toList();

    List<MatchJoueur> joueursExterieurTries = getJoueursTriesParNombreDeVotes(
        widget.match.joueursEquipeExterieur, widget.match);

    joueursExterieurTries =
        joueursExterieurTries.where((joueur) => joueur.joueur != null).toList();

    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorPalette.background(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                        sizeFactor: anim, axis: Axis.vertical, child: child)),
                child: currentUserVote != null
                    ? Card(
                        key: ValueKey(currentUserVote!.id),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'avatar-${currentUserVote!.id}',
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      ColorPalette.pictureBackground(context),
                                  backgroundImage: currentUserVote!.picture
                                          .startsWith('http')
                                      ? NetworkImage(currentUserVote!.picture)
                                          as ImageProvider
                                      : AssetImage(currentUserVote!.picture),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUserVote!.fullName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ColorPalette.textPrimary(context),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          size: 16,
                                          color: ColorPalette.accent(context),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          getNbVotesWithUserVote(
                                                  match: widget.match,
                                                  joueur: currentUserVote!,
                                                  initialUserVote:
                                                      widget.initialUserVote,
                                                  currentUserVote:
                                                      currentUserVote)
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: ColorPalette.textSecondary(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop({
                                  "joueur": currentUserVote,
                                  "enleverVote": false,
                                }),
                                icon: Icon(
                                  Icons.how_to_vote,
                                  color: ColorPalette.textSecondary(context),
                                ),
                                label: Text(
                                  'Valider',
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: ColorPalette.border(context),
                                  ),
                                  overlayColor: ColorPalette.highlight(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('no-selection'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aucun joueur sélectionné',
                                  style: TextStyle(
                                    color: ColorPalette.textSecondary(context),
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop({
                                  "joueur": currentUserVote,
                                  "enleverVote": true,
                                }),
                                icon: Icon(
                                  Icons.how_to_vote,
                                  color: ColorPalette.textSecondary(context),
                                ),
                                label: Text(
                                  'Valider',
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: ColorPalette.border(context),
                                  ),
                                  overlayColor: ColorPalette.highlight(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(children: [
                Expanded(
                  child: Text(
                    'Sélectionnez un joueur pour voter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              widget.match.equipeDomicile.nom,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: ColorPalette.surface(context),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              widget.match.equipeExterieur.nom,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: [
                          joueursDomicileTries.length,
                          joueursExterieurTries.length,
                        ].reduce((a, b) => a > b ? a : b),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final playerHome = index < joueursDomicileTries.length
                              ? joueursDomicileTries[index].joueur
                              : null;

                          final playerAway =
                              index < joueursExterieurTries.length
                                  ? joueursExterieurTries[index].joueur
                                  : null;

                          return Row(
                            children: [
                              Expanded(
                                child: playerHome != null
                                    ? playerTile(
                                        joueur: playerHome,
                                        onTap: () => selectPlayer(playerHome),
                                        isUserVote: false,
                                        context: context,
                                        match: widget.match,
                                        initialUserVote: widget.initialUserVote,
                                        currentUserVote: currentUserVote,
                                      )
                                    : const SizedBox(),
                              ),
                              Container(
                                width: 1,
                                height: 60,
                                color: ColorPalette.border(context),
                              ),
                              Expanded(
                                child: playerAway != null
                                    ? playerTile(
                                        joueur: playerAway,
                                        onTap: () => selectPlayer(playerAway),
                                        isUserVote: false,
                                        context: context,
                                        match: widget.match,
                                        initialUserVote: widget.initialUserVote,
                                        currentUserVote: currentUserVote,
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(({
                        "joueur": widget.initialUserVote,
                        "enleverVote": false,
                      })),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _viderVote,
                    child: Text(
                      'Vider',
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                      ),
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
