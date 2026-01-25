import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/match_details_tabs/match_infos_card.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_vote_bottom_sheet.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_card.dart';
import 'package:scorescope/widgets/match_details_tabs/match_rating_card.dart';
import 'package:scorescope/widgets/match_details_tabs/visionnage_match_card.dart';
import '../../../models/match.dart';

class InfosTab extends StatefulWidget {
  final MatchModel match;
  final int userDataVersion;

  const InfosTab({super.key, required this.match, this.userDataVersion = 0});

  @override
  State<InfosTab> createState() => _InfosTabState();
}

class _InfosTabState extends State<InfosTab> {
  Joueur? currentMvp;
  Joueur? userVoteMVP;
  int? userVoteNoteMatch;
  bool _loadingMvp = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadMvpEtNote();
  }

  @override
  void didUpdateWidget(covariant InfosTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userDataVersion != oldWidget.userDataVersion) {
      setState(() {
        userVoteMVP = null;
        userVoteNoteMatch = null;
        currentMvp = null;
        _loadingMvp = true;
      });
      _loadMvpEtNote();
    }
  }

  Future<void> _loadMvpEtNote() async {
    if (!mounted) return;
    setState(() => _loadingMvp = true);

    Joueur? loadedCurrentMvp;
    Joueur? loadedUserVoteMVP;
    int? loadedUserNote;

    try {
      loadedCurrentMvp = await widget.match.getMvp();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final match = await RepositoryProvider.matchRepository
            .fetchMatchById(widget.match.id);
        if (match != null) {
          final userVoteId = match.mvpVotes[firebaseUser.uid];
          if (userVoteId != null) {
            loadedUserVoteMVP =
                await RepositoryProvider.joueurRepository.fetchJoueurById(
              userVoteId,
            );
          } else {
            loadedUserVoteMVP = null;
          }
          final userNote = match.notesDuMatch[firebaseUser.uid];
          loadedUserNote = userNote;
        }
      }

      if (!mounted) return;
      setState(() {
        currentMvp = loadedCurrentMvp;
        userVoteMVP = loadedUserVoteMVP;
        userVoteNoteMatch = loadedUserNote;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement du MVP ou du vote utilisateur: $e');
      if (!mounted) return;
      setState(() {
        currentMvp = loadedCurrentMvp; // on garde ce qu'on a pu lire du global
        userVoteMVP = null;
        userVoteNoteMatch = null;
      });
    } finally {
      if (!mounted) return;
      setState(() => _loadingMvp = false);
    }
  }

  Future<void> _onPlusPressed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final Joueur? newJoueurSelected = await showVoteBottomSheet(
      context: context,
      match: widget.match,
      initialUserVote: userVoteMVP,
    );

    if (newJoueurSelected != null) {
      widget.match
          .voterPourMVP(userId: user.uid, joueurId: newJoueurSelected.id);
      userVoteMVP = newJoueurSelected;
    } else {
      widget.match.enleverVote(userId: user.uid);
    }
    await _loadMvpEtNote();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MatchRatingCard(
            key: ValueKey(
              'match_rating_${widget.match.id}_${widget.userDataVersion}',
            ),
            noteMoyenne: widget.match.getNoteMoyenne(),
            userVote: userVoteNoteMatch,
            onChanged: (nouvelleValeur) {},
            onConfirm: (valeurConfirmee) async {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              widget.match.noterMatch(userId: uid, note: valeurConfirmee);
              userVoteNoteMatch = valeurConfirmee;
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          _loadingMvp
              ? const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : MvpCard(
                  key: ValueKey(
                    'mvp_${widget.match.id}_${widget.userDataVersion}',
                  ),
                  mvp: currentMvp,
                  userVote: userVoteMVP,
                  onVotePressed: _onPlusPressed,
                ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: VisionnageMatchCard(
                    key: ValueKey(
                      'visionnage_${widget.match.id}_${widget.userDataVersion}',
                    ),
                    match: widget.match,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 1,
                  child: MatchInfosCard(match: widget.match),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
