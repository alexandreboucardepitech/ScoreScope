import 'dart:async';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/mock/mock_competition_repository.dart';
import 'package:scorescope/services/mock/mock_equipe_repository.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';
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

  final List<MatchModel> _matches = [];
  final IEquipeRepository equipeRepository = MockEquipeRepository();
  final IJoueurRepository joueurRepository = MockJoueurRepository();
  final ICompetitionRepository competitionRepository =
      MockCompetitionRepository();

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

    final ligue1 = await competitionRepository.fetchCompetitionById("1");
    final laliga = await competitionRepository.fetchCompetitionById("2");

    if (psg != null &&
        fcnantes != null &&
        abline != null &&
        benhattab != null &&
        leroux != null &&
        hakimi != null &&
        ligue1 != null) {
      _matches.add(
        MatchModel(
          id: "1",
          status: MatchStatus.finished,
          liveMinute: null,
          equipeDomicile: psg,
          equipeExterieur: fcnantes,
          competition: ligue1,
          date: DateTime.now().subtract(const Duration(hours: 3)),
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
        mastantuono != null &&
        laliga != null) {
      _matches.add(
        MatchModel(
          id: "2",
          status: MatchStatus.live,
          liveMinute: "72'",
          equipeDomicile: barca,
          equipeExterieur: realmadrid,
          competition: laliga,
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
  Future<List<MatchModel>> fetchAllMatches() async {
    await _seedingFuture;
    await Future.delayed(const Duration(milliseconds: 300));
    return List<MatchModel>.from(_matches);
  }

  @override
  Future<MatchModel?> fetchMatchById(String id) async {
    await _seedingFuture;
    await Future.delayed(Duration(milliseconds: 200));

    try {
      final match = _matches.firstWhere((match) => match.id == id);
      return match;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<MatchModel>> fetchMatchesListById(List<String> ids) async {
    List<MatchModel> matches = [];
    for (String id in ids) {
      MatchModel? match = await fetchMatchById(id);
      if (match != null) {
        matches.add(match);
      }
    }
    return matches;
  }

  @override
  Future<List<MatchModel>> fetchMatchesByDate(DateTime date) async {
    await _seedingFuture;
    // Simule un léger délai réseau
    await Future.delayed(const Duration(milliseconds: 200));

    return _matches.where((match) {
      return match.date.year == date.year &&
          match.date.month == date.month &&
          match.date.day == date.day;
    }).toList();
  }

  @override
  Future<void> addMatch(MatchModel match) async {
    _matches.add(match);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updateMatch(MatchModel match) async {
    final idx = _matches.indexWhere((x) => x == match);
    if (idx >= 0) _matches[idx] = match;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> deleteMatch(MatchModel match) async {
    _matches.remove(match);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> noterMatch(String matchId, String userId, int? note) async {
    final idx = _matches.indexWhere((match) => match.id == matchId);
    if (idx < 0) return;

    final match = _matches[idx];

    if (note != null) {
      // ne pas réinitialiser : on écrit directement dans la map existante
      match.notesDuMatch[userId] = note;
    } else {
      match.notesDuMatch.remove(userId);
    }

    // mettre à jour le mock AppUser.matchsUserData
    await MockAppUserRepository().setNoteForMatch(userId, matchId, note);

    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> voterPourMVP(
      String matchId, String userId, String? joueurId) async {
    final idx = _matches.indexWhere((match) => match.id == matchId);
    if (idx < 0) return;

    final match = _matches[idx];

    if (joueurId != null) {
      match.mvpVotes[userId] = joueurId;
    } else {
      match.mvpVotes.remove(userId);
    }

    await MockAppUserRepository().setMvpVoteForMatch(userId, matchId, joueurId);

    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> enleverVote(String matchId, String userId) async {
    final idx = _matches.indexWhere((match) => match.id == matchId);
    if (idx < 0) return;

    final match = _matches[idx];

    match.mvpVotes.remove(userId);

    // supprimer le mvpVoteId dans l'user data (en le mettant à null)
    await MockAppUserRepository().setMvpVoteForMatch(userId, matchId, null);

    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> removeUserDataFromMatch(String matchId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _matches.indexWhere((match) => match.id == matchId);
    if (idx < 0) return;

    final match = _matches[idx];

    match.notesDuMatch.remove(userId);
    match.mvpVotes.remove(userId);
  }
}
