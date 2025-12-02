import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/reaction.dart';
import 'package:scorescope/services/repositories/i_post_repository.dart';
import 'package:scorescope/services/repository_provider.dart';

class WebPostRepository implements IPostRepository {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<List<FriendMatchEntry>> fetchFriendsMatchesUserData(
    String userId, {
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

    final List<FriendMatchEntry> allEntries = [];

    for (final friend in friends) {
      final friendId = friend.uid;

      final subCollectionSnap =
          await usersCollection.doc(friendId).collection('matchUserData').get();

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
            FriendMatchEntry(
              friend: friend,
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
  Future<List<FriendMatchEntry>> fetchFriendsMatchUserDataForMatch(
      String matchId, String userId) async {
    final friends =
        await RepositoryProvider.amitieRepository.fetchFriendsForUser(userId);
    if (friends.isEmpty) return [];

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final List<FriendMatchEntry> entries = [];

    for (final friend in friends) {
      final friendId = friend.uid;

      final matchUserDataQuery = await usersCollection
          .doc(friendId)
          .collection('matchUserData')
          .where('matchId', isEqualTo: matchId)
          .get();

      for (final doc in matchUserDataQuery.docs) {
        final map = doc.data();

        try {
          final matchUserData = MatchUserData.fromJson(map);

          if (map['private'] == true || matchUserData.private == true) {
            continue;
          }

          entries.add(
            FriendMatchEntry(
              friend: friend,
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
    final coll = usersCollection.doc(ownerUserId).collection('matchUserData')
        as CollectionReference;
    final q = await coll.where('matchId', isEqualTo: matchId).limit(1).get();
    if (q.docs.isEmpty) {
      throw StateError(
          'matchUserData not found for owner=$ownerUserId matchId=$matchId');
    }
    final doc = q.docs.first;
    return coll.doc(doc.id);
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
    await commentRef.delete();
  }

  @override
  Future<List<Commentaire>> fetchComments({
    required String ownerUserId,
    required String matchId,
    int? limit,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    Query q =
        parentRef.collection('comments').orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);

    final snap = await q.get();
    return snap.docs
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

    // create a new reaction doc with auto-id
    await reactionsRef.add(data);
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

    // Query for docs matching both userId and emoji
    final q = reactionsCol
        .where('userId', isEqualTo: authorId)
        .where('emoji', isEqualTo: emoji);

    final snap = await q.get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<List<Reaction>> fetchReactions({
    required String ownerUserId,
    required String matchId,
    int? limit,
  }) async {
    final parentRef = await _findMatchUserDataDocRef(
      ownerUserId: ownerUserId,
      matchId: matchId,
    );

    Query q = parentRef
        .collection('reactions')
        .orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);

    final snap = await q.get();
    return snap.docs
        .map((d) => Reaction.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }
}
