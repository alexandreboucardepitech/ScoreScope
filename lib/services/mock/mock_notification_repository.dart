import 'dart:async';

import 'package:scorescope/models/post/post_notification.dart';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/repositories/i_notification_repository.dart';

class MockNotificationRepository implements INotificationRepository {
  MockNotificationRepository() {
    _initSeed();
  }

  final Map<String, PostNotification> _notifications = {};

  late final Future<void> _seedingFuture = _initSeed();
  Future<void> get ready => _seedingFuture;

  Future<void> _initSeed() async {
    await MockAppUserRepository().ready;

    final now = DateTime.now().toUtc();

    _notifications[_key(
      userId: 'u_alex',
      ownerUserId: 'u_alex',
      matchId: '1',
    )] = PostNotification(
      ownerUserId: 'u_alex',
      matchId: '1',
      commentCounts: {'u_marie': 1},
      reactionCounts: {'u_jules': 1},
      hasNewComments: true,
      hasNewReactions: true,
      lastPostActivity: now.subtract(const Duration(minutes: 30)),
    );
  }

  String _key({
    required String userId,
    required String ownerUserId,
    required String matchId,
  }) =>
      '$userId|$ownerUserId|$matchId';

  PostNotification _getOrCreate({
    required String userId,
    required String ownerUserId,
    required String matchId,
  }) {
    final key = _key(
      userId: userId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    return _notifications.putIfAbsent(
      key,
      () => PostNotification(
        ownerUserId: ownerUserId,
        matchId: matchId,
        commentCounts: {},
        reactionCounts: {},
        hasNewComments: false,
        hasNewReactions: false,
        lastPostActivity: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<List<PostNotification>> fetchNotifications({
    required String userId,
  }) async {
    await ready;
    await Future.delayed(const Duration(milliseconds: 150));

    final list =
        _notifications.values.where((n) => n.ownerUserId == userId).toList();

    list.sort(
      (a, b) => b.lastPostActivity.compareTo(a.lastPostActivity),
    );

    return list;
  }

  @override
  Future<void> markNotificationSeen({
    required String userId,
    required String ownerUserId,
    required String matchId,
    String? type,
  }) async {
    await ready;
    await Future.delayed(const Duration(milliseconds: 80));

    final notif = _getOrCreate(
      userId: userId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    );
    final PostNotification newNotif;

    switch (type) {
      case "comments":
        newNotif = notif.copyWith(
          hasNewComments: false,
        );
      case "reactions":
        newNotif = notif.copyWith(
          hasNewReactions: false,
        );
      default:
        newNotif = notif.copyWith(
          hasNewComments: false,
          hasNewReactions: false,
        );
    }

    _notifications[_key(
      userId: userId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    )] = newNotif;
  }

  @override
  Future<void> markAllNotificationsSeen({
    required String userId,
  }) async {
    await ready;
    await Future.delayed(const Duration(milliseconds: 120));

    _notifications.updateAll((key, notif) {
      if (notif.ownerUserId != userId) return notif;

      if (!notif.hasNewComments && !notif.hasNewReactions) {
        return notif;
      }

      return notif.copyWith(
        hasNewComments: false,
        hasNewReactions: false,
      );
    });
  }

  @override
  Future<void> notifyNewComment({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    await ready;
    if (ownerUserId == authorId) return;

    final notif = _getOrCreate(
      userId: ownerUserId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final counts = Map<String, int>.from(notif.commentCounts);
    counts[authorId] = (counts[authorId] ?? 0) + 1;

    _notifications[_key(
      userId: ownerUserId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    )] = notif.copyWith(
      commentCounts: counts,
      hasNewComments: true,
      lastPostActivity: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> notifyNewReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    await ready;

    if (ownerUserId == authorId) return;

    final notif = _getOrCreate(
      userId: ownerUserId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    if (!notif.reactionCounts.values.contains(authorId)) {
      notif.reactionCounts[authorId] = 0;
    }

    _notifications[_key(
      userId: ownerUserId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    )] = notif.copyWith(
      hasNewReactions: true,
      lastPostActivity: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> notifyCommentDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    await ready;

    final key = _key(
      userId: ownerUserId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final notif = _notifications[key];
    if (notif == null) return;

    final counts = Map<String, int>.from(notif.commentCounts);
    final current = counts[authorId] ?? 0;

    if (current <= 1) {
      counts.remove(authorId);
    } else {
      counts[authorId] = current - 1;
    }

    _notifications[key] = notif.copyWith(
      commentCounts: counts,
      hasNewComments: counts.isNotEmpty,
    );
  }

  @override
  Future<void> notifyReactionDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    await ready;

    final key = _key(
      userId: ownerUserId,
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final notif = _notifications[key];
    if (notif == null) return;

    final counts = Map<String, int>.from(notif.reactionCounts);
    final current = counts[authorId] ?? 0;

    if (current <= 1) {
      counts.remove(authorId);
    } else {
      counts[authorId] = current - 1;
    }

    _notifications[key] = notif.copyWith(
      reactionCounts: counts,
      hasNewReactions: counts.isNotEmpty,
    );
  }

  @override
  Future<void> deleteOldNotifications({
    required String userId,
    required int daysLimit,
  }) async {
    await ready;

    final cutoff = DateTime.now().toUtc().subtract(Duration(days: daysLimit));

    _notifications.removeWhere(
      (_, notif) =>
          notif.ownerUserId == userId &&
          notif.lastPostActivity.isBefore(cutoff),
    );
  }

  @override
  Future<int> getNumberNotifications({required String userId}) async {
    int count = 0;
    List<PostNotification> notifications =
        await fetchNotifications(userId: userId);

    for (PostNotification notif in notifications) {
      if (notif.hasNewComments) count++;
      if (notif.hasNewReactions) count++;
    }

    return count;
  }
}
