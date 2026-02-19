import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';

abstract class IAmitieRepository {
  Future<List<Amitie>> fetchFriendshipsForUser({
    required String userId,
    bool alsoGetBlockedUsers = false,
  });
  Future<int> getUserNbAmis(String userId);
  Future<List<AppUser>> fetchFriendsForUser(String userId);
  Future<List<Amitie>> fetchFriendRequestsReceived(String userId);
  Future<List<Amitie>> fetchFriendRequestsSent(String userId);
  Future<List<Amitie>> fetchBlockedUsers(String userId, String blockType);
  Future<void> sendFriendRequest(String fromUserId, String toUserId);
  Future<void> acceptFriendRequest(String userId1, String userId2);
  Future<void> rejectFriendRequest(String userId1, String userId2);
  Future<void> removeFriend(String userId1, String userId2);
  Future<void> blockUser(String fromUserId, String toUserId);
  Future<void> unblockUser(String fromUserId, String toUserId);
  Future<Amitie?> friendshipByUsersId(String userId1, String userId2);
  Future<int> getUserNbPendingFriendRequests(String userId);
}
