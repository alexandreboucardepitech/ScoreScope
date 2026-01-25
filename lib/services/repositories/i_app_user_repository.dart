import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match_user_data.dart';

abstract class IAppUserRepository {
  Future<List<AppUser>> fetchAllUsers();
  Future<AppUser?> fetchUserById(String id);
  Future<List<String>> getUserEquipesPrefereesId(String userId);
  Future<List<String>> getUserMatchsRegardesId(
      {required String userId,
      bool onlyPublic = false,
      DateTimeRange? dateRange});
  Future<int> getUserNbMatchsRegardes(String userId, bool onlyPublic);
  Future<int> getUserNbButs(String userId, bool onlyPublic);
  Future<int> getUserNbMatchsRegardesParEquipe(
      String userId, String equipeId, bool onlyPublic);
  Future<List<String>> getUserMatchsFavorisId(String userId, bool onlyPublic);
  Future<void> matchFavori(
      String matchId, String userId, DateTime matchDate, bool favori);
  Future<bool> isMatchFavori(String userId, String matchId);
  Future<void> setVisionnageMatch(String matchId, String userId,
      DateTime matchDate, VisionnageMatch visionnageMatch);
  Future<VisionnageMatch> getVisionnageMatch(String userId, String matchId);
  Future<void> setMatchPrivacy(
      String matchId, String userId, DateTime matchDate, bool privacy);
  Future<bool> getMatchPrivacy(String userId, String matchId);
  Future<AppUser?> getCurrentUser();
  Future<List<AppUser>> searchUsersByPrefix(String prefix, {int limit = 50});
  Future<List<MatchUserData>> fetchUserAllMatchUserData(
      {required String userId,
      bool onlyPublic = false,
      DateTimeRange? dateRange});
  Future<MatchUserData?> fetchUserMatchUserData(String userId, String matchId);
  Future<void> removeMatchUserData(String userId, String matchId);
}
