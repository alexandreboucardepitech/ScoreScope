import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../repositories/i_app_user_repository.dart';

/// Simple HTTP implementation of [IAppUserRepository].
/// Adjust endpoints and error handling to match your backend.
class WebAppUserRepository implements IAppUserRepository {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

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
  Future<List<String>> getUserMatchsRegardesId(String userId) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    return matchUserDataSnapshot.docs
        .map((d) => d.data()['matchId'] as String)
        .toList();
  }

  @override
  Future<int> getUserNbMatchsRegardes(String userId) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    return matchUserDataSnapshot.docs.length;
  }

  @override
  Future<int> getUserNbButs(String userId) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    int totalButs = 0;

    final matchsCollection = FirebaseFirestore.instance.collection('matchs');

    for (var doc in matchUserDataSnapshot.docs) {
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
  Future<List<String>> getUserMatchsFavorisId(String userId) async {
    final matchUserDataSnapshot =
        await _usersCollection.doc(userId).collection('matchUserData').get();

    return matchUserDataSnapshot.docs
        .where((d) => d.data()['favourite'] == true)
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

    data['matchUserData'] =
        matchUserDataSnapshot.docs.map((d) => d.data()).toList();

    return AppUser.fromJson(json: data, userId: firebaseUser.uid);
  }
}
