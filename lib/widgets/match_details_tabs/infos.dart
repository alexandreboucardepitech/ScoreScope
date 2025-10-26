// Dans ton MatchDetailsPage, remplace l'enfant de l'onglet "Infos" par :
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
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

  void _onPlusPressed() {
    // pour l'instant : rien, ou debug print.
    // Plus tard tu remplaceras par l'ouverture d'un dialogue de vote.
    debugPrint('Bouton + pressé (ouvrir sélection / vote ici)');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MvpCard(mvp: currentMvp, onPlusPressed: _onPlusPressed),

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
