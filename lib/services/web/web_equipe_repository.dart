import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/i_equipe_repository.dart';
import '../../../models/equipe.dart';

class WebEquipeRepository implements IEquipeRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('equipes');

  @override
  Future<List<Equipe>> fetchAllEquipes() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Equipe.fromJson(json: doc.data(), equipeId: doc.id)).toList();
  }

  @override
  Future<Equipe?> fetchEquipeById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Equipe.fromJson(json: doc.data()!, equipeId: doc.id);
  }

  @override
  Future<void> addEquipe(Equipe e) async {
    await _collection.doc(e.id).set(e.toJson());
  }

  @override
  Future<void> updateEquipe(Equipe e) async {
    await _collection.doc(e.id).update(e.toJson());
  }

  @override
  Future<void> deleteEquipe(Equipe e) async {
    await _collection.doc(e.id).delete();
  }

  @override
  Future<List<Equipe>> searchEquipes(String query, {int limit = 8}) async {
    final snapshot = await _collection.get();
    final allEquipes = snapshot.docs.map((doc) => Equipe.fromJson(json: doc.data(), equipeId: doc.id)).toList();
    final q = query.toLowerCase();
    final starts = allEquipes.where((e) => e.nom.toLowerCase().startsWith(q) || (e.code?.toLowerCase().startsWith(q) ?? false)).toList();
    final contains = allEquipes.where((e) =>
        !(e.nom.toLowerCase().startsWith(q) || (e.code?.toLowerCase().startsWith(q) ?? false)) &&
        (e.nom.toLowerCase().contains(q) || (e.code?.toLowerCase().contains(q) ?? false))
    ).toList();

    final result = [...starts, ...contains];
    return result.take(limit).toList();
  }
}
