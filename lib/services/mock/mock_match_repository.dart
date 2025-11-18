import 'dart:async';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/mock/mock_equipe_repository.dart';
import 'package:scorescope/services/repositories/i_joueur_repository.dart';
import 'package:scorescope/services/mock/mock_joueur_repository.dart';

import '../../models/match.dart';
import '../../models/but.dart';
import '../repositories/i_match_repository.dart';
import '../repositories/i_equipe_repository.dart';
// import 'package:uuid/uuid.dart';

class MockMatchRepository implements IMatchRepository {
  static final MockMatchRepository _instance = MockMatchRepository._internal();

  late final Future<void> _seedingFuture; // { changed code }

  MockMatchRepository._internal() {
    _seedingFuture = _seed(); // { changed code }
  } // { changed code }

  factory MockMatchRepository() {
    return _instance;
  }

  Future<void> get ready => _seedingFuture;

  final List<Match> _matches = [];
  final IEquipeRepository equipeRepository = MockEquipeRepository();
  final IJoueurRepository joueurRepository = MockJoueurRepository();

  Future<void> _seed() async {
    await MockJoueurRepository().ready;
    await MockEquipeRepository().ready;

    final abline = await joueurRepository.fetchJoueurById("1");
    final benhattab = await joueurRepository.fetchJoueurById("2");
    final leroux = await joueurRepository.fetchJoueurById("3");
    final yamal = await joueurRepository.fetchJoueurById("4");
    final pedri = await joueurRepository.fetchJoueurById("5");
    final mbappe = await joueurRepository.fetchJoueurById("6");
    final mastantuono = await joueurRepository.fetchJoueurById("7");
    final hakimi = await joueurRepository.fetchJoueurById("8");

    final psg = await equipeRepository.fetchEquipeById("1");
    final fcnantes = await equipeRepository.fetchEquipeById("2");
    final barca = await equipeRepository.fetchEquipeById("3");
    final realmadrid = await equipeRepository.fetchEquipeById("4");

    if (psg != null &&
        fcnantes != null &&
        abline != null &&
        benhattab != null &&
        leroux != null &&
        hakimi != null) {
      _matches.add(
        Match(
          id: "1",
          equipeDomicile: psg,
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
          joueursEquipeDomicile: [hakimi],
          joueursEquipeExterieur: [abline, benhattab, leroux],
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
        ),
      );
    }
    return;
  }

  @override
  Future<List<Match>> fetchAllMatches() async {
    await _seedingFuture;
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Match>.from(_matches);
  }

  @override
  Future<Match?> fetchMatchById(String id) async {
    await _seedingFuture;
    await Future.delayed(Duration(milliseconds: 200));

    try {
      final match = _matches.firstWhere((m) => m.id == id);
      return match;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Match>> fetchMatchesListById(List<String> ids) async {
    List<Match> matches = [];
    for (String id in ids) {
      Match? match = await fetchMatchById(id);
      if (match != null) {
        matches.add(match);
      }
    }
    return matches;
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

  @override
  Future<void> noterMatch(String matchId, String userId, int? note) async {
    final idx = _matches.indexWhere((m) => m.id == matchId);
    if (idx < 0) return;

    final m = _matches[idx];

    if (note != null) {
      // ne pas réinitialiser : on écrit directement dans la map existante
      m.notesDuMatch[userId] = note;
    } else {
      m.notesDuMatch.remove(userId);
    }

    // mettre à jour le mock AppUser.matchsUserData
    await MockAppUserRepository().setNoteForMatch(userId, matchId, note);

    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> voterPourMVP(
      String matchId, String userId, String? joueurId) async {
    final idx = _matches.indexWhere((m) => m.id == matchId);
    if (idx < 0) return;

    final m = _matches[idx];

    if (joueurId != null) {
      m.mvpVotes[userId] = joueurId;
    } else {
      m.mvpVotes.remove(userId);
    }

    await MockAppUserRepository().setMvpVoteForMatch(userId, matchId, joueurId);

    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> enleverVote(String matchId, String userId) async {
    final idx = _matches.indexWhere((m) => m.id == matchId);
    if (idx < 0) return;

    final m = _matches[idx];

    m.mvpVotes.remove(userId);

    // supprimer le mvpVoteId dans l'user data (en le mettant à null)
    await MockAppUserRepository().setMvpVoteForMatch(userId, matchId, null);

    await Future.delayed(const Duration(milliseconds: 50));
  }
}
