import 'package:scorescope/models/app_user.dart';

abstract class IAppUserRepository {
  Future<List<AppUser>> fetchAllUsers();
  Future<AppUser?> fetchUserById(String id);
  Future<List<String>> getUserEquipesPrefereesId(String userId);
  Future<List<String>> getUserMatchsRegardesId(String userId);
  Future<int> getUserNbMatchsRegardes(String userId);
  Future<int> getUserNbButs(String userId);
  Future<List<String>> getUserMatchsFavorisId(String userId);
  Future<AppUser?> getCurrentUser();
}
