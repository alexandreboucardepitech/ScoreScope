
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String usersCol = 'users';

  DocumentReference<Map<String, dynamic>> userDocRef(String uid) {
    return _db.collection(usersCol).doc(uid);
  }

  Future<void> createUserIfNotExists({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<Map<String, String>>? equipePrefereesJson,
  }) async {
    final ref = userDocRef(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'equipePrefereesId': equipePrefereesJson ?? [],
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

  Future<AppUser?> getUser(String uid) async {
    final snap = await userDocRef(uid).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return AppUser.fromJson(json: data, userId: uid);
  }

  Stream<AppUser?> streamUser(String uid) {
    return userDocRef(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return AppUser.fromJson(json: data, userId: uid);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> update) async {
    await userDocRef(uid).set(update, SetOptions(merge: true));
  }

  Future<void> setUser(String uid, AppUser user) async {
    await userDocRef(uid).set(user.toJson());
  }

  Future<void> deleteUser(String uid) async {
    await userDocRef(uid).delete();
  }
}
