import '../../models/match.dart';

abstract class IMatchRepository {
  Future<List<MatchModel>> fetchAllMatches();
  Future<MatchModel?> fetchMatchById(String id);
  Future<List<MatchModel>> fetchMatchesListById(List<String> ids);
  Future<void> addMatch(MatchModel match);
  Future<void> updateMatch(MatchModel match);
  Future<void> deleteMatch(MatchModel match);
  Future<void> noterMatch(String matchId, String userId, int? note);
  Future<void> voterPourMVP(String matchId, String userId, String? joueurId);
  Future<void> enleverVote(String matchId, String userId);
}
