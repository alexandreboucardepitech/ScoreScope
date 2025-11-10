import '../../models/joueur.dart';

abstract class IJoueurRepository {
  Future<List<Joueur>> fetchAllJoueurs();
  Future<Joueur?> fetchJoueurById(String id);
  Future<void> addJoueur(Joueur e);
  Future<void> updateJoueur(Joueur e);
  Future<void> deleteJoueur(Joueur e);
  Future<List<Joueur>> searchJoueurs(String query, {String? equipeId, int limit = 8});
}
