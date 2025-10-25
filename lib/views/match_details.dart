// /lib/views/match_details.dart
// A simple details page for a Match object.
// Adjust the import and field names to match your existing Match class.

import 'package:flutter/material.dart';
import '../models/match.dart';
import '../utils/get_lignes_buteurs.dart';

class MatchDetailsPage extends StatelessWidget {
  final Match match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          // --- Partie haute colorée ---
          Container(
            height: screenHeight / 3,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16),

            // --> Centrer verticalement tout le contenu dans la zone bleue
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Ligne principale : équipes + score ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Équipe à domicile
                    Expanded(
                      flex: 1, // 1/3
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.asset(match.equipeDomicile.logoPath!,
                                fit: BoxFit.contain),
                          ),
                          Text(
                            match.equipeDomicile.nom,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score
                    Expanded(
                      flex: 1, // 1/3
                      child: Text(
                        '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Équipe à l’extérieur
                    Expanded(
                      flex: 1, // 1/3
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.asset(match.equipeExterieur.logoPath!,
                                fit: BoxFit.contain),
                          ),
                          Text(
                            match.equipeExterieur.nom,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8), // espace entre les lignes

                // --- Ligne des buteurs ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buteurs équipe domicile
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: getLignesButeurs(
                          buts: match.butsEquipeDomicile,
                          domicile: true,
                          fullName: false,
                        )
                            .map((line) => Text(
                                  line,
                                  style: const TextStyle(color: Colors.black),
                                ))
                            .toList(),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.sports_soccer,
                          color: Colors.black, size: 16),
                    ),

                    // Buteurs équipe extérieure
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getLignesButeurs(
                          buts: match.butsEquipeExterieur,
                          domicile: false,
                          fullName: false,
                        )
                            .map((line) => Text(
                                  line,
                                  style: const TextStyle(color: Colors.black),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Contenu du reste de la page ---
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Text('Détails du match ici...'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
