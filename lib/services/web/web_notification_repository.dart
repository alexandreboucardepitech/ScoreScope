import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/post/post_notification.dart';
import 'package:scorescope/services/repositories/i_notification_repository.dart';

class WebNotificationRepository implements INotificationRepository {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  CollectionReference _notificationsCol(String userId) {
    return usersCollection.doc(userId).collection('postNotifications');
  }

  String _notificationId({
    required String ownerUserId,
    required String matchId,
  }) {
    return '${ownerUserId}_$matchId';
  }

  // FETCH

  @override
  Future<List<PostNotification>> fetchNotifications({
    required String userId,
  }) async {
    final snap = await _notificationsCol(userId)
        .orderBy('lastPostActivity', descending: true)
        .get();

    return snap.docs
        .map(
          (d) => PostNotification.fromJson(d.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> markNotificationSeen({
    required String userId,
    required String ownerUserId,
    required String matchId,
    String? type,
  }) async {
    final docRef = _notificationsCol(userId).doc(
      _notificationId(
        ownerUserId: ownerUserId,
        matchId: matchId,
      ),
    );

    switch (type) {
      case "comments":
        await docRef.update({
          'newCommentsCount': 0,
        });
      case "reactions":
        await docRef.update({
          'newReactionsCount': 0,
        });
      default:
        await docRef.update({
          'newCommentsCount': 0,
          'newReactionsCount': 0,
        });
    }
  }

  @override
  Future<void> markAllNotificationsSeen({
    required String userId,
  }) async {
    final querySnapshot = await _notificationsCol(userId).get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'newCommentsCount': 0,
        'newReactionsCount': 0,
      });
    }

    await batch.commit();
  }

  @override
  Future<void> notifyNewComment({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    if (ownerUserId == authorId) return;

    final docRef = _notificationsCol(ownerUserId).doc(
      _notificationId(ownerUserId: ownerUserId, matchId: matchId),
    );

    await FirebaseFirestore.instance.runTransaction((tx) async {
      await docRef.set({
        'ownerUserId': ownerUserId,
        'matchId': matchId,
        'commentCounts': {
          authorId: FieldValue.increment(1),
        },
        'newCommentsCount': FieldValue.increment(1),
        'lastPostActivity': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> notifyNewReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    if (ownerUserId == authorId) return;

    final docRef = _notificationsCol(ownerUserId).doc(
      _notificationId(ownerUserId: ownerUserId, matchId: matchId),
    );

    await FirebaseFirestore.instance.runTransaction((tx) async {
      await docRef.set({
        'ownerUserId': ownerUserId,
        'matchId': matchId,
        'reactionCounts': {
          authorId: FieldValue.increment(1),
        },
        'newReactionsCount': FieldValue.increment(1),
        'lastPostActivity': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> notifyCommentDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    final docRef = _notificationsCol(ownerUserId).doc(
      _notificationId(
        ownerUserId: ownerUserId,
        matchId: matchId,
      ),
    );

    await docRef.set({
      'commentCounts': {
        authorId: FieldValue.increment(-1),
      },
      'newCommentsCount': FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> notifyReactionDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    final docRef = _notificationsCol(ownerUserId).doc(
      _notificationId(
        ownerUserId: ownerUserId,
        matchId: matchId,
      ),
    );

    await docRef.set({
      'reactionCounts': {
        authorId: FieldValue.increment(-1),
      },
      'newReactionsCount': FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteOldNotifications({
    required String userId,
    int daysLimit = 14,
  }) async {
    final cutoff =
        Timestamp.fromDate(DateTime.now().subtract(Duration(days: daysLimit)));

    final snap = await _notificationsCol(userId)
        .where('lastPostActivity', isLessThan: cutoff)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<int> getNumberNotifications({required String userId}) async {
    int count = 0;
    List<PostNotification> notifications =
        await fetchNotifications(userId: userId);

    for (PostNotification notif in notifications) {
      if (notif.newCommentsCount > 0) count++;
      if (notif.newReactionsCount > 0) count++;
    }

    return count;
  }
}
