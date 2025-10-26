import 'package:flutter/material.dart';

import '../models/joueur.dart';

class MvpCard extends StatelessWidget {
  final Joueur? mvp;
  final VoidCallback? onPlusPressed;

  const MvpCard({super.key, this.mvp, this.onPlusPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            // Avatar / photo
            if (mvp != null)
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: (mvp!.picture != null && mvp!.picture!.isNotEmpty)
                        ? Image.asset(
                            mvp!.picture!,
                            fit: BoxFit.contain, // ne remplira pas tout
                          )
                        : Center(
                            child: Text(
                              mvp!.fullName[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                  ),
                ),
              )
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person, color: Colors.grey.shade700),
              ),

            const SizedBox(width: 12),

            // Texte (nom / équipe ou message vide)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mvp != null) ...[
                    Text(
                      '${mvp!.prenom} ${mvp!.nom}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (mvp!.equipe != null)
                      Text(
                        mvp!.equipe!.nom,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ] else ...[
                    const Text(
                      'Aucun MVP élu',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Sois le premier à voter !',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ]
                ],
              ),
            ),

            // Bouton +
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Voter / proposer un MVP',
              onPressed: onPlusPressed ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
