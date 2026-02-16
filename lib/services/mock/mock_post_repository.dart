import 'dart:async';

import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/reaction.dart';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/mock/mock_notification_repository.dart';
import 'package:scorescope/services/repositories/i_post_repository.dart';
import 'package:scorescope/services/repository_provider.dart';

class MockPostRepository implements IPostRepository {
  MockPostRepository() {
    _seed();
  }

  // in-memory storage keyed by "$ownerUserId|$matchId"
  final Map<String, List<Commentaire>> _comments = {};
  final Map<String, List<Reaction>> _reactions = {};

  late final Future<void> _seedingFuture = _seed();

  Future<void> get ready => _seedingFuture;

  Future<void> _seed() async {
    await MockAppUserRepository().ready;

    final allUsers = await MockAppUserRepository().fetchAllUsers();
    for (final u in allUsers) {
      for (final mu in u.matchsUserData) {
        final key = _key(u.uid, mu.matchId);
        _comments.putIfAbsent(key, () => []);
        _reactions.putIfAbsent(key, () => []);
      }
    }

    // Example seeded comments & reactions
    _addCommentInternal(
      ownerUserId: 'u_alex',
      matchId: '1',
      comment: Commentaire(
        id: _genId(),
        authorId: 'u_marie',
        text: "Quel match ! Le but final était incroyable.",
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 90)),
      ),
    );

    _addReactionInternal(
      ownerUserId: 'u_alex',
      matchId: '1',
      reaction: Reaction(
        id: _genId(),
        userId: 'u_jules',
        emoji: '🔥',
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 80)),
      ),
    );

    _addCommentInternal(
      ownerUserId: 'u_marie',
      matchId: '1',
      comment: Commentaire(
        id: _genId(),
        authorId: 'u_jules',
        text: "WHOAAAAAA",
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 90)),
      ),
    );

    _addReactionInternal(
      ownerUserId: 'u_marie',
      matchId: '1',
      reaction: Reaction(
        id: _genId(),
        userId: 'u_jules',
        emoji: '👀',
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 80)),
      ),
    );
  }

  // -----------------------
  // Helpers
  // -----------------------
  String _key(String ownerUserId, String matchId) => '$ownerUserId|$matchId';
  String _genId() => DateTime.now().toUtc().millisecondsSinceEpoch.toString();

  void _addCommentInternal({
    required String ownerUserId,
    required String matchId,
    required Commentaire comment,
  }) {
    final key = _key(ownerUserId, matchId);
    final list = _comments.putIfAbsent(key, () => []);
    // keep newest-first
    list.insert(0, comment);
  }

  void _addReactionInternal({
    required String ownerUserId,
    required String matchId,
    required Reaction reaction,
  }) {
    final key = _key(ownerUserId, matchId);
    final list = _reactions.putIfAbsent(key, () => []);
    // insert newest-first
    list.insert(0, reaction);
  }

  // -------------------------
  // FRIENDS' MATCH USERDATA FETCH (kept behaviour)
  // -------------------------
  @override
  Future<List<UserMatchEntry>> fetchFriendsMatchesUserData({
    required String userId,
    bool onlyPublic = true,
    int? daysLimit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final friends =
        await RepositoryProvider.amitieRepository.fetchFriendsForUser(userId);
    if (friends.isEmpty) return [];

    final now = DateTime.now().toUtc();
    final DateTime? cutoff =
        daysLimit != null ? now.subtract(Duration(days: daysLimit)) : null;

    final List<UserMatchEntry> result = [];

    for (final friend in friends) {
      final friendMatches = await MockAppUserRepository()
          .fetchUserAllMatchUserData(
              userId: friend.uid, onlyPublic: onlyPublic);

      for (final md in friendMatches) {
        if (cutoff != null &&
            md.watchedAt != null &&
            md.watchedAt!.isBefore(cutoff)) {
          continue;
        }
        result.add(UserMatchEntry(user: friend, matchData: md));
      }
    }

    result.sort((a, b) {
      final da = a.matchData.watchedAt;
      final db = b.matchData.watchedAt;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return result;
  }

  @override
  Future<List<UserMatchEntry>> fetchFriendsMatchUserDataForMatch(
      String matchId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final friends =
        await RepositoryProvider.amitieRepository.fetchFriendsForUser(userId);
    if (friends.isEmpty) return [];

    final List<UserMatchEntry> result = [];

    for (final friend in friends) {
      final matchUserData = await MockAppUserRepository()
          .fetchUserMatchUserData(friend.uid, matchId);
      if (matchUserData != null) {
        result.add(UserMatchEntry(user: friend, matchData: matchUserData));
      }
    }

    result.sort((a, b) {
      final da = a.matchData.watchedAt;
      final db = b.matchData.watchedAt;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return result;
  }

  // -------------------------
  // COMMENTS
  // -------------------------
  @override
  Future<void> addComment({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String text,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 120));

    final comment = Commentaire(
      id: _genId(),
      authorId: authorId,
      text: text,
      createdAt: DateTime.now().toUtc(),
    );

    _addCommentInternal(
        ownerUserId: ownerUserId, matchId: matchId, comment: comment);

    MockNotificationRepository().notifyNewComment(
      ownerUserId: ownerUserId,
      matchId: matchId,
      authorId: authorId,
    );
  }

  @override
  Future<void> editComment({
    required String ownerUserId,
    required String matchId,
    required String commentId,
    required String newText,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 80));

    final key = _key(ownerUserId, matchId);
    final list = _comments.putIfAbsent(key, () => []);
    final idx = list.indexWhere((c) => c.id == commentId);
    if (idx >= 0) {
      final old = list[idx];
      final edited = Commentaire(
        id: old.id,
        authorId: old.authorId,
        text: newText,
        createdAt: old.createdAt,
      );
      list[idx] = edited;
    }
  }

  @override
  Future<void> deleteComment({
    required String ownerUserId,
    required String matchId,
    required String commentId,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 80));

    final key = _key(ownerUserId, matchId);
    final list = _comments.putIfAbsent(key, () => []);

    final idx = list.indexWhere((c) => c.id == commentId);
    if (idx == -1) return;

    final comment = list[idx];
    final authorId = comment.authorId;

    list.removeAt(idx);

    await MockNotificationRepository().notifyCommentDeleted(
      ownerUserId: ownerUserId,
      matchId: matchId,
      authorId: authorId,
    );
  }

  @override
  Future<List<Commentaire>> fetchComments({
    required String ownerUserId,
    required String matchId,
    int? limit,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 120));

    final key = _key(ownerUserId, matchId);
    final list = _comments.putIfAbsent(key, () => []);
    final copy = List<Commentaire>.from(list);
    if (limit != null && limit < copy.length) {
      return copy.take(limit).toList();
    }
    return copy;
  }

  // -------------------------
  // REACTIONS
  // -------------------------
  @override
  Future<void> addReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String emoji,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 100));

    final key = _key(ownerUserId, matchId);
    final list = _reactions.putIfAbsent(key, () => []);

    list.removeWhere((r) => r.userId == authorId && r.emoji == emoji);

    final reaction = Reaction(
      id: _genId(),
      userId: authorId,
      emoji: emoji,
      createdAt: DateTime.now().toUtc(),
    );

    list.insert(0, reaction);

    MockNotificationRepository().notifyNewReaction(
      ownerUserId: ownerUserId,
      matchId: matchId,
      authorId: authorId,
    );
  }

  @override
  Future<void> deleteReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String emoji,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 80));

    final key = _key(ownerUserId, matchId);
    final list = _reactions.putIfAbsent(key, () => []);

    final idx =
        list.indexWhere((c) => c.userId == authorId && c.emoji == emoji);
    if (idx == -1) return;

    list.removeAt(idx);

    await MockNotificationRepository().notifyCommentDeleted(
      ownerUserId: ownerUserId,
      matchId: matchId,
      authorId: authorId,
    );
  }

  @override
  Future<List<Reaction>> fetchReactions({
    required String ownerUserId,
    required String matchId,
    int? limit,
  }) async {
    await MockAppUserRepository().ready;
    await Future.delayed(const Duration(milliseconds: 120));

    final key = _key(ownerUserId, matchId);
    final list = _reactions.putIfAbsent(key, () => []);
    final copy = List<Reaction>.from(list);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && limit < copy.length) {
      return copy.take(limit).toList();
    }
    return copy;
  }
}
