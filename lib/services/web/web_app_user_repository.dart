import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/models/enum/theme_options.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/options.dart';
import 'package:scorescope/services/repository_provider.dart';

import '../../models/app_user.dart';
import '../repositories/i_app_user_repository.dart';

class WebAppUserRepository implements IAppUserRepository {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _matchsCollection =
      FirebaseFirestore.instance.collection('matchs');

  @override
  AppUser?
      currentUser; // à utiliser que quand on ne peut vraiment pas faire d'async

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
  Future<List<String>> getUserMatchsRegardesId({
    required String userId,
    bool onlyPublic = false,
    DateTimeRange? dateRange,
  }) async {
    Query<Map<String, dynamic>> query =
        _usersCollection.doc(userId).collection('matchUserData');

    if (onlyPublic) {
      query = query.where('private', isEqualTo: false);
    }
    if (dateRange != null) {
      query = query
          .where(
            'matchDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
          )
          .where(
            'matchDate',
            isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
          );
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    return snapshot.docs.map((doc) => doc.data()['matchId'] as String).toList();
  }

  @override
  Future<int> getUserNbMatchsRegardes(String userId, bool onlyPublic) async {
    final matchUserDataSnapshot = onlyPublic
        ? await _usersCollection
            .doc(userId)
            .collection('matchUserData')
            .where('private', isEqualTo: false)
            .get()
        : await _usersCollection.doc(userId).collection('matchUserData').get();

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
    final matchUserDataSnapshot = onlyPublic
        ? await _usersCollection
            .doc(userId)
            .collection('matchUserData')
            .where('private', isEqualTo: false)
            .get()
        : await _usersCollection.doc(userId).collection('matchUserData').get();

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
        await getUserMatchsRegardesId(userId: userId, onlyPublic: onlyPublic);

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
  Future<int> getUserNbMatchsRegardesParCompetition(
      String userId, String compId, bool onlyPublic) async {
    int nbMatchsRegardes = 0;
    List<String> matchsRegardesId =
        await getUserMatchsRegardesId(userId: userId, onlyPublic: onlyPublic);

    if (matchsRegardesId.isEmpty) return 0;

    final matchsCollection = FirebaseFirestore.instance.collection('matchs');

    for (final matchId in matchsRegardesId) {
      final doc = await matchsCollection.doc(matchId).get();
      if (!doc.exists) continue;

      final data = doc.data();
      if (data == null) continue;

      if (data['competitionId'] == compId) {
        nbMatchsRegardes++;
      }
    }

    return nbMatchsRegardes;
  }

  @override
  Future<List<String>> getUserMatchsFavorisId(
      String userId, bool onlyPublic) async {
    final matchUserDataSnapshot = onlyPublic
        ? await _usersCollection
            .doc(userId)
            .collection('matchUserData')
            .where('private', isEqualTo: false)
            .get()
        : await _usersCollection.doc(userId).collection('matchUserData').get();

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

    currentUser = AppUser.fromJson(json: data, userId: firebaseUser.uid);
    return currentUser;
  }

  @override
  Future<bool> isMatchFavori(String userId, String matchId) async {
    List<String> matchsFavoris = await getUserMatchsFavorisId(userId, false);
    return matchsFavoris.contains(matchId);
  }

  @override
  Future<void> matchFavori(
      String matchId, String userId, DateTime matchDate, bool favori) async {
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
        'watchedAt': DateTime.now().toUtc(),
        'matchDate': matchDate,
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
  Future<void> setVisionnageMatch(String matchId, String userId,
      DateTime matchDate, VisionnageMatch visionnageMatch) async {
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
        'watchedAt': DateTime.now().toUtc(),
        'matchDate': matchDate,
      });
    }
  }

  @override
  Future<bool> getMatchPrivacy(String userId, String matchId) async {
    final userMatchDocRef =
        _usersCollection.doc(userId).collection('matchUserData').doc(matchId);

    final directDoc = await userMatchDocRef.get();
    if (directDoc.exists) {
      final data = directDoc.data();
      if (data != null && data.containsKey('private')) {
        final pv = data['private'];
        if (pv is bool) return pv;
        return false;
      }
      return false;
    }

    final snapshot = await _usersCollection
        .doc(userId)
        .collection('matchUserData')
        .where('matchId', isEqualTo: matchId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return false;
    }

    final data = snapshot.docs.first.data();
    final pv = data['private'];
    if (pv is bool) return pv;
    return false;
  }

  @override
  Future<void> setMatchPrivacy(
      String matchId, String userId, DateTime matchDate, bool privacy) async {
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
        'watchedAt': DateTime.now().toUtc(),
        'matchDate': matchDate,
      });
    }
  }

  @override
  Future<List<AppUser>> searchUsersByPrefix(String prefix,
      {int limit = 50}) async {
    final allUsers = await fetchAllUsers();

    final queryLower = prefix.toLowerCase();

    final filtered = allUsers.where((u) {
      final name = u.displayName.toLowerCase();
      return name.contains(queryLower);
    }).toList();

    return filtered.take(limit).toList();
  }

  @override
  Future<List<MatchUserData>> fetchUserAllMatchUserData({
    required String userId,
    bool onlyPublic = false,
    DateTimeRange? dateRange,
  }) async {
    Query<Map<String, dynamic>> query =
        _usersCollection.doc(userId).collection('matchUserData');

    if (onlyPublic) {
      query = query.where('private', isEqualTo: false);
    }

    if (dateRange != null) {
      query = query
          .where(
            'matchDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
          )
          .where(
            'matchDate',
            isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
          );
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    return snapshot.docs
        .map((doc) => MatchUserData.fromJson(doc.data()))
        .toList();
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
    final firestore = FirebaseFirestore.instance;

    try {
      final notesRef =
          _matchsCollection.doc(matchId).collection('notes').doc(userId);

      final mvpVotesRef =
          _matchsCollection.doc(matchId).collection('mvpVotes').doc(userId);

      final notesSnap = await notesRef.get();
      if (notesSnap.exists) {
        await notesRef.delete();
      }

      final mvpSnap = await mvpVotesRef.get();
      if (mvpSnap.exists) {
        await mvpVotesRef.delete();
      }

      final userMatchDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('matchUserData')
          .doc(matchId);

      final userMatchSnap = await userMatchDocRef.get();
      if (userMatchSnap.exists) {
        final commentsSnap = await userMatchDocRef.collection('comments').get();
        for (final doc in commentsSnap.docs) {
          await doc.reference.delete();
        }

        final reactionsSnap =
            await userMatchDocRef.collection('reactions').get();
        for (final doc in reactionsSnap.docs) {
          await doc.reference.delete();
        }

        await userMatchDocRef.delete();
      }

      final postNotificationsQuery = firestore
          .collection('users')
          .doc(userId)
          .collection('postNotifications')
          .where('matchId', isEqualTo: matchId);

      final notificationsSnap = await postNotificationsQuery.get();
      for (final doc in notificationsSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e, stack) {
      debugPrint(
        '❌ removeMatchUserData failed for user=$userId match=$matchId\n$e',
      );
      debugPrint(stack.toString());
    }
  }

  @override
  Future<void> editProfile({
    required String userId,
    File? newProfilePicture,
    String? newUsername,
    String? newBio,
    List<String>? newEquipesPrefereesId,
    List<String>? newCompetitionsPrefereesId,
    bool photoRemoved = false,
  }) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    final docSnapshot = await userDocRef.get();

    if (docSnapshot.exists) {
      String? downloadUrl;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      if (newProfilePicture != null) {
        await ref.putFile(newProfilePicture);
        downloadUrl = await ref.getDownloadURL();
      } else if (photoRemoved) {
        await ref.delete();
      }

      await userDocRef.update({
        if (newUsername != null) 'displayName': newUsername,
        if (newBio != null) 'bio': newBio,
        if (downloadUrl != null || photoRemoved == true)
          'photoUrl': downloadUrl,
        if (newEquipesPrefereesId != null)
          'equipesPrefereesId': newEquipesPrefereesId,
        if (newCompetitionsPrefereesId != null)
          'competitionsPrefereesId': newCompetitionsPrefereesId,
      });
    } else {
      throw Exception("Ce profil n'existe pas");
    }
  }

  @override
  Future<void> updateEmail({
    required String userId,
    required String newEmail,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid != userId) {
      throw Exception("Utilisateur invalide.");
    }

    await user.verifyBeforeUpdateEmail(newEmail);

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await userDocRef.update({
      'email': newEmail,
    });
  }

  @override
  Future<void> updatePassword({
    required String userId,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid != userId) {
      throw Exception("Utilisateur invalide.");
    }

    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount({
    required String uid,
    required String? email,
    required String password,
    required List<String> providers,
  }) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw Exception("Utilisateur non connecté");
    }

    /// 1️⃣ Reauth obligatoire
    if (email == null) {
      throw Exception("Email introuvable.");
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);

    /// 2️⃣ Vérifier si déjà supprimé
    final userRef = firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw Exception("Document utilisateur introuvable.");
    }

    if (userDoc.data()?['deleted'] == true) {
      throw Exception("Compte déjà supprimé.");
    }

    /// 3️⃣ Supprimer amitiés
    await RepositoryProvider.amitieRepository.removeAllFriendshipsForUser(uid);

    /// 4️⃣ Décrémenter popularité des compétitions
    final competitions = List<String>.from(
      userDoc.data()?['competitionsPrefereesId'] ?? [],
    );

    for (final compId in competitions) {
      await firestore.collection('competitions').doc(compId).update({
        'popularite': FieldValue.increment(-1),
      });
    }

    /// 5️⃣ Supprimer matchUserData + sous-collections reactions / comments
    final matchUserDataSnapshot =
        await userRef.collection('matchUserData').get();

    for (final matchDoc in matchUserDataSnapshot.docs) {
      // 🔥 Supprimer reactions
      final reactionsSnapshot =
          await matchDoc.reference.collection('reactions').get();
      await _deleteInBatches(firestore, reactionsSnapshot.docs);

      // 🔥 Supprimer comments
      final commentsSnapshot =
          await matchDoc.reference.collection('comments').get();
      await _deleteInBatches(firestore, commentsSnapshot.docs);
    }

    // 🔥 Supprimer les documents matchUserData eux-mêmes
    await _deleteInBatches(firestore, matchUserDataSnapshot.docs);

    /// 6️⃣ Supprimer postNotifications
    final postNotificationsSnapshot =
        await userRef.collection('postNotifications').get();
    await _deleteInBatches(firestore, postNotificationsSnapshot.docs);

    /// 7️⃣ Supprimer votes MVP et notes dans chaque match
    final matchesSnapshot = await firestore.collection('matchs').get();
    for (final matchDoc in matchesSnapshot.docs) {
      // MVP votes
      final mvpVotesSnapshot = await matchDoc.reference
          .collection('mvpVotes')
          .where('userId', isEqualTo: uid)
          .get();
      for (final voteDoc in mvpVotesSnapshot.docs) {
        await voteDoc.reference.delete();
      }

      // Notes
      final notesSnapshot = await matchDoc.reference
          .collection('notes')
          .where('userId', isEqualTo: uid)
          .get();
      for (final noteDoc in notesSnapshot.docs) {
        await noteDoc.reference.delete();
      }
    }

    /// 8️⃣ Soft delete user
    await userRef.update({
      'deleted': true,
      'displayName': 'Utilisateur supprimé',
      'photoUrl': null,
      'email': null,
      'competitionsPrefereesId': [],
      'bio': null,
      'equipesPrefereesId': [],
      'private': null,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    /// 🔟 Supprimer compte Auth
    await user.delete();
  }

  Future<void> _deleteInBatches(
    FirebaseFirestore firestore,
    List<QueryDocumentSnapshot> docs,
  ) async {
    const chunkSize = 450; // sécurité sous limite 500

    for (var i = 0; i < docs.length; i += chunkSize) {
      final batch = firestore.batch();
      final chunk = docs.skip(i).take(chunkSize);

      for (final doc in chunk) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  @override
  Future<void> updateOptions({
    required String userId,
    bool? allNotifications,
    bool? newFollowers,
    bool? likes,
    bool? comments,
    bool? replies,
    bool? favoriteTeamMatch,
    bool? results,
    bool? emailNotifications,
    LanguageOptions? language,
    ThemeOptions? theme,
    VisionnageMatch? defaultVisionnageMatch,
  }) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    final docSnapshot = await userDocRef.get();

    if (docSnapshot.exists) {
      final currentData = docSnapshot.data()!;
      final currentOptions = currentData['options'] != null
          ? Options.fromJson(currentData['options'] as Map<String, dynamic>)
          : Options();

      final updatedOptions = Options(
        allNotifications: allNotifications ?? currentOptions.allNotifications,
        newFollowers: newFollowers ?? currentOptions.newFollowers,
        likes: likes ?? currentOptions.likes,
        comments: comments ?? currentOptions.comments,
        replies: replies ?? currentOptions.replies,
        favoriteTeamMatch:
            favoriteTeamMatch ?? currentOptions.favoriteTeamMatch,
        results: results ?? currentOptions.results,
        emailNotifications:
            emailNotifications ?? currentOptions.emailNotifications,
        language: language ?? currentOptions.language,
        theme: theme ?? currentOptions.theme,
        defaultVisionnageMatch:
            defaultVisionnageMatch ?? currentOptions.defaultVisionnageMatch,
      );

      await userDocRef.update({
        'options': updatedOptions.toJson(),
      });
    } else {
      throw Exception("Ce profil n'existe pas");
    }
  }

  @override
  Future<void> updatePrivateAccount({
    required String userId,
    required bool isPrivate,
  }) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    await userDocRef.update({
      'private': isPrivate,
    });
  }
}
