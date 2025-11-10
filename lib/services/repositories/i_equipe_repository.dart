import '../../models/equipe.dart';

abstract class IEquipeRepository {
  Future<List<Equipe>> fetchAllEquipes();
  Future<Equipe?> fetchEquipeById(String id);
  Future<void> addEquipe(Equipe e);
  Future<void> updateEquipe(Equipe e);
  Future<void> deleteEquipe(Equipe e);
  Future<List<Equipe>> searchEquipes(String query, {int limit = 8});
}
