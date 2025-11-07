// Dans ton MatchDetailsPage, remplace l'enfant de l'onglet "Infos" par :
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
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

  @override
  void initState() {
    super.initState();
    currentMvp = widget.match.mvp;
  }

  void _onPlusPressed() async {
    int oldVote =
        (currentMvp != null ? widget.match.mvpVotes[currentMvp] : 1) ?? 1;
    Joueur? newJoueurSelected = await showVoteBottomSheet(
        context: context, match: widget.match, initialUserVote: currentMvp);
    widget.match.mvp = newJoueurSelected;
    if (currentMvp != null) {
      widget.match.mvpVotes[currentMvp!] = oldVote - 1;
    }
    if (newJoueurSelected != null) {
      int newJoueurNbVotes = widget.match.mvpVotes[newJoueurSelected] ?? 0;
      widget.match.mvpVotes[newJoueurSelected] = newJoueurNbVotes + 1;
    }
    currentMvp = newJoueurSelected;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MatchRatingCard(
            noteMoyenne: widget.match.getNoteMoyenne(),
            onChanged: (nouvelleValeur) {
            },
            onConfirm: (valeurConfirmee) {
              widget.match.noterMatch(username: 'username', note: valeurConfirmee);
              setState(() {});
            },
          ),
          MvpCard(
              mvp: currentMvp,
              userVote: currentMvp,
              onVotePressed: _onPlusPressed),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
