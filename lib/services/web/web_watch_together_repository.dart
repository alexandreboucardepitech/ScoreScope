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
      print('Error fetching watchTogether documents: $e');
      return [];
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
      print('Error creating watchTogether document: $e');
      rethrow;
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

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error removing watchTogether document: $e');
      rethrow;
    }
  }
}
