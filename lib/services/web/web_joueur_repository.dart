import 'dart:async';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/services/repositories/equipe/i_equipe_repository.dart';
import 'package:scorescope/services/web/web_equipe_repository.dart';

import '../../models/joueur.dart';
import '../repositories/joueur/i_joueur_repository.dart';
import '../../utils/string_helper.dart';

class WebJoueurRepository implements IJoueurRepository {
  static final WebJoueurRepository _instance =
      WebJoueurRepository._internal();

  late final Future<void> _seedingFuture;

  WebJoueurRepository._internal() {
    _seedingFuture = _seed();
  }

  factory WebJoueurRepository() => _instance;

  Future<void> get ready => _seedingFuture;

  final List<Joueur> _joueurs = [];

  final IEquipeRepository equipeRepository = WebEquipeRepository();

  Future<void> _seed() async {
    await WebEquipeRepository().ready;

    final om = await equipeRepository.fetchEquipeById("1");
    final fcnantes = await equipeRepository.fetchEquipeById("2");
    final barca = await equipeRepository.fetchEquipeById("3");
    final realmadrid = await equipeRepository.fetchEquipeById("4");

    _joueurs.addAll([
      Joueur(prenom: "Matthis", nom: "Abline", id: "1", equipe: fcnantes, picture: "assets/joueurs/abline.png"),
      Joueur(prenom: "Yassine", nom: "Benhattab", id: "2", equipe: fcnantes, picture: "assets/joueurs/default.png"),
      Joueur(prenom: "Louis", nom: "Leroux", id: "3", equipe: fcnantes, picture: "assets/joueurs/default.png"),
      Joueur(prenom: "Lamine", nom: "Yamal", id: "4", equipe: barca, picture: "assets/joueurs/default.png"),
      Joueur(prenom: "", nom: "Pedri", id: "5", equipe: barca, picture: "assets/joueurs/default.png"),
      Joueur(prenom: "Kylian", nom: "Mbappé", id: "6", equipe: realmadrid, picture: "assets/joueurs/default.png"),
      Joueur(prenom: "Franco", nom: "Mastantuono", id: "7", equipe: realmadrid, picture: "assets/joueurs/default.png"),
      Joueur(prenom: "Pierre-Emerick", nom: "Aubameyang", id: "8", equipe: om, picture: "assets/joueurs/default.png"),
    ]);
  }

  @override
  Future<List<Joueur>> fetchAllJoueurs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Joueur>.from(_joueurs);
  }

  @override
  Future<Joueur?> fetchJoueurById(String id) async {
    await Future.delayed(Duration(milliseconds: 200));

    try {
      final joueur = _joueurs.firstWhere((e) => e.id == id);
      return joueur;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> addJoueur(Joueur e) async {
    _joueurs.add(e);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updateJoueur(Joueur e) async {
    final idx = _joueurs.indexWhere((x) => x == e);
    if (idx >= 0) _joueurs[idx] = e;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> deleteJoueur(Joueur e) async {
    _joueurs.remove(e);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<List<Joueur>> searchJoueurs(String query,
      {Equipe? equipe, int limit = 8}) async {
    final q = normalize(query);
    if (q.isEmpty) return [];
    final starts = _joueurs.where((j) {
      final normPrenom = normalize(j.prenom);
      final normNom = normalize(j.nom);
      return (normPrenom.startsWith(q) || normNom.startsWith(q)) &&
          (equipe == null || j.equipe == equipe);
    }).toList();

    final contains = _joueurs.where((j) {
      final normPrenom = normalize(j.prenom);
      final normNom = normalize(j.nom);
      return !(normPrenom.startsWith(q) || normNom.startsWith(q)) &&
          (normPrenom.contains(q) || normNom.contains(q)) &&
          (equipe == null || j.equipe == equipe);
    }).toList();
    final result = <Joueur>[];
    result.addAll(starts);
    result.addAll(contains);
    return result.take(limit).toList();
  }
}
