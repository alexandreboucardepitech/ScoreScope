import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';

abstract class IAppUserRepository {
  Future<List<AppUser>> fetchAllUsers();
  Future<AppUser?> fetchUserById(String id);
  Future<List<String>> getUserEquipesPrefereesId(String userId);
  Future<List<String>> getUserMatchsRegardesId(String userId);
  Future<int> getUserNbMatchsRegardes(String userId);
  Future<int> getUserNbButs(String userId);
  Future<int> getUserNbMatchsRegardesParEquipe(String userId, String equipeId);
  Future<List<String>> getUserMatchsFavorisId(String userId);
  Future<void> matchFavori(String matchId, String userId, bool favori);
  Future<bool> isMatchFavori(String userId, String matchId);
  Future<void> setVisionnageMatch(String matchId, String userId, VisionnageMatch visionnageMatch);
  Future<VisionnageMatch> getVisionnageMatch(String userId, String matchId);
  Future<AppUser?> getCurrentUser();
}
