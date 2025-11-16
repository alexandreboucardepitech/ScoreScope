import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_vote_bottom_sheet.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_card.dart';
import 'package:scorescope/widgets/match_details_tabs/match_rating_card.dart';
import '../../../models/match.dart';

class InfosTab extends StatefulWidget {
  final Match match;
  const InfosTab({super.key, required this.match});

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
    _loadMvp();
  }

  Future<void> _loadMvp() async {
    setState(() => _loadingMvp = true);
    try {
      final mvp = await widget.match.getMvp();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final joueurId = widget.match.mvpVotes[user.uid];
        if (joueurId != null) {
          userVoteMVP = await RepositoryProvider.joueurRepository
              .fetchJoueurById(joueurId);
        }
        userVoteNoteMatch = widget.match.notesDuMatch[user.uid];
      }

      if (!mounted) return;
      setState(() {
        currentMvp = mvp;
        // userVote = initialUserVote;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement du MVP ou du vote utilisateur: $e');
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
    await _loadMvp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MatchRatingCard(
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
                  mvp: currentMvp,
                  userVote: userVoteMVP,
                  onVotePressed: _onPlusPressed,
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
