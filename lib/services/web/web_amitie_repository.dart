import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match_user_data.dart';
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
  Future<List<AppUser>> fetchFriendsForUser(String userId) async {
    final allFriendships = await fetchFriendshipsForUser(userId);

    // ne garder que les amitiés acceptées
    final acceptedFriendIds = allFriendships.map((f) {
      return f.firstUserId == userId ? f.secondUserId : f.firstUserId;
    }).toList();

    if (acceptedFriendIds.isEmpty) return [];

    // récupère les infos utilisateurs correspondantes
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final friends = <AppUser>[];

    const batchSize = 10;
    for (var i = 0; i < acceptedFriendIds.length; i += batchSize) {
      final batchIds = acceptedFriendIds.sublist(
        i,
        i + batchSize > acceptedFriendIds.length
            ? acceptedFriendIds.length
            : i + batchSize,
      );

      final usersQuery =
          await usersCollection.where('uid', whereIn: batchIds).get();

      friends.addAll(usersQuery.docs
          .map((doc) => AppUser.fromJson(json: doc.data()))
          .toList());
    }

    return friends;
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

  @override
  Future<int> getUserNbPendingFriendRequests(String userId) async {
    final querySnapshot = await _friendshipsCollection
        .where('secondUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return querySnapshot.docs.length;
  }

  @override
  Future<List<FriendMatchEntry>> fetchFriendsMatchesUserData(
    String userId, {
    bool onlyPublic = true,
    int? daysLimit,
  }) async {
    final friends = await fetchFriendsForUser(userId);
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

          if (onlyPublic && (map['private'] == true || matchUserData.private == true)) {
            continue;
          }

          final dynamic raw = map['watchedAt'];
          DateTime? watchedAt;

          if (raw is Timestamp) {
            watchedAt = raw.toDate().toUtc();
          } else if (raw is DateTime) {
            watchedAt = raw.toUtc();
          } else if (raw is String) {
            try {
              watchedAt = DateTime.parse(raw).toUtc();
            } catch (_) {
              watchedAt = null;
            }
          }

          // Filtre daysLimit
          if (cutoff != null &&
              watchedAt != null &&
              watchedAt.isBefore(cutoff)) {
            continue;
          }

          allEntries.add(
            FriendMatchEntry(
              friend: friend,
              matchData: matchUserData,
              eventDate: watchedAt,
            ),
          );
        } catch (_) {}
      }
    }

    // Tri global par watchedAt desc
    allEntries.sort((a, b) {
      final da = a.eventDate;
      final db = b.eventDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return allEntries;
  }
}
