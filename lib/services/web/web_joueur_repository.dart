import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/joueur/i_joueur_repository.dart';
import '../../../models/joueur.dart';

class WebJoueurRepository implements IJoueurRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('joueurs');

  @override
  Future<List<Joueur>> fetchAllJoueurs() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Joueur.fromJson(json: doc.data(), joueurId: doc.id)).toList();
  }

  @override
  Future<Joueur?> fetchJoueurById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Joueur.fromJson(json: doc.data()!, joueurId: doc.id);
  }

  @override
  Future<void> addJoueur(Joueur e) async {
    await _collection.doc(e.id).set(e.toJson());
  }

  @override
  Future<void> updateJoueur(Joueur e) async {
    await _collection.doc(e.id).update(e.toJson());
  }

  @override
  Future<void> deleteJoueur(Joueur e) async {
    await _collection.doc(e.id).delete();
  }

  @override
  Future<List<Joueur>> searchJoueurs(String query,
      {String? equipeId, int limit = 8}) async {
    final snapshot = await _collection.get();
    final allJoueurs =
        snapshot.docs.map((doc) => Joueur.fromJson(json: doc.data(), joueurId: doc.id)).toList();
    final q = query.toLowerCase();

    var filtered = allJoueurs.where((j) =>
        j.nom.toLowerCase().contains(q) || j.prenom.toLowerCase().contains(q));

    if (equipeId != null) {
      filtered = filtered.where((j) => j.equipeId == equipeId);
    }

    return filtered.take(limit).toList();
  }
}
