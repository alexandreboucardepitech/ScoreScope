import 'package:flutter/material.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/views/match_tile.dart';
import '../models/match.dart';

class AllMatchesView extends StatelessWidget {
  // Données mock pour commencer

  final List<Match> matches = [];

  void initMatches()
  {
    ////////// équipes //////////
    final psg = Equipe(nom: "PSG");
    final fcNantes = Equipe(nom: "FC Nantes");
    final barcelona = Equipe(nom: "FC Barcelona");
    final realMadrid = Equipe(nom: "Real Madrid");

    ////////// joueurs //////////
    final abline = Joueur(prenom: "Matthis", nom: "Abline");
    final benhattab = Joueur(prenom: "Yassine", nom: "Benhattab");
    final leroux = Joueur(prenom: "Louis", nom: "Leroux");
    final yamal = Joueur(prenom: "Lamine", nom: "Yamal");
    final pedri = Joueur(prenom: "", nom: "Pedri");
    final mbappe = Joueur(prenom: "Kylian", nom: "Mbappé");
    final mastantuono = Joueur(prenom: "Franco", nom: "Mastantuono");

    matches.add(
      Match(
        equipeDomicile: psg,
        equipeExterieur: fcNantes,
        competition: "Ligue 1",
        date: DateTime.now(),
        scoreEquipeDomicile: 0,
        scoreEquipeExterieur: 6,
        butsEquipeDomicile: [],
        butsEquipeExterieur: [But(buteur: abline, minute: "12"),
                              But(buteur: abline, minute: "23"),
                              But(buteur: abline, minute: "47"),
                              But(buteur: benhattab, minute: "25"),
                              But(buteur: leroux, minute: "63"),
                              But(buteur: leroux, minute: "90+1")]
      )
    );
    matches.add(
      Match(
        equipeDomicile: barcelona,
        equipeExterieur: realMadrid,
        competition: "Liga",
        date: DateTime.now(),
        scoreEquipeDomicile: 3,
        scoreEquipeExterieur: 2,
        butsEquipeDomicile: [But(buteur: yamal, minute: "52"),
                             But(buteur: yamal, minute: "55"),
                             But(buteur: pedri, minute: "83")],
        butsEquipeExterieur: [But(buteur: mbappe, minute: "4"),
                              But(buteur: mastantuono, minute: "17")]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    initMatches();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("Matchs regardés"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black), // contour noir
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).secondaryHeaderColor,
        ),
        child: ListView.separated(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return MatchTile(match: matches[index]);
          },
          separatorBuilder: (context, index) => Divider(color: Colors.black),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),  
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigation vers le formulaire d'ajout
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
    );
  }
}
