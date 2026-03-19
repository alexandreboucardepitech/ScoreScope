import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/match_joueur.dart';

import '../../models/match.dart';

abstract class IMatchRepository {
  Future<List<MatchModel>> fetchAllMatches();
  Future<List<MatchModelId>> fetchAllMatchesId({bool loadVotesAndNotes = true});
  Future<MatchModel?> fetchMatchById(String id);
  Future<MatchModelId?> fetchMatchModelIdById(String id);
  Future<List<MatchModel>> fetchMatchesListById(List<String> ids);
  Future<List<MatchModel>> fetchMatchesByDate(DateTime date);
  Future<void> addMatch(MatchModel match);
  Future<void> addMatchModelId(MatchModelId matchId);
  Future<void> addMatchModelIdList(List<MatchModelId> matchs);
  Future<void> updateMatch(MatchModel match);
  Future<void> updateMatchModelId(MatchModelId matchId);
  Future<void> updateField({
    required String matchId,
    MatchStatus? status,
    int? liveMinute,
    int? extraTime,
    int? saison,
    String? equipeDomicileId,
    String? equipeExterieurId,
    String? competitionId,
    DateTime? date,
    String? refereeName,
    String? stadiumName,
    int? scoreEquipeDomicile,
    int? scoreEquipeExterieur,
    List<ButId>? butsEquipeDomicileId,
    List<ButId>? butsEquipeExterieurId,
    List<MatchJoueurId>? joueursEquipeDomicileId,
    List<MatchJoueurId>? joueursEquipeExterieurId,
    Map<String, String>? mvpVotes,
    Map<String, int>? notes,
  });
  Future<void> deleteMatch(MatchModel match);
  Future<void> noterMatch(
    String matchId,
    String userId,
    DateTime matchDate,
    int? note,
  );
  Future<void> enleverNote(String matchId, String userId);
  Future<void> voterPourMVP(
    String matchId,
    String userId,
    DateTime matchDate,
    String? joueurId,
  );
  Future<void> enleverVote(String matchId, String userId);
  Future<List<MatchModel>> fetchTeamAllMatches(String teamId);
}
