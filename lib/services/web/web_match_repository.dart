import 'dart:async';
import 'package:scorescope/services/web/web_equipe_repository.dart';
import 'package:scorescope/services/repositories/joueur/i_joueur_repository.dart';
import 'package:scorescope/services/web/web_joueur_repository.dart';

import '../../models/match.dart';
import '../../models/but.dart';
import '../repositories/match/i_match_repository.dart';
import '../repositories/equipe/i_equipe_repository.dart';
// import 'package:uuid/uuid.dart';

class WebMatchRepository implements IMatchRepository {
  static final WebMatchRepository _instance = WebMatchRepository._internal();

  late final Future<void> _seedingFuture; // { changed code }

  WebMatchRepository._internal() {
    _seedingFuture = _seed(); // { changed code }
  } // { changed code }

  factory WebMatchRepository() {
    return _instance;
  }

  final List<Match> _matches = [];
  final IEquipeRepository equipeRepository = WebEquipeRepository();
  final IJoueurRepository joueurRepository = WebJoueurRepository();

  Future<void> _seed() async {
    await WebJoueurRepository().ready;
    await WebEquipeRepository().ready;

    final abline = await joueurRepository.fetchJoueurById("1");
    final benhattab = await joueurRepository.fetchJoueurById("2");
    final leroux = await joueurRepository.fetchJoueurById("3");
    final yamal = await joueurRepository.fetchJoueurById("4");
    final pedri = await joueurRepository.fetchJoueurById("5");
    final mbappe = await joueurRepository.fetchJoueurById("6");
    final mastantuono = await joueurRepository.fetchJoueurById("7");
    final aubameyang = await joueurRepository.fetchJoueurById("8");

    final om = await equipeRepository.fetchEquipeById("1");
    final fcnantes = await equipeRepository.fetchEquipeById("2");
    final barca = await equipeRepository.fetchEquipeById("3");
    final realmadrid = await equipeRepository.fetchEquipeById("4");

    if (om != null &&
        fcnantes != null &&
        abline != null &&
        benhattab != null &&
        leroux != null &&
        aubameyang != null) {
      _matches.add(
        Match(
          id: "1",
          equipeDomicile: om,
          equipeExterieur: fcnantes,
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
            But(buteur: leroux, minute: "90+1"),
          ],
          joueursEquipeDomicile: [aubameyang],
          joueursEquipeExterieur: [abline, benhattab, leroux],
          mvp: abline,
        ),
      );
    }

    if (barca != null &&
        realmadrid != null &&
        yamal != null &&
        pedri != null &&
        mbappe != null &&
        mastantuono != null) {
      _matches.add(
        Match(
          id: "2",
          equipeDomicile: barca,
          equipeExterieur: realmadrid,
          competition: "Liga",
          date: DateTime.now(),
          scoreEquipeDomicile: 3,
          scoreEquipeExterieur: 2,
          butsEquipeDomicile: [
            But(buteur: yamal, minute: "52"),
            But(buteur: yamal, minute: "55"),
            But(buteur: pedri, minute: "83"),
          ],
          butsEquipeExterieur: [
            But(buteur: mbappe, minute: "4"),
            But(buteur: mastantuono, minute: "17"),
          ],
          joueursEquipeDomicile: [yamal, pedri],
          joueursEquipeExterieur: [mbappe, mastantuono],
          mvp: pedri,
        ),
      );
    }
    return; // ensure Future completes (optional) { changed code }
  }

  @override
  Future<List<Match>> fetchAllMatches() async {
    await _seedingFuture; // wait for seed to finish { changed code }
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Match>.from(_matches);
  }

  @override
  Future<Match?> fetchMatchById(String id) async {
    // Simuler un délai comme si on faisait un appel réseau
    await _seedingFuture; // wait for seed to finish { changed code }
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
