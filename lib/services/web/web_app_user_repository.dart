import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match_user_data.dart';

import '../../models/app_user.dart';
import '../repositories/i_app_user_repository.dart';

/// Simple HTTP implementation of [IAppUserRepository].
/// Adjust endpoints and error handling to match your backend.
class WebAppUserRepository implements IAppUserRepository {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _matchsCollection =
      FirebaseFirestore.instance.collection('matchs');

  @override
  Future<List<AppUser>> fetchAllUsers() async {
    final snapshot = await _usersCollection.get();
    return snapshot.docs
        .map((doc) => AppUser.fromJson(json: doc.data(), userId: doc.id))
        .toList();
  }

  @override
  Future<AppUser?> fetchUserById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(json: doc.data()!, userId: doc.id);
  }

  @override
  Future<List<String>> getUserEquipesPrefereesId(String userId) async {
    AppUser? user = await fetchUserById(userId);
    if (user == null) return [];
    return user.equipesPrefereesId;
  }

  @override
  Future<List<String>> getUserMatchsRegardesId(
      String userId, bool onlyPublic) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    return matchUserDataSnapshot.docs
        .where((d) => !onlyPublic || (d.data()['private'] == false))
        .map((d) => d.data()['matchId'] as String)
        .toList();
  }

  @override
  Future<int> getUserNbMatchsRegardes(String userId, bool onlyPublic) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    int count = 0;

    for (var doc in matchUserDataSnapshot.docs) {
      final data = doc.data();
      if (!onlyPublic || (data['private'] == false)) {
        count++;
      }
    }

    return count;
  }

  @override
  Future<int> getUserNbButs(String userId, bool onlyPublic) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    int totalButs = 0;

    final matchsCollection = FirebaseFirestore.instance.collection('matchs');

    for (var doc in matchUserDataSnapshot.docs) {
      if (onlyPublic && (doc.data()['private'] == true)) {
        continue;
      }
      final matchId = doc.data()['matchId'] as String?;

      if (matchId == null) continue;

      final matchDoc = await matchsCollection.doc(matchId).get();
      if (!matchDoc.exists) continue;

      final matchData = matchDoc.data()!;
      final int scoreDomicile = matchData['scoreEquipeDomicile'] as int? ?? 0;
      final int scoreExterieur = matchData['scoreEquipeExterieur'] as int? ?? 0;

      totalButs += scoreDomicile + scoreExterieur;
    }

    return totalButs;
  }

  @override
  Future<int> getUserNbMatchsRegardesParEquipe(
      String userId, String equipeId, bool onlyPublic) async {
    int nbMatchsRegardes = 0;
    List<String> matchsRegardesId =
        await getUserMatchsRegardesId(userId, onlyPublic);

    if (matchsRegardesId.isEmpty) return 0;

    final matchsCollection = FirebaseFirestore.instance.collection('matchs');

    for (final matchId in matchsRegardesId) {
      final doc = await matchsCollection.doc(matchId).get();
      if (!doc.exists) continue;

      final data = doc.data();
      if (data == null) continue;

      final String equipeDomicileId = data['equipeDomicileId'] as String;
      final String equipeExterieurId = data['equipeExterieurId'] as String;

      if (equipeDomicileId == equipeId || equipeExterieurId == equipeId) {
        nbMatchsRegardes++;
      }
    }

    return nbMatchsRegardes;
  }

  @override
  Future<List<String>> getUserMatchsFavorisId(
      String userId, bool onlyPublic) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    return matchUserDataSnapshot.docs
        .where((d) => d.data()['favourite'] == true)
        .where((d) => !onlyPublic || (d.data()['private'] == false))
        .map((d) => d.data()['matchId'] as String)
        .toList();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;
    final doc = await _usersCollection.doc(firebaseUser.uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final matchUserDataSnapshot =
        await _usersCollection.doc(doc.id).collection('matchUserData').get();

    data['matchsUserData'] =
        matchUserDataSnapshot.docs.map((d) => d.data()).toList();

    return AppUser.fromJson(json: data, userId: firebaseUser.uid);
  }

  @override
  Future<bool> isMatchFavori(String userId, String matchId) async {
    List<String> matchsFavoris = await getUserMatchsFavorisId(userId, false);
    return matchsFavoris.contains(matchId);
  }

  @override
  Future<void> matchFavori(String matchId, String userId, bool favori) async {
    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();

    if (docSnapshot.exists) {
      await userMatchDocRef.update({
        'favourite': favori,
      });
    } else {
      await userMatchDocRef.set({
        'matchId': matchId,
        'note': null,
        'mvpVoteId': null,
        'favourite': favori,
        'private': false,
      });
    }
  }

  @override
  Future<VisionnageMatch> getVisionnageMatch(
      String userId, String matchId) async {
    final doc = await _usersCollection
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId)
        .get();
    if (!doc.exists) return VisionnageMatch.tele;
    final data = doc.data()!;
    final VisionnageMatch? visionnageValue =
        VisionnageMatchExt.fromString(data['visionnageMatch']);
    return visionnageValue ?? VisionnageMatch.tele;
  }

  @override
  Future<void> setVisionnageMatch(
      String matchId, String userId, VisionnageMatch visionnageMatch) async {
    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();

    if (docSnapshot.exists) {
      await userMatchDocRef.update({
        'visionnageMatch': visionnageMatch.label,
      });
    } else {
      await userMatchDocRef.set({
        'matchId': matchId,
        'note': null,
        'mvpVoteId': null,
        'favourite': false,
        'visionnageMatch': visionnageMatch.label,
        'private': false,
      });
    }
  }

  @override
  Future<bool> getMatchPrivacy(String userId, String matchId) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();
    for (var doc in matchUserDataSnapshot.docs) {
      final data = doc.data();
      if (data['matchId'] == matchId) {
        final bool? privacy = data['private'];
        if (privacy != null) {
          try {
            return privacy;
          } on StateError {
            return false;
          }
        }
      }
    }
    return false;
  }

  @override
  Future<void> setMatchPrivacy(
      String matchId, String userId, bool privacy) async {
    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();

    if (docSnapshot.exists) {
      await userMatchDocRef.update({
        'private': privacy,
      });
    } else {
      await userMatchDocRef.set({
        'matchId': matchId,
        'note': null,
        'mvpVoteId': null,
        'favourite': false,
        'private': privacy,
      });
    }
  }

  @override
  Future<List<AppUser>> searchUsersByPrefix(String prefix,
      {int limit = 50}) async {
    final allUsers = await fetchAllUsers();

    final queryLower = prefix.toLowerCase();

    final filtered = allUsers.where((u) {
      final name = u.displayName?.toLowerCase() ?? '';
      return name.contains(queryLower);
    }).toList();

    return filtered.take(limit).toList();
  }

  @override
  Future<List<MatchUserData>> fetchUserAllMatchUserData(
      String userId, bool onlyPublic) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    List<MatchUserData> matchUserDataList = [];

    for (var doc in matchUserDataSnapshot.docs) {
      final data = doc.data();
      final matchUserData = MatchUserData.fromJson(data);
      if (onlyPublic) {
        if (!matchUserData.private) {
          matchUserDataList.add(matchUserData);
        }
      } else {
        matchUserDataList.add(matchUserData);
      }
    }

    return matchUserDataList;
  }

  @override
  Future<MatchUserData?> fetchUserMatchUserData(String userId, String matchId) {
    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    return userMatchDocRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        return MatchUserData.fromJson(docSnapshot.data()!);
      } else {
        return null;
      }
    });
  }

  @override
  Future<void> removeMatchUserData(String userId, String matchId) async {
    await _matchsCollection
        .doc(matchId)
        .collection('notes')
        .doc(userId)
        .delete();

    await _matchsCollection
        .doc(matchId)
        .collection('mvpVotes')
        .doc(userId)
        .delete();

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    return userMatchDocRef.delete();
  }
}
