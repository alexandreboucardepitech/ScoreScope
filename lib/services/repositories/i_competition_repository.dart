import 'package:scorescope/models/competition.dart';

abstract class ICompetitionRepository {
  Future<List<Competition>> fetchAllCompetitions();
  Future<Competition?> fetchCompetitionById(String id);
  Future<void> updateFavoriteCompetitions({
    required String userId,
    required List<String> competitionIds,
  });
  Future<void> addCompetition(Competition competition);
  Future<void> addCompetitionList(List<Competition> competitions);
  Future<void> updateCompetition({
    required String id,
    String? nom,
    String? country,
    String? logoUrl,
    int? popularite,
  });
}
