import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/i_joueur_repository.dart';
import '../../../models/joueur.dart';

class WebJoueurRepository implements IJoueurRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('joueurs');

  @override
  Future<List<Joueur>> fetchAllJoueurs() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Joueur.fromJson(json: doc.data(), joueurId: doc.id))
        .toList();
  }

  @override
  Future<Joueur?> fetchJoueurById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Joueur.fromJson(json: doc.data()!, joueurId: doc.id);
  }

  @override
  Future<void> addJoueur(Joueur joueur) async {
    final docRef = _collection.doc(joueur.id);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(joueur.toJson());
      print(
          "Joueur ajouté : ${joueur.fullName} (${joueur.id}) -> équipe ${joueur.equipeId} | equipe nationale : ${joueur.equipeNationaleId}");
    } else {
      print("Joueur déjà existant : ${joueur.fullName} (${joueur.id})");
      final data = doc.data();
      if (data != null && data['equipeId'] != joueur.equipeId) {
        print("Le joueur ${joueur.fullName} a changé d'équipe ! : ${joueur.equipeId}");
        _collection.doc(joueur.id).update({'equipeId': joueur.equipeId});
      }
      if (data != null &&
          joueur.equipeNationaleId != null &&
          joueur.equipeNationaleId != data["equipeNationaleId"]) {
        print("Le joueur ${joueur.fullName} a une nouvelle équipe nationale ! : ${joueur.equipeNationaleId}");
        _collection.doc(joueur.id).update({
          'equipeNationaleId': joueur.equipeNationaleId,
        });
      }
    }
  }

  @override
  Future<void> addJoueursList(List<Joueur> joueurs) async {
    for (Joueur joueur in joueurs) {
      await addJoueur(joueur);
    }
  }

  @override
  Future<void> updateJoueur(Joueur joueur) async {
    await _collection.doc(joueur.id).update(joueur.toJson());
  }

  @override
  Future<void> deleteJoueur(Joueur joueur) async {
    await _collection.doc(joueur.id).delete();
  }

  @override
  Future<List<Joueur>> searchJoueurs(String query,
      {String? equipeId, int limit = 8}) async {
    final snapshot = await _collection.get();
    final allJoueurs = snapshot.docs
        .map((doc) => Joueur.fromJson(json: doc.data(), joueurId: doc.id))
        .toList();
    final q = query.toLowerCase();

    var filtered = allJoueurs.where((j) =>
        j.nom.toLowerCase().contains(q) || j.prenom.toLowerCase().contains(q));

    if (equipeId != null) {
      filtered = filtered.where((j) => j.equipeId == equipeId);
    }

    return filtered.take(limit).toList();
  }
}
