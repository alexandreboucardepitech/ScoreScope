import 'package:flutter/material.dart';

import '../../models/equipe.dart';

abstract class IEquipeRepository {
  Future<List<Equipe>> fetchAllEquipes();
  Future<Equipe?> fetchEquipeById(String id);
  Future<void> addEquipe(
    Equipe equipe, {
    bool popUpNomCourt = false,
    BuildContext? context,
  });
  Future<void> updateEquipe(Equipe e);
  Future<void> deleteEquipe(Equipe e);
  Future<List<Equipe>> searchEquipes(String query, {int limit = 8});
  Future<void> addEquipesList(
    List<Equipe> equipes, {
    bool popUpNomCourt = false,
    BuildContext? context,
  });
}
