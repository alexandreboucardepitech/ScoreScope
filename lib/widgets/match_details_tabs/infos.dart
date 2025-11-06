// Dans ton MatchDetailsPage, remplace l'enfant de l'onglet "Infos" par :
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_vote_bottom_sheet.dart';
import 'package:scorescope/widgets/mvp_card.dart';
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
    int oldVote = (currentMvp != null ? widget.match.mvpVotes[currentMvp] : 1) ?? 1;
    Joueur? newJoueurSelected = await showVoteBottomSheet(context: context, match: widget.match, initialUserVote: currentMvp);
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
          MvpCard(mvp: currentMvp, userVote: currentMvp, onVotePressed: _onPlusPressed),

          const SizedBox(height: 16),

          // Exemple : liste des joueurs (pour futur vote)
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: widget.match.joueurs.length,
          //     itemBuilder: (context, i) {
          //       final j = widget.match.joueurs[i];
          //       return ListTile(
          //         leading: CircleAvatar(
          //           backgroundImage: (j.picture != null && j.picture!.isNotEmpty)
          //               ? NetworkImage(j.picture!)
          //               : null,
          //           child: (j.picture == null || j.picture!.isEmpty)
          //               ? Text(
          //                   '${j.prenom.isNotEmpty ? j.prenom[0] : ''}${j.nom.isNotEmpty ? j.nom[0] : ''}',
          //                   style: const TextStyle(fontWeight: FontWeight.bold),
          //                 )
          //               : null,
          //         ),
          //         title: Text('${j.prenom} ${j.nom}'),
          //         subtitle: j.equipe != null ? Text(j.equipe!.nom) : null,
          //         trailing: IconButton(
          //           icon: const Icon(Icons.how_to_vote),
          //           onPressed: () {
          //             // futur comportement : enregistrer un vote pour ce joueur
          //             debugPrint('Vote pour ${j.prenom} ${j.nom}');
          //           },
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
