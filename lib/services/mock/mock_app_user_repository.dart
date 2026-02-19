import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/mock/mock_equipe_repository.dart';
import 'package:scorescope/services/mock/mock_match_repository.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';

class MockAppUserRepository implements IAppUserRepository {
  MockAppUserRepository({String currentUserId = 'u_alex'})
      : _currentUserId = currentUserId {
    _seedingFuture = _seed();
  }

  late final Future<void> _seedingFuture;

  Future<void> get ready => _seedingFuture;

  final List<AppUser> _users = [];

  final String _currentUserId;

  @override
  AppUser?
      currentUser; // à utiliser que quand on ne peut vraiment pas faire d'async

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
        competitionsPrefereesId: ["1", "2"], // ligue 1 / laliga
        private: false,
        matchsUserData: [
          MatchUserData(
            matchId: "1",
            favourite: true,
            mvpVoteId: "1",
            note: 8,
            visionnageMatch: VisionnageMatch.stade,
            private: false,
            watchedAt: DateTime.now().subtract(const Duration(minutes: 30)),
            matchDate: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          MatchUserData(
            matchId: "2",
            mvpVoteId: "5",
            note: 3,
            private: true,
            watchedAt: DateTime.parse('2025-11-02T18:00:00Z'),
          ),
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
        competitionsPrefereesId: ["1", "3"], // ligue 1 / ldc
        private: true,
        matchsUserData: [
          MatchUserData(
            matchId: "1",
            mvpVoteId: "8",
            note: 4,
            favourite: true,
            private: false,
            visionnageMatch: VisionnageMatch.tele,
            watchedAt: DateTime.now().subtract(const Duration(minutes: 45)),
            matchDate: DateTime.now().subtract(const Duration(hours: 3)),
          ),
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
        competitionsPrefereesId: ["2"], // laliga
        private: false,
        matchsUserData: [
          MatchUserData(
            matchId: "2",
            mvpVoteId: "5",
            note: 6,
            private: false,
            favourite: false,
            visionnageMatch: VisionnageMatch.bar,
            watchedAt: DateTime.now(),
            matchDate: DateTime.now(),
          ),
        ],
        photoUrl: null,
        createdAt: DateTime.parse('2024-01-05T10:00:00Z'),
      ),
    );
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
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    return user.uid.isEmpty ? [] : user.equipesPrefereesId;
  }

  @override
  Future<List<String>> getUserMatchsRegardesId(
      {required String userId,
      bool onlyPublic = false,
      DateTimeRange? dateRange}) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (user.uid.isEmpty) return [];
    final matchsRegardes = onlyPublic
        ? user.matchsUserData
            .where((m) => m.private == false)
            .where((m) => dateRange != null
                ? m.watchedAt != null &&
                    m.watchedAt!.isAfter(
                        dateRange.start.subtract(const Duration(days: 1))) &&
                    m.watchedAt!
                        .isBefore(dateRange.end.add(const Duration(days: 1)))
                : true)
            .map((m) => m.matchId)
            .toList()
        : user.matchsUserData.map((m) => m.matchId).toList();
    return matchsRegardes;
  }

  @override
  Future<int> getUserNbMatchsRegardes(String userId, bool onlyPublic) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (user.uid.isEmpty) return 0;
    final matchsRegardes = onlyPublic
        ? user.matchsUserData.where((m) => m.private == false).toList()
        : user.matchsUserData;
    return matchsRegardes.length;
  }

  @override
  Future<int> getUserNbButs(String userId, bool onlyPublic) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    int nbButs = 0;
    MatchModel? match;
    for (MatchUserData data in user.matchsUserData) {
      if (onlyPublic && data.private) {
        continue;
      }
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
      String userId, String equipeId, bool onlyPublic) async {
    await _seedingFuture;

    final List<String> matchsRegardesId =
        await getUserMatchsRegardesId(userId: userId, onlyPublic: onlyPublic);
    if (matchsRegardesId.isEmpty) return 0;

    final matchesRepo = MockMatchRepository();

    final futures =
        matchsRegardesId.map((id) => matchesRepo.fetchMatchById(id));
    final List<MatchModel?> matches = await Future.wait(futures);

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
  Future<int> getUserNbMatchsRegardesParCompetition(
      String userId, String compId, bool onlyPublic) async {
    await _seedingFuture;

    final List<String> matchsRegardesId =
        await getUserMatchsRegardesId(userId: userId, onlyPublic: onlyPublic);
    if (matchsRegardesId.isEmpty) return 0;

    final matchesRepo = MockMatchRepository();

    final futures =
        matchsRegardesId.map((id) => matchesRepo.fetchMatchById(id));
    final List<MatchModel?> matches = await Future.wait(futures);

    int nbMatchs = 0;

    for (final match in matches) {
      if (match == null) continue;

      if (match.competition.id == compId) {
        nbMatchs++;
      }
    }

    return nbMatchs;
  }

  @override
  Future<List<String>> getUserMatchsFavorisId(
      String userId, bool onlyPublic) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (user.uid.isEmpty) return [];
    final favoris = user.matchsUserData
        .where((m) => m.favourite == true)
        .where((m) => onlyPublic ? m.private == false : true)
        .map((m) => m.matchId)
        .toList();
    return favoris;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    await _seedingFuture;
    final found = _users.firstWhere((u) => u.uid == _currentUserId,
        orElse: () => _users.first);
    currentUser = found;
    return found;
  }

  Future<void> setNoteForMatch(
      String userId, String matchId, DateTime matchDate, int? note) async {
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
        visionnageMatch: old.visionnageMatch,
        private: old.private,
      );
    } else {
      updated.add(
        MatchUserData(
          matchId: matchId,
          favourite: false,
          mvpVoteId: null,
          note: note,
          visionnageMatch: VisionnageMatch.tele,
          private: false,
          matchDate: matchDate,
          watchedAt: DateTime.now(),
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
      competitionsPrefereesId: user.competitionsPrefereesId,
      private: user.private,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  Future<void> setMvpVoteForMatch(
    String userId,
    String matchId,
    DateTime matchDate,
    String? joueurId,
  ) async {
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
        visionnageMatch: old.visionnageMatch,
        private: old.private,
      );
    } else {
      updated.add(
        MatchUserData(
          matchId: matchId,
          favourite: false,
          mvpVoteId: joueurId,
          note: null,
          visionnageMatch: VisionnageMatch.tele,
          private: false,
          matchDate: matchDate,
          watchedAt: DateTime.now(),
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
      competitionsPrefereesId: user.competitionsPrefereesId,
      private: user.private,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<void> matchFavori(
    String userId,
    String matchId,
    DateTime matchDate,
    bool favori,
  ) async {
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
        visionnageMatch: old.visionnageMatch,
        private: old.private,
        comments: old.comments,
        reactions: old.reactions,
        matchDate: old.matchDate,
        watchedAt: old.watchedAt,
      );
    } else {
      updated.add(
        MatchUserData(
          matchId: matchId,
          favourite: favori,
          mvpVoteId: null,
          note: null,
          visionnageMatch: VisionnageMatch.tele,
          private: false,
          matchDate: matchDate,
          watchedAt: DateTime.now(),
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
      competitionsPrefereesId: user.competitionsPrefereesId,
      private: user.private,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<bool> isMatchFavori(String userId, String matchId) async {
    List<String> matchsFavoris = await getUserMatchsFavorisId(userId, false);
    return matchsFavoris.contains(matchId);
  }

  @override
  Future<VisionnageMatch> getVisionnageMatch(
      String userId, String matchId) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (user.uid.isEmpty) return VisionnageMatch.tele;
    final matchData = user.matchsUserData.firstWhere(
        (m) => m.matchId == matchId,
        orElse: () => MatchUserData(matchId: matchId));
    return matchData.visionnageMatch;
  }

  @override
  Future<void> setVisionnageMatch(
    String matchId,
    String userId,
    DateTime matchDate,
    VisionnageMatch visionnageMatch,
  ) async {
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
        private: old.private,
        comments: old.comments,
        reactions: old.reactions,
        matchDate: old.matchDate,
        watchedAt: old.watchedAt,
      );
    } else {
      updated.add(
        MatchUserData(
          matchId: matchId,
          favourite: false,
          mvpVoteId: null,
          note: null,
          visionnageMatch: visionnageMatch,
          private: false,
          matchDate: matchDate,
          watchedAt: DateTime.now(),
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
      competitionsPrefereesId: user.competitionsPrefereesId,
      private: user.private,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<bool> getMatchPrivacy(String userId, String matchId) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (user.uid.isEmpty) return false;
    final matchData = user.matchsUserData.firstWhere(
        (m) => m.matchId == matchId,
        orElse: () => MatchUserData(matchId: matchId));
    return matchData.private;
  }

  @override
  Future<void> setMatchPrivacy(
    String matchId,
    String userId,
    DateTime matchDate,
    bool privacy,
  ) async {
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
        visionnageMatch: old.visionnageMatch,
        private: privacy,
        comments: old.comments,
        reactions: old.reactions,
        matchDate: old.matchDate,
        watchedAt: old.watchedAt,
      );
    } else {
      updated.add(
        MatchUserData(
          matchId: matchId,
          favourite: false,
          mvpVoteId: null,
          note: null,
          visionnageMatch: VisionnageMatch.tele,
          private: privacy,
          matchDate: matchDate,
          watchedAt: DateTime.now(),
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
      competitionsPrefereesId: user.competitionsPrefereesId,
      private: user.private,
      matchsUserData: updated,
    );

    _users[userIdx] = newUser;

    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<List<AppUser>> searchUsersByPrefix(String prefix,
      {int limit = 50}) async {
    await _seedingFuture;

    final queryLower = prefix.toLowerCase();

    final filtered = _users.where((u) {
      final name = u.displayName.toLowerCase();
      return name.contains(queryLower);
    }).toList();

    return filtered.take(limit).toList();
  }

  @override
  Future<List<MatchUserData>> fetchUserAllMatchUserData(
      {required String userId,
      bool onlyPublic = false,
      DateTimeRange? dateRange}) async {
    await _seedingFuture;
    final user = _users.firstWhere(
      (u) => u.uid == userId,
      orElse: () => AppUser(
        uid: '',
        displayName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (user.uid.isEmpty) return [];
    if (onlyPublic) {
      return user.matchsUserData.where((m) => m.private == false).toList();
    } else {
      return user.matchsUserData;
    }
  }

  @override
  Future<void> removeMatchUserData(String userId, String matchId) async {
    await _seedingFuture;

    final userIdx = _users.indexWhere((u) => u.uid == userId);
    if (userIdx < 0) return;

    final user = _users[userIdx];

    final updated = user.matchsUserData
        .where((m) => m.matchId != matchId)
        .toList(); // trouve la liste de tous les matchs avec un id DIFFÉRENT de matchId

    final newUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      equipesPrefereesId: user.equipesPrefereesId,
      competitionsPrefereesId: user.competitionsPrefereesId,
      private: user.private,
      matchsUserData: updated,
    );
    _users[userIdx] = newUser;

    // également, dans le mock match repository, enlever la note et le vote MVP
    await MockMatchRepository().removeUserDataFromMatch(matchId, userId);
  }

  @override
  Future<MatchUserData?> fetchUserMatchUserData(String userId, String matchId) {
    return fetchUserAllMatchUserData(userId: userId, onlyPublic: false)
        .then((allData) {
      try {
        return allData.firstWhere((m) => m.matchId == matchId);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> editProfile({
    required String userId,
    File? newProfilePicture,
    String? newUsername,
    String? newBio,
    List<String>? newEquipesPrefereesId,
    List<String>? newCompetitionsPrefereesId,
    bool photoRemoved = false,
  }) async {
    final userIdx = _users.indexWhere((u) => u.uid == userId);
    if (userIdx < 0) return;

    final user = _users[userIdx];

    final newUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: newUsername ?? user.displayName,
      bio: newBio ?? user.bio,
      photoUrl: newProfilePicture != null || photoRemoved
          ? newProfilePicture!.path
          : user.photoUrl,
      createdAt: user.createdAt,
      equipesPrefereesId: newEquipesPrefereesId ?? user.equipesPrefereesId,
      matchsUserData: user.matchsUserData,
      competitionsPrefereesId:
          newCompetitionsPrefereesId ?? user.competitionsPrefereesId,
      private: user.private,
    );

    _users[userIdx] = newUser;
  }
}
