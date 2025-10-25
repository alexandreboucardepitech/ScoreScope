import 'package:scorescope/models/equipe.dart';

import '../../../models/joueur.dart';

abstract class IJoueurRepository {
  Future<List<Joueur>> fetchAllJoueurs();
  Future<Joueur?> fetchJoueurById(String id);
  Future<void> addJoueur(Joueur e);
  Future<void> updateJoueur(Joueur e);
  Future<void> deleteJoueur(Joueur e);
  Future<List<Joueur>> searchJoueurs(String query, {Equipe? equipe, int limit = 8});
}
