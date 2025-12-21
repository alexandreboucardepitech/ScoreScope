import 'package:scorescope/models/competition.dart';

abstract class ICompetitionRepository {
  Future<List<Competition>> fetchAllCompetitions();
  Future<Competition?> fetchCompetitionById(String id);
  Future<void> updateFavoriteCompetitions(
      {required String userId, required List<String> competitionIds});
}
