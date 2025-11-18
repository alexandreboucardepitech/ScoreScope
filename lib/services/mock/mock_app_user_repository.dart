import 'dart:async';

import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/mock/mock_equipe_repository.dart';
import 'package:scorescope/services/mock/mock_match_repository.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';

class MockAppUserRepository implements IAppUserRepository {
  static final MockAppUserRepository _instance =
      MockAppUserRepository._internal();
  factory MockAppUserRepository() => _instance;

  late final Future<void> _seedingFuture;

  Future<void> get ready => _seedingFuture;

  final List<AppUser> _users = [];

  final String _currentUserId;

  MockAppUserRepository._internal({String currentUserId = 'u_alex'})
      : _currentUserId = currentUserId {
    _seedingFuture = _seed();
  }

  Future<void> _seed() async {
    final equipeRepository = MockEquipeRepository();
    final matchRepository = MockMatchRepository();

    await equipeRepository.ready;
    await matchRepository.ready;

    _users.add(
      AppUser(
        uid: 'u_alex',
        displayName: 'alex_foot',
        email: 'alex@example.com',
        bio:
            "coucou moi c'est alex et j'aime le foot (bah oui c'est mon nom t con)",
        equipesPrefereesId: ["2", "3"], // fc nantes / barça
        matchsUserData: [
          MatchUserData(matchId: "1", favourite: true, mvpVoteId: "1", note: 8),
          MatchUserData(matchId: "2", mvpVoteId: "5", note: 3),
        ],
        photoUrl: null,
        createdAt: DateTime.parse('2023-06-01T12:00:00Z'),
      ),
    );

    _users.add(
      AppUser(
        uid: 'u_marie',
        displayName: 'marie_goal',
        email: 'marie@example.com',
        equipesPrefereesId: ["1"], //psg
        matchsUserData: [
          MatchUserData(matchId: "1", mvpVoteId: "8", note: 4),
        ],
        photoUrl: null,
        createdAt: DateTime.parse('2022-11-15T08:30:00Z'),
      ),
    );

    _users.add(
      AppUser(
        uid: 'u_jules',
        displayName: 'jules_fan',
        email: 'jules@example.com',
        equipesPrefereesId: ["3", "4"], // barça / real madrid (hein ?)
        matchsUserData: [
          MatchUserData(matchId: "2", mvpVoteId: "5", note: 6),
        ],
        photoUrl: null,
        createdAt: DateTime.parse('2024-01-05T10:00:00Z'),
      ),
    );

    return;
  }

  @override
  Future<List<AppUser>> fetchAllUsers() async {
    await _seedingFuture;

    await Future.delayed(const Duration(milliseconds: 300));

    return _users;
  }

  @override
  Future<AppUser?> fetchUserById(String id) async {
    await _seedingFuture;
    try {
      return _users.firstWhere((u) => u.uid == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getUserEquipesPrefereesId(String userId) async {
    await _seedingFuture;
    final user = _users.firstWhere((u) => u.uid == userId,
        orElse: () => AppUser(uid: '', createdAt: DateTime.now()));
    return user.uid.isEmpty ? [] : user.equipesPrefereesId;
  }

  @override
  Future<List<String>> getUserMatchsRegardesId(String userId) async {
    await _seedingFuture;
    final user = _users.firstWhere((u) => u.uid == userId,
        orElse: () => AppUser(uid: '', createdAt: DateTime.now()));
    return user.uid.isEmpty
        ? []
        : user.matchsUserData.map((m) => m.matchId).toList();
  }

  @override
  Future<int> getUserNbMatchsRegardes(String userId) async {
    await _seedingFuture;
    final user = _users.firstWhere((u) => u.uid == userId,
        orElse: () => AppUser(uid: '', createdAt: DateTime.now()));
    return user.matchsUserData.length;
  }

  @override
  Future<int> getUserNbButs(String userId) async {
    await _seedingFuture;
    final user = _users.firstWhere((u) => u.uid == userId,
        orElse: () => AppUser(uid: '', createdAt: DateTime.now()));
    int nbButs = 0;
    Match? match;
    for (MatchUserData data in user.matchsUserData) {
      match = await MockMatchRepository().fetchMatchById(data.matchId);
      if (match != null) {
        nbButs =
            nbButs + match.scoreEquipeDomicile + match.scoreEquipeExterieur;
      }
    }
    return nbButs;
  }

  @override
  Future<int> getUserNbMatchsRegardesParEquipe(
      String userId, String equipeId) async {
    await _seedingFuture;

    final List<String> matchsRegardesId = await getUserMatchsRegardesId(userId);
    if (matchsRegardesId.isEmpty) return 0;

    final matchesRepo = MockMatchRepository();

    final futures =
        matchsRegardesId.map((id) => matchesRepo.fetchMatchById(id));
    final List<Match?> matches = await Future.wait(futures);

    int nbMatchs = 0;

    for (final match in matches) {
      if (match == null) continue;

      if (match.equipeDomicile.id == equipeId ||
          match.equipeExterieur.id == equipeId) {
        nbMatchs++;
      }
    }

    return nbMatchs;
  }

  @override
  Future<List<String>> getUserMatchsFavorisId(String userId) async {
    await _seedingFuture;
    final user = _users.firstWhere((u) => u.uid == userId,
        orElse: () => AppUser(uid: '', createdAt: DateTime.now()));
    return user.uid.isEmpty
        ? []
        : user.matchsUserData
            .where((match) => match.favourite == true)
            .map((m) => m.matchId)
            .toList();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    await _seedingFuture;
    final found = _users.firstWhere((u) => u.uid == _currentUserId,
        orElse: () => _users.first);
    return found;
  }

  Future<void> setNoteForMatch(String userId, String matchId, int? note) async {
    await _seedingFuture;
    final userIdx = _users.indexWhere((u) => u.uid == userId);
    if (userIdx < 0) return;

    final user = _users[userIdx];

    final List<MatchUserData> updated = List.from(user.matchsUserData);

    final muIdx = updated.indexWhere((m) => m.matchId == matchId);

    if (muIdx >= 0) {
      final old = updated[muIdx];
      updated[muIdx] = MatchUserData(
        matchId: old.matchId,
        favourite: old.favourite,
        mvpVoteId: old.mvpVoteId,
        note: note,
      );
    } else {
      updated.add(MatchUserData(
          matchId: matchId, favourite: false, mvpVoteId: null, note: note));
    }

    final newUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      equipesPrefereesId: user.equipesPrefereesId,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  Future<void> setMvpVoteForMatch(
      String userId, String matchId, String? joueurId) async {
    await _seedingFuture;
    final userIdx = _users.indexWhere((u) => u.uid == userId);
    if (userIdx < 0) return;

    final user = _users[userIdx];

    final List<MatchUserData> updated = List.from(user.matchsUserData);

    final muIdx = updated.indexWhere((m) => m.matchId == matchId);

    if (muIdx >= 0) {
      final old = updated[muIdx];
      updated[muIdx] = MatchUserData(
        matchId: old.matchId,
        favourite: old.favourite,
        mvpVoteId: joueurId,
        note: old.note,
      );
    } else {
      updated.add(MatchUserData(
          matchId: matchId, favourite: false, mvpVoteId: joueurId, note: null));
    }

    final newUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      equipesPrefereesId: user.equipesPrefereesId,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<void> matchFavori(String userId, String matchId, bool favori) async {
    await _seedingFuture;
    final userIdx = _users.indexWhere((u) => u.uid == userId);
    if (userIdx < 0) return;

    final user = _users[userIdx];

    final List<MatchUserData> updated = List.from(user.matchsUserData);

    final muIdx = updated.indexWhere((m) => m.matchId == matchId);

    if (muIdx >= 0) {
      final old = updated[muIdx];
      updated[muIdx] = MatchUserData(
        matchId: old.matchId,
        favourite: favori,
        mvpVoteId: old.mvpVoteId,
        note: old.note,
      );
    } else {
      updated.add(MatchUserData(
          matchId: matchId, favourite: favori, mvpVoteId: null, note: null));
    }

    final newUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      equipesPrefereesId: user.equipesPrefereesId,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<bool> isMatchFavori(String userId, String matchId) async {
    List<String> matchsFavoris = await getUserMatchsFavorisId(userId);
    return matchsFavoris.contains(matchId);
  }

  @override
  Future<VisionnageMatch> getVisionnageMatch(
      String userId, String matchId) async {
    await _seedingFuture;
    final user = _users.firstWhere((u) => u.uid == userId,
        orElse: () => AppUser(uid: '', createdAt: DateTime.now()));
    if (user.uid.isEmpty) return VisionnageMatch.tele;
    final matchData = user.matchsUserData.firstWhere(
        (m) => m.matchId == matchId,
        orElse: () => MatchUserData(matchId: matchId));
    return matchData.visionnageMatch;
  }

  @override
  Future<void> setVisionnageMatch(
      String matchId, String userId, VisionnageMatch visionnageMatch) async {
    await _seedingFuture;
    final userIdx = _users.indexWhere((u) => u.uid == userId);
    if (userIdx < 0) return;

    final user = _users[userIdx];

    final List<MatchUserData> updated = List.from(user.matchsUserData);

    final muIdx = updated.indexWhere((m) => m.matchId == matchId);

    if (muIdx >= 0) {
      final old = updated[muIdx];
      updated[muIdx] = MatchUserData(
        matchId: old.matchId,
        favourite: old.favourite,
        mvpVoteId: old.mvpVoteId,
        note: old.note,
        visionnageMatch: visionnageMatch,
      );
    } else {
      updated.add(
        MatchUserData(
          matchId: matchId,
          favourite: false,
          mvpVoteId: null,
          note: null,
          visionnageMatch: visionnageMatch,
        ),
      );
    }

    final newUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      equipesPrefereesId: user.equipesPrefereesId,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }
}
