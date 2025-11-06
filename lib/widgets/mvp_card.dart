// lib/widgets/mvp_card.dart
import 'package:flutter/material.dart';
import '../models/joueur.dart';

class MvpCard extends StatelessWidget {
  final Joueur? mvp; // MVP élu par la communauté (peut être null)
  final Joueur?
      userVote; // Le joueur pour lequel l'utilisateur courant a voté (nullable)
  final VoidCallback? onVotePressed;

  const MvpCard({
    super.key,
    this.mvp,
    this.userVote,
    this.onVotePressed,
  });

  String _initiales(Joueur j) {
    final p = j.prenom.trim();
    final n = j.nom.trim();
    final ip = p.isNotEmpty ? p[0].toUpperCase() : '';
    final iname = n.isNotEmpty ? n[0].toUpperCase() : '';
    final res = (ip + iname);
    return res.isEmpty ? '?' : res;
  }

  Widget _buildAvatar({Joueur? player, double radius = 28}) {
    // On essaie d'afficher la photo du MVP s'il y en a une, sinon initiales / placeholder.
    final picture = player?.picture;
    if (picture != null && picture.isNotEmpty) {
      // Si c'est une ressource locale :
      // return CircleAvatar(radius: radius, backgroundImage: AssetImage(picture));
      // Si c'est une URL depuis le réseau utilisez NetworkImage :
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image(
              image: picture.startsWith('http')
                  ? NetworkImage(picture) as ImageProvider
                  : AssetImage(picture),
              fit: BoxFit.contain,
              width: radius * 2,
              height: radius * 2,
            ),
          ),
        ),
      );
    } else if (player != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          _initiales(player),
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.person, color: Colors.grey.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUserVoted = userVote != null;
    final buttonLabel = hasUserVoted ? 'Changer' : 'Voter';
    final displayedPlayer =
        mvp; // joueur affiché comme "MVP élu" (peut être null)

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITRE
            Text(
              'MVP du match',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            // LIGNE PRINCIPALE : avatar + infos + bouton
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar du MVP (ou placeholder)
                _buildAvatar(player: displayedPlayer, radius: 28),

                const SizedBox(width: 12),

                // Texte (nom / équipe) + info "Votre vote"
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (displayedPlayer != null) ...[
                        Text(
                          displayedPlayer.fullName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        if (displayedPlayer.equipe != null)
                          Text(
                            displayedPlayer.equipe!.nom,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700),
                          ),
                      ] else ...[
                        const Text('Aucun MVP élu',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('Sois le premier à voter !',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700)),
                      ],

                      const SizedBox(height: 6),

                      // Affichage du vote de l'utilisateur (si présent)
                      if (hasUserVoted)
                        Text(
                          'Votre vote : ${userVote!.fullName}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                    ],
                  ),
                ),

                // Bouton Voter / Changer mon vote
                ElevatedButton.icon(
                  onPressed: onVotePressed ?? () {},
                  icon: Icon(hasUserVoted ? Icons.refresh : Icons.how_to_vote,
                      size: 18),
                  label: Text(buttonLabel),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
