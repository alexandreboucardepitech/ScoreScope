import 'dart:async';
import '../../models/match.dart';
import '../../models/equipe.dart';
import '../../models/joueur.dart';
import '../../models/but.dart';
import 'i_match_repository.dart';
// import 'package:uuid/uuid.dart';

class MockMatchRepository implements IMatchRepository {
  final List<Match> _matches = [];

  MockMatchRepository() {
    _seed();
  }

  void _seed() {
    final psg = Equipe(nom: "PSG");
    final fcNantes = Equipe(nom: "FC Nantes");
    final barcelona = Equipe(nom: "FC Barcelona");
    final realMadrid = Equipe(nom: "Real Madrid");

    final abline = Joueur(prenom: "Matthis", nom: "Abline");
    final benhattab = Joueur(prenom: "Yassine", nom: "Benhattab");
    final leroux = Joueur(prenom: "Louis", nom: "Leroux");
    final yamal = Joueur(prenom: "Lamine", nom: "Yamal");
    final pedri = Joueur(prenom: "", nom: "Pedri");
    final mbappe = Joueur(prenom: "Kylian", nom: "Mbappé");
    final mastantuono = Joueur(prenom: "Franco", nom: "Mastantuono");

    _matches.add(Match(
      id: "1",
      equipeDomicile: psg,
      equipeExterieur: fcNantes,
      competition: "Ligue 1",
      date: DateTime.now(),
      scoreEquipeDomicile: 0,
      scoreEquipeExterieur: 6,
      butsEquipeDomicile: [],
      butsEquipeExterieur: [
        But(buteur: abline, minute: "12"),
        But(buteur: abline, minute: "23"),
        But(buteur: abline, minute: "47"),
        But(buteur: benhattab, minute: "25"),
        But(buteur: leroux, minute: "63"),
        But(buteur: leroux, minute: "90+1")
      ],
    ));

    _matches.add(Match(
      id: "2",
      equipeDomicile: barcelona,
      equipeExterieur: realMadrid,
      competition: "Liga",
      date: DateTime.now(),
      scoreEquipeDomicile: 3,
      scoreEquipeExterieur: 2,
      butsEquipeDomicile: [
        But(buteur: yamal, minute: "52"),
        But(buteur: yamal, minute: "55"),
        But(buteur: pedri, minute: "83")
      ],
      butsEquipeExterieur: [
        But(buteur: mbappe, minute: "4"),
        But(buteur: mastantuono, minute: "17")
      ],
    ));
  }

  @override
  Future<List<Match>> fetchAllMatches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Match>.from(_matches);
  }

  @override
  Future<Match?> fetchMatchById(String id) async {
    // Simuler un délai comme si on faisait un appel réseau
    await Future.delayed(Duration(milliseconds: 200));

    // Cherche le match correspondant à l'id
    try {
      final match = _matches.firstWhere((m) => m.id == id);
      return match;
    } catch (e) {
      // Si aucun match trouvé, retourne null
      return null;
    }
  }


  @override
  Future<void> addMatch(Match m) async {
    _matches.add(m);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updateMatch(Match m) async {
    // naive : remplace par égalité d'instance ou implémente id
    final idx = _matches.indexWhere((x) => x == m);
    if (idx >= 0) _matches[idx] = m;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> deleteMatch(Match m) async {
    _matches.remove(m);
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
