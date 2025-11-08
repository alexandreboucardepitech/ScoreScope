
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String usersCol = 'users';

  DocumentReference<Map<String, dynamic>> userDocRef(String uid) {
    return _db.collection(usersCol).doc(uid);
  }

  /// Crée le document utilisateur s'il n'existe pas (idempotent).
  /// Utilise serverTimestamp() pour createdAt.
  Future<void> createUserIfNotExists({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<Map<String, dynamic>>? equipePrefereesJson, // optionnel si tu préfères envoyer des Equipe.toJson()
  }) async {
    final ref = userDocRef(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        // createdAt en timestamp serveur
        'createdAt': FieldValue.serverTimestamp(),
        // équipe préférées : par défaut vide
        'equipePreferees': equipePrefereesJson ?? [],
      });
    } else {
      // Optionnel : mise à jour minimale si certaines infos sont manquantes
      final data = snap.data();
      final updateData = <String, dynamic>{};
      if (data != null) {
        if ((data['email'] == null || data['email'] == '') && email != null) {
          updateData['email'] = email;
        }
        if ((data['displayName'] == null || data['displayName'] == '') && displayName != null) {
          updateData['displayName'] = displayName;
        }
        if ((data['photoUrl'] == null || data['photoUrl'] == '') && photoUrl != null) {
          updateData['photoUrl'] = photoUrl;
        }
      }
      if (updateData.isNotEmpty) {
        await ref.set(updateData, SetOptions(merge: true));
      }
    }
  }

  /// Lecture ponctuelle et conversion en AppUser (ou null si absent)
  Future<AppUser?> getUser(String uid) async {
    final snap = await userDocRef(uid).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return AppUser.fromJson(data);
  }

  /// Stream en temps réel du document utilisateur
  Stream<AppUser?> streamUser(String uid) {
    return userDocRef(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return AppUser.fromJson(data);
    });
  }

  /// Mise à jour partielle (merge)
  Future<void> updateUser(String uid, Map<String, dynamic> update) async {
    await userDocRef(uid).set(update, SetOptions(merge: true));
  }

  /// Remplace complètement le document (attention)
  Future<void> setUser(String uid, AppUser user) async {
    await userDocRef(uid).set(user.toJson());
  }

  /// Supprime le document (ne supprime pas l'Auth user)
  Future<void> deleteUser(String uid) async {
    await userDocRef(uid).delete();
  }
}
