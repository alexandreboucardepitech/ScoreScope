import '../../../models/match.dart';

abstract class IMatchRepository {
  Future<List<Match>> fetchAllMatches();
  Future<Match?> fetchMatchById(String id);
  Future<void> addMatch(Match m);
  Future<void> updateMatch(Match m);
  Future<void> deleteMatch(Match m);
}
