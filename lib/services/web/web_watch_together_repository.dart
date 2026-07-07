import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/watch_together.dart';
import 'package:scorescope/models/watch_together/watch_together_season_summary.dart';
import 'package:scorescope/services/repositories/i_watch_together_repository.dart';
import 'package:scorescope/services/repository_provider.dart';

class WebWatchTogetherRepository implements IWatchTogetherRepository {
  final CollectionReference<Map<String, dynamic>> _watchTogetherCollection =
      FirebaseFirestore.instance.collection('watchTogether');

  @override
  Future<List<WatchTogether>> getFriendsWatchedWith(
    String ownerId,
    String matchId,
  ) async {
    try {
      final querySnapshot = await _watchTogetherCollection
          .where('ownerId', isEqualTo: ownerId)
          .where('matchId', isEqualTo: matchId)
          .get();

      return querySnapshot.docs
          .map((doc) => WatchTogether.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching watchTogether documents: $e');
    }
  }

  @override
  Future<void> createWatchTogether({
    required String matchId,
    required String ownerId,
    required String friendId,
  }) async {
    try {
      await _watchTogetherCollection.add({
        'matchId': matchId,
        'ownerId': ownerId,
        'friendId': friendId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error creating watchTogether document: $e');
    }
  }

  @override
  Future<void> removeWatchTogether({
    required String matchId,
    required String ownerId,
    required String friendId,
  }) async {
    try {
      final querySnapshot = await _watchTogetherCollection
          .where('matchId', isEqualTo: matchId)
          .where('ownerId', isEqualTo: ownerId)
          .where('friendId', isEqualTo: friendId)
          .get();
      final querySnapshotReversed = await _watchTogetherCollection
          .where('matchId', isEqualTo: matchId)
          .where('ownerId', isEqualTo: friendId)
          .where('friendId', isEqualTo: ownerId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      for (final doc in querySnapshotReversed.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error removing watchTogether document: $e');
    }
  }

  @override
  Future<void> acceptWatchTogether(
      {required String matchId,
      required String ownerId,
      required String friendId}) async {
    try {
      final querySnapshot = await _watchTogetherCollection
          .where('matchId', isEqualTo: matchId)
          .where('ownerId', isEqualTo: ownerId)
          .where('friendId', isEqualTo: friendId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'status': 'accepted'});
      }
    } catch (e) {
      throw Exception('Error accepting watchTogether document: $e');
    }

    // également créer un autre document dans l'autre sens
    try {
      await _watchTogetherCollection.add({
        'matchId': matchId,
        'ownerId': friendId,
        'friendId': ownerId,
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error creating watchTogether document: $e');
    }
  }

  @override
  Future<void> removeAllWatchTogetherForUser({required String userId}) async {
    try {
      //ownerId OR friendId

      final querySnapshot = await _watchTogetherCollection
          .where('ownerId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      final querySnapshotFriend = await _watchTogetherCollection
          .where('friendId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshotFriend.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error removing watchTogether documents for user: $e');
    }
  }

  @override
  Future<WatchTogetherSeasonSummary> fetchUserWatchTogetherSummary({
    required String userId,
    required List<String> matchIds,
  }) async {
    if (matchIds.isEmpty) return WatchTogetherSeasonSummary.empty;

    try {
      final querySnapshot = await _watchTogetherCollection
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final docs = querySnapshot.docs
          .map((doc) => WatchTogether.fromJson(doc.data()))
          .where((wt) => matchIds.contains(wt.matchId))
          .toList();

      if (docs.isEmpty) return WatchTogetherSeasonSummary.empty;

      final distinctMatchIds = <String>{};
      final matchesPerFriend = <String, int>{};

      for (final wt in docs) {
        distinctMatchIds.add(wt.matchId);
        matchesPerFriend[wt.friendId] =
            (matchesPerFriend[wt.friendId] ?? 0) + 1;
      }

      final sortedFriendIds = matchesPerFriend.keys.toList()
        ..sort((a, b) => matchesPerFriend[b]!.compareTo(matchesPerFriend[a]!));

      final topFriends = (await Future.wait(
        sortedFriendIds.take(3).map((friendId) async {
          final friend =
              await RepositoryProvider.userRepository.fetchUserById(friendId);
          if (friend == null) return null;
          return WatchTogetherFriendStat(
            friendId: friendId,
            friendName: friend.displayName,
            friendPhoto: friend.photoUrl,
            matchesTogether: matchesPerFriend[friendId]!,
          );
        }),
      ))
          .whereType<WatchTogetherFriendStat>()
          .toList();

      return WatchTogetherSeasonSummary(
        totalMatchesWithFriends: distinctMatchIds.length,
        distinctFriendsCount: matchesPerFriend.keys.length,
        topFriends: topFriends,
      );
    } catch (e) {
      throw Exception('Error fetching watch together summary: $e');
    }
  }
}
