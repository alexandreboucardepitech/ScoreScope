import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/amitie.dart';
import '../repositories/i_amitie_repository.dart';

class WebAmitieRepository implements IAmitieRepository {
  final CollectionReference<Map<String, dynamic>> _friendshipsCollection =
      FirebaseFirestore.instance.collection('friendships');

  /// Trouve la doc de l'amitié entre deux utilisateurs
  Future<DocumentReference<Map<String, dynamic>>?> _findFriendshipDoc(
      String userId1, String userId2) async {
    final query = await _friendshipsCollection
        .where('firstUserId', whereIn: [userId1, userId2]).get();

    for (final doc in query.docs) {
      final data = doc.data();
      if ((data['firstUserId'] == userId1 && data['secondUserId'] == userId2) ||
          (data['firstUserId'] == userId2 && data['secondUserId'] == userId1)) {
        return doc.reference;
      }
    }
    return null;
  }

  @override
  Future<List<Amitie>> fetchFriendshipsForUser(String userId) async {
    final querySnapshot = await _friendshipsCollection
        .where('firstUserId', isEqualTo: userId)
        .get();

    final secondQuerySnapshot = await _friendshipsCollection
        .where('secondUserId', isEqualTo: userId)
        .get();

    final allDocs = [...querySnapshot.docs, ...secondQuerySnapshot.docs];

    return allDocs.map((doc) => Amitie.fromJson(json: doc.data())).toList();
  }

  @override
  Future<int> getUserNbAmis(String userId) async {
    final querySnapshot = await _friendshipsCollection
        .where('firstUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final secondQuerySnapshot = await _friendshipsCollection
        .where('secondUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final allDocs = [...querySnapshot.docs, ...secondQuerySnapshot.docs];

    return allDocs.length;
  }

  @override
  Future<List<Amitie>> fetchFriendRequestsReceived(String userId) async {
    final querySnapshot = await _friendshipsCollection
        .where('secondUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return querySnapshot.docs
        .map((doc) => Amitie.fromJson(json: doc.data()))
        .toList();
  }

  @override
  Future<List<Amitie>> fetchFriendRequestsSent(String userId) async {
    final querySnapshot = await _friendshipsCollection
        .where('firstUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return querySnapshot.docs
        .map((doc) => Amitie.fromJson(json: doc.data()))
        .toList();
  }

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    await _friendshipsCollection.add({
      'firstUserId': fromUserId,
      'secondUserId': toUserId,
      'status': 'pending',
      'createdAt': DateTime.now(),
    });
  }

  @override
  Future<void> acceptFriendRequest(String userId1, String userId2) async {
    final docRef = await _findFriendshipDoc(userId1, userId2);
    if (docRef != null) {
      await docRef.update({'status': 'accepted'});
    } else {
      await _friendshipsCollection.add({
        'firstUserId': userId1,
        'secondUserId': userId2,
        'status': 'accepted',
        'createdAt': DateTime.now(),
      });
    }
  }

  @override
  Future<void> rejectFriendRequest(String userId1, String userId2) async {
    final docRef = await _findFriendshipDoc(userId1, userId2);
    if (docRef != null) {
      await docRef.delete();
    }
  }

  @override
  Future<void> removeFriend(String userId1, String userId2) async {
    final docRef = await _findFriendshipDoc(userId1, userId2);
    if (docRef != null) {
      await docRef.delete();
    }
  }

  @override
  Future<Amitie?> friendshipByUsersId(String userId1, String userId2) async {
    try {
      final querySnapshot = await _friendshipsCollection
          .where('firstUserId', whereIn: [userId1, userId2]).where(
              'secondUserId',
              whereIn: [userId1, userId2]).get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return Amitie.fromJson(json: doc.data());
    } catch (_) {
      return null;
    }
  }
}
