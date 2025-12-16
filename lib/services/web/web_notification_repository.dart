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
          'hasNewComments': false,
        });
      case "reactions":
        await docRef.update({
          'hasNewReactions': false,
        });
      default:
        await docRef.update({
          'hasNewComments': false,
          'hasNewReactions': false,
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
        'hasNewComments': false,
        'hasNewReactions': false,
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
      final snap = await tx.get(docRef);

      if (!snap.exists) {
        tx.set(docRef, {
          'ownerUserId': ownerUserId,
          'matchId': matchId,
          'commentCounts': {authorId: 1},
          'reactionCounts': {},
          'hasNewComments': true,
          'hasNewReactions': false,
          'lastPostActivity': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(docRef, {
          'commentCounts.$authorId': FieldValue.increment(1),
          'hasNewComments': true,
          'lastPostActivity': FieldValue.serverTimestamp(),
        });
      }
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
      final snap = await tx.get(docRef);

      if (!snap.exists) {
        tx.set(docRef, {
          'ownerUserId': ownerUserId,
          'matchId': matchId,
          'commentCounts': {},
          'reactionCounts': {authorId: 1},
          'hasNewComments': false,
          'hasNewReactions': true,
          'lastPostActivity': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(docRef, {
          'reactionCounts.$authorId': FieldValue.increment(1),
          'hasNewReactions': true,
          'lastPostActivity': FieldValue.serverTimestamp(),
        });
      }
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

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final Map<String, dynamic> counts =
          Map<String, dynamic>.from(data['commentCounts'] ?? {});

      final int currentCount = (counts[authorId] ?? 0) as int;

      if (currentCount <= 0) return;

      if (currentCount == 1) {
        tx.update(docRef, {
          'commentCounts.$authorId': FieldValue.delete(),
        });
        counts.remove(authorId);
      } else {
        // Décrément
        tx.update(docRef, {
          'commentCounts.$authorId': FieldValue.increment(-1),
        });
        counts[authorId] = currentCount - 1;
      }

      // Mise à jour du flag global
      tx.update(docRef, {
        'hasNewComments': counts.isNotEmpty,
      });
    });
  }

  @override
  Future<void> notifyReactionDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  }) async {
    final docRef = _notificationsCol(ownerUserId).doc(
      _notificationId(ownerUserId: ownerUserId, matchId: matchId),
    );

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final counts = Map<String, dynamic>.from(data['reactionCounts'] ?? {});

      final current = (counts[authorId] ?? 0) as int;
      if (current <= 1) {
        tx.update(docRef, {
          'reactionCounts.$authorId': FieldValue.delete(),
        });
        counts.remove(authorId);
      } else {
        tx.update(docRef, {
          'reactionCounts.$authorId': FieldValue.increment(-1),
        });
        counts[authorId] = current - 1;
      }

      tx.update(docRef, {
        'hasNewReactions': counts.isNotEmpty,
      });
    });
  }

  @override
  Future<void> deleteOldNotifications({
    required String userId,
    required int daysLimit,
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
    List<PostNotification> notifications = await fetchNotifications(userId: userId);

    for (PostNotification notif in notifications) {
      if (notif.hasNewComments) count++;
      if (notif.hasNewReactions) count++;
    }

    return count;
  }
}
