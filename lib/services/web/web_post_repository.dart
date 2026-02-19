import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/reaction.dart';
import 'package:scorescope/services/repositories/i_post_repository.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/services/web/web_notification_repository.dart';

class WebPostRepository implements IPostRepository {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<List<UserMatchEntry>> fetchFriendsMatchesUserData({
    required String userId,
    bool onlyPublic = true,
    int? daysLimit,
  }) async {
    final friends =
        await RepositoryProvider.amitieRepository.fetchFriendsForUser(userId);
    if (friends.isEmpty) return [];

    final now = DateTime.now().toUtc();
    final DateTime? cutoff =
        daysLimit != null ? now.subtract(Duration(days: daysLimit)) : null;

    final usersCollection = FirebaseFirestore.instance.collection('users');

    final List<UserMatchEntry> allEntries = [];

    for (final friend in friends) {
      final friendId = friend.uid;

      final collRef = usersCollection.doc(friendId).collection('matchUserData');
      final subCollectionSnap = onlyPublic
          ? await collRef.where('private', isEqualTo: false).get()
          : await collRef.get();

      for (final doc in subCollectionSnap.docs) {
        final map = doc.data();

        try {
          final matchUserData = MatchUserData.fromJson(map);

          if (onlyPublic &&
              (map['private'] == true || matchUserData.private == true)) {
            continue;
          }

          if (cutoff != null &&
              matchUserData.watchedAt != null &&
              matchUserData.watchedAt!.isBefore(cutoff)) {
            continue;
          }

          allEntries.add(
            UserMatchEntry(
              user: friend,
              matchData: matchUserData,
            ),
          );
        } catch (_) {}
      }
    }

    allEntries.sort((a, b) {
      final da = a.matchData.watchedAt;
      final db = b.matchData.watchedAt;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return allEntries;
  }

  @override
  Future<List<UserMatchEntry>> fetchFriendsMatchUserDataForMatch(
      String matchId, String userId) async {
    final friends =
        await RepositoryProvider.amitieRepository.fetchFriendsForUser(userId);
    if (friends.isEmpty) return [];

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final List<UserMatchEntry> entries = [];

    for (final friend in friends) {
      final friendId = friend.uid;

      Query query = usersCollection
          .doc(friendId)
          .collection('matchUserData')
          .where('matchId', isEqualTo: matchId)
          .where('private', isEqualTo: false);

      final matchUserDataQuery = await query.get();

      for (final doc in matchUserDataQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          final matchUserData = MatchUserData.fromJson(data);

          if (data['private'] == true || matchUserData.private == true) {
            continue;
          }

          entries.add(
            UserMatchEntry(
              user: friend,
              matchData: matchUserData,
            ),
          );
        } catch (_) {}
      }
    }

    entries.sort((a, b) {
      final da = a.matchData.watchedAt;
      final db = b.matchData.watchedAt;

      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return entries;
  }

  Future<DocumentReference> _findMatchUserDataDocRef({
    required String ownerUserId,
    required String matchId,
  }) async {
    final coll = usersCollection.doc(ownerUserId).collection('matchUserData');

    final docRef = coll.doc(matchId);
    final snap = await docRef.get();

    if (!snap.exists) {
      throw StateError(
          'matchUserData not found for owner=$ownerUserId matchId=$matchId (tried doc id)');
    }

    return docRef;
  }

  // COMMENTS

  @override
  Future<void> addComment({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String text,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final commentsRef = parentRef.collection('comments');

    final newDocRef = commentsRef.doc();
    final commentData = {
      'authorId': authorId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await newDocRef.set(commentData);

    WebNotificationRepository().notifyNewComment(
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
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final commentRef = parentRef.collection('comments').doc(commentId);

    await commentRef.update({
      'text': newText,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteComment({
    required String ownerUserId,
    required String matchId,
    required String commentId,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final commentRef = parentRef.collection('comments').doc(commentId);

    final snap = await commentRef.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final authorId = data['authorId'] as String;

    await commentRef.delete();

    await WebNotificationRepository().notifyCommentDeleted(
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
    bool removeBlockedUsersComments = false,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    Query query =
        parentRef.collection('comments').orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);

    final snap = await query.get();
    var docs = snap.docs;
    if (removeBlockedUsersComments &&
        RepositoryProvider.userRepository.currentUser != null) {
      final currentUserId = RepositoryProvider.userRepository.currentUser!.uid;
      final blockedUsers = await RepositoryProvider.amitieRepository
          .fetchBlockedUsers(currentUserId, 'both');
      final blockedIds = blockedUsers.map((b) {
        if (b.firstUserId == currentUserId) {
          return b.secondUserId;
        } else {
          return b.firstUserId;
        }
      }).toList();
      docs.removeWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final authorId = data['authorId'] as String;
        return blockedIds.contains(authorId);
      });
    }
    return docs
        .map(
            (d) => Commentaire.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // REACTIONS

  @override
  Future<void> addReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String emoji,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final reactionsRef = parentRef.collection('reactions');

    final data = {
      'userId': authorId,
      'emoji': emoji,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await reactionsRef.add(data);

    WebNotificationRepository().notifyNewReaction(
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
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    final CollectionReference reactionsCol = parentRef.collection('reactions');

    final query = reactionsCol
        .where('userId', isEqualTo: authorId)
        .where('emoji', isEqualTo: emoji);

    final snap = await query.get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await WebNotificationRepository().notifyReactionDeleted(
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
    bool removeBlockedUsersReactions = false,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    Query query = parentRef
        .collection('reactions')
        .orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);

    final snap = await query.get();
    var docs = snap.docs;
    if (removeBlockedUsersReactions &&
        RepositoryProvider.userRepository.currentUser != null) {
      final currentUserId = RepositoryProvider.userRepository.currentUser!.uid;
      final blockedUsers = await RepositoryProvider.amitieRepository
          .fetchBlockedUsers(currentUserId, 'both');
      final blockedIds = blockedUsers.map((b) {
        if (b.firstUserId == currentUserId) {
          return b.secondUserId;
        } else {
          return b.firstUserId;
        }
      }).toList();
      docs.removeWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String;
        return blockedIds.contains(userId);
      });
    }
    return docs
        .map((d) => Reaction.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }
}
