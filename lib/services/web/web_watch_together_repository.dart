import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/watch_together.dart';
import 'package:scorescope/services/repositories/i_watch_together_repository.dart';

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
}
