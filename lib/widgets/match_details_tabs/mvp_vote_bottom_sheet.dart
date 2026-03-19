import 'package:flutter/material.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import '../../models/match.dart';
import '../../models/joueur.dart';

Future<Joueur?> showVoteBottomSheet({
  required BuildContext context,
  required MatchModel match,
  Joueur? initialUserVote,
}) {
  return showModalBottomSheet<Joueur?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorPalette.tileBackground(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => VoteBottomSheetContent(
      match: match,
      initialUserVote: initialUserVote,
    ),
  );
}

class VoteBottomSheetContent extends StatefulWidget {
  final MatchModel match;
  final Joueur? initialUserVote;
  const VoteBottomSheetContent({
    super.key,
    required this.match,
    this.initialUserVote,
  });

  @override
  State<VoteBottomSheetContent> createState() => _VoteBottomSheetContentState();
}

class _VoteBottomSheetContentState extends State<VoteBottomSheetContent> {
  Joueur? currentUserVote;

  @override
  void initState() {
    super.initState();
    currentUserVote = widget.initialUserVote;
  }

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

  List<MatchJoueur> getJoueursTriesParNombreDeVotes(
      List<MatchJoueur> joueurs, MatchModel match) {
    List<MatchJoueur> newList = List<MatchJoueur>.from(joueurs);
    newList.sort((a, b) =>
        (a.joueur != null ? match.getNbVotesById(a.joueur!.id) : 0) >
                (b.joueur != null ? match.getNbVotesById(b.joueur!.id) : 0)
            ? -1
            : 1);
    return newList;
  }

  Widget playerTile(Joueur joueur, VoidCallback onTap) {
    final isUserVote =
        currentUserVote != null && currentUserVote!.id == joueur.id;
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
                      const SizedBox(width: 6),
                      Text(
                        getNbVotesWithUserVote(
                                match: widget.match,
                                joueur: joueur,
                                initialUserVote: widget.initialUserVote,
                                currentUserVote: currentUserVote)
                            .toString(),
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

  void selectPlayer(Joueur p) => setState(() => currentUserVote = p);

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
                                onPressed: () =>
                                    Navigator.of(context).pop(currentUserVote),
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
                                  // backgroundColor:
                                  //     ColorPalette.buttonPrimary(context),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
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
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.separated(
                              itemCount: joueursDomicileTries.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final player = joueursDomicileTries[index];
                                if (player.joueur != null) {
                                  return playerTile(player.joueur!,
                                      () => selectPlayer(player.joueur!));
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: double.infinity,
                      color: ColorPalette.surface(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
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
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.separated(
                              itemCount: joueursExterieurTries.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final player = joueursExterieurTries[index];
                                if (player.joueur != null) {
                                  return playerTile(player.joueur!,
                                      () => selectPlayer(player.joueur!));
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                      onPressed: () => Navigator.of(context).pop(null),
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
                    onPressed: () => setState(() => currentUserVote = null),
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
