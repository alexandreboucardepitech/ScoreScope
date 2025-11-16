import '../../models/match.dart';

abstract class IMatchRepository {
  Future<List<Match>> fetchAllMatches();
  Future<Match?> fetchMatchById(String id);
  Future<List<Match>> fetchMatchesListById(List<String> ids);
  Future<void> addMatch(Match match);
  Future<void> updateMatch(Match match);
  Future<void> deleteMatch(Match match);
  Future<void> noterMatch(String matchId, String userId, int? note);
  Future<void> voterPourMVP(String matchId, String userId, String? joueurId);
  Future<void> enleverVote(String matchId, String userId);
  Future<void> matchFavori(String matchId, String userId, bool favori);
}
