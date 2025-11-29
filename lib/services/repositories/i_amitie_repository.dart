import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';

abstract class IAmitieRepository {
  Future<List<Amitie>> fetchFriendshipsForUser(String userId);
  Future<int> getUserNbAmis(String userId);
  Future<List<AppUser>> fetchFriendsForUser(String userId);
  Future<List<Amitie>> fetchFriendRequestsReceived(String userId);
  Future<List<Amitie>> fetchFriendRequestsSent(String userId);
  Future<void> sendFriendRequest(String fromUserId, String toUserId);
  Future<void> acceptFriendRequest(String userId1, String userId2);
  Future<void> rejectFriendRequest(String userId1, String userId2);
  Future<void> removeFriend(String userId1, String userId2);
  Future<Amitie?> friendshipByUsersId(String userId1, String userId2);
  Future<int> getUserNbPendingFriendRequests(String userId);
  Future<List<FriendMatchEntry>> fetchFriendsMatchesUserData(String userId);
  Future<List<FriendMatchEntry>> fetchFriendsMatchUserDataForMatch(
      String matchId, String userId);
}
