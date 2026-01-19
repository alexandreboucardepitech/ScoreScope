import 'dart:async';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';

class MockCompetitionRepository implements ICompetitionRepository {
  static final MockCompetitionRepository _instance =
      MockCompetitionRepository._internal();

  late final Future<void> _seedingFuture;

  MockCompetitionRepository._internal() {
    _seedingFuture = _seed();
  }

  factory MockCompetitionRepository() => _instance;

  Future<void> get ready => _seedingFuture;

  final List<Competition> _competitions = [];

  Future<void> _seed() async {
    _competitions.addAll([
      Competition(
        id: '1',
        nom: 'Ligue 1',
        logoUrl: 'assets/competitions/ligue1.jpg',
        popularite: 40,
      ),
      Competition(
        id: '2',
        nom: 'La Liga',
        logoUrl: 'assets/competitions/ligue1.jpg',
        popularite: 50,
      ),
      Competition(
          id: '3',
          nom: 'Ligue des Champions',
          logoUrl: 'assets/competitions/ligue1.jpg',
          popularite: 100)
    ]);
  }

  @override
  Future<List<Competition>> fetchAllCompetitions() async {
    await ready;
    await Future.delayed(Duration(milliseconds: 200));
    return _competitions;
  }

  @override
  Future<Competition?> fetchCompetitionById(String id) async {
    await ready;
    await Future.delayed(Duration(milliseconds: 200));
    try {
      return _competitions.firstWhere((comp) => comp.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateFavoriteCompetitions(
      {required String userId, required List<String> competitionIds}) async {
    await Future.delayed(Duration(milliseconds: 200));

    final user = await MockAppUserRepository().fetchUserById(userId);

    if (user != null) {
      user.competitionsPrefereesId
        ..clear()
        ..addAll(competitionIds);
    }
  }
}
