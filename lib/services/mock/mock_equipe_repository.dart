import 'dart:async';
import '../../models/equipe.dart';
import '../repositories/i_equipe_repository.dart';
import '../../utils/string_helper.dart';

class MockEquipeRepository implements IEquipeRepository {
  static final MockEquipeRepository _instance =
      MockEquipeRepository._internal();

  late final Future<void> _seedingFuture;

  MockEquipeRepository._internal() {
    _seedingFuture = _seed();
  }

  factory MockEquipeRepository() => _instance;

  Future<void> get ready => _seedingFuture;

  final List<Equipe> _equipes = [];

  Future<void> _seed() async {
    _equipes.addAll([
      Equipe(
          nom: 'Paris Saint-Germain',
          code: 'PSG',
          id: "1",
          logoPath: "assets/equipes/fcnantes.png"),
      Equipe(
          nom: 'FC Nantes',
          code: 'FCN',
          id: "2",
          logoPath: "assets/equipes/fcnantes.png"),
      Equipe(
          nom: 'FC Barcelona',
          code: 'BAR',
          id: "3",
          logoPath: "assets/equipes/fcnantes.png"),
      Equipe(
          nom: 'Real Madrid',
          code: 'RMA',
          id: "4",
          logoPath: "assets/equipes/fcnantes.png"),
    ]);
  }

  @override
  Future<List<Equipe>> fetchAllEquipes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Equipe>.from(_equipes);
  }

  @override
  Future<Equipe?> fetchEquipeById(String id) async {
    await Future.delayed(Duration(milliseconds: 200));

    try {
      final equipe = _equipes.firstWhere((e) => e.id == id);
      return equipe;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> addEquipe(Equipe e) async {
    _equipes.add(e);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updateEquipe(Equipe e) async {
    final idx = _equipes.indexWhere((x) => x == e);
    if (idx >= 0) _equipes[idx] = e;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> deleteEquipe(Equipe e) async {
    _equipes.remove(e);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<List<Equipe>> searchEquipes(String query, {int limit = 8}) async {
    final q = normalize(query);
    if (q.isEmpty) return [];
    final starts = _equipes.where((e) {
      final normNom = normalize(e.nom);
      final normCode = normalize(e.code ?? '');
      return normNom.startsWith(q) || normCode.startsWith(q);
    }).toList();

    final contains = _equipes.where((e) {
      final normNom = normalize(e.nom);
      final normCode = normalize(e.code ?? '');
      return !(normNom.startsWith(q) || normCode.startsWith(q)) &&
          (normNom.contains(q) || normCode.contains(q));
    }).toList();
    final result = <Equipe>[];
    result.addAll(starts);
    result.addAll(contains);
    return result.take(limit).toList();
  }
}
