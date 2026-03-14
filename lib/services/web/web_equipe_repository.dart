import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/services/repositories/i_equipe_repository.dart';
import 'package:scorescope/utils/string/popup_nom_court.dart';
import '../../../models/equipe.dart';

class WebEquipeRepository implements IEquipeRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('equipes');

  @override
  Future<List<Equipe>> fetchAllEquipes() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Equipe.fromJson(json: doc.data(), equipeId: doc.id))
        .toList();
  }

  @override
  Future<Equipe?> fetchEquipeById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Equipe.fromJson(json: doc.data()!, equipeId: doc.id);
  }

  @override
  Future<void> addEquipe(
    Equipe equipe, {
    bool popUpNomCourt = false,
    BuildContext? context,
  }) async {
    final docRef = _collection.doc(equipe.id);

    final doc = await docRef.get();
    if (!doc.exists) {
      Map<String, dynamic> json = equipe.toJson();
      if (equipe.nom.length > 15 && popUpNomCourt && context != null) {
        String? nomCourt = await popupNomCourt(context, equipe.nom);
        if (nomCourt != null) json["nomCourt"] = nomCourt;
      }
      await _collection.doc(equipe.id).set(json);
      print("Équipe ajoutée : ${equipe.nom} / ${equipe.id}");
    } else {
      print("Équipe déjà existante : ${equipe.nom} / ${equipe.id}");
    }
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
    final allEquipes = snapshot.docs
        .map((doc) => Equipe.fromJson(json: doc.data(), equipeId: doc.id))
        .toList();
    final q = query.toLowerCase();
    final starts = allEquipes
        .where((e) =>
            e.nom.toLowerCase().startsWith(q) ||
            (e.code?.toLowerCase().startsWith(q) ?? false))
        .toList();
    final contains = allEquipes
        .where((e) =>
            !(e.nom.toLowerCase().startsWith(q) ||
                (e.code?.toLowerCase().startsWith(q) ?? false)) &&
            (e.nom.toLowerCase().contains(q) ||
                (e.code?.toLowerCase().contains(q) ?? false)))
        .toList();

    final result = [...starts, ...contains];
    return result.take(limit).toList();
  }

  @override
  Future<void> addEquipesList(
    List<Equipe> equipes, {
    bool popUpNomCourt = false,
    BuildContext? context,
  }) async {
    for (Equipe equipe in equipes) {
      await addEquipe(equipe, popUpNomCourt: popUpNomCourt, context: context);
    }
  }
}
