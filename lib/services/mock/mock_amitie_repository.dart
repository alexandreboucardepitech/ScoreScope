import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/repositories/i_amitie_repository.dart';

class MockAmitieRepository implements IAmitieRepository {
  MockAmitieRepository() {
    _seed();
  }

  final List<Amitie> _friendships = [];

  void _seed() {
    _friendships.add(
      Amitie(
        firstUserId: 'u_alex',
        secondUserId: 'u_marie',
        status: 'accepted',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
      ),
    );

    _friendships.add(
      Amitie(
        firstUserId: 'u_jules',
        secondUserId: 'u_alex',
        status: 'pending',
        createdAt: DateTime.parse('2024-10-10T12:00:00Z'),
      ),
    );
  }

  @override
  Future<List<Amitie>> fetchFriendshipsForUser({
    required String userId,
    bool alsoGetBlockedUsers = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _friendships
        .where((amitie) =>
            amitie.firstUserId == userId || amitie.secondUserId == userId)
        .where((amitie) => alsoGetBlockedUsers || amitie.status != 'blocked')
        .toList();
  }

  @override
  Future<List<AppUser>> fetchFriendsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final acceptedFriendships = _friendships
        .where((amitie) =>
            (amitie.firstUserId == userId || amitie.secondUserId == userId) &&
            amitie.status == 'accepted')
        .toList();

    final friends = <AppUser>[];

    for (final f in acceptedFriendships) {
      final friendId = f.firstUserId == userId ? f.secondUserId : f.firstUserId;
      final friendUser = await MockAppUserRepository().fetchUserById(friendId);
      if (friendUser != null) {
        friends.add(friendUser);
      }
    }

    return friends;
  }

  @override
  Future<int> getUserNbAmis(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final friends = _friendships
        .where((a) =>
            (a.firstUserId == userId || a.secondUserId == userId) &&
            a.status == 'accepted')
        .toList();
    return friends.length;
  }

  @override
  Future<List<Amitie>> fetchFriendRequestsReceived(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _friendships
        .where((a) => a.status == 'pending' && a.secondUserId == userId)
        .toList();
  }

  @override
  Future<List<Amitie>> fetchFriendRequestsSent(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _friendships
        .where((a) => a.status == 'pending' && a.firstUserId == userId)
        .toList();
  }

  @override
  Future<List<Amitie>> fetchBlockedUsers(
      String userId, String blockType) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (blockType == 'blocking') {
      return _friendships
          .where((a) => a.status == 'blocked' && a.firstUserId == userId)
          .toList();
    } else if (blockType == 'blocked') {
      return _friendships
          .where((a) => a.status == 'blocked' && a.secondUserId == userId)
          .toList();
    } else if (blockType == 'both') {
      return _friendships
          .where((a) =>
              a.status == 'blocked' &&
              (a.firstUserId == userId || a.secondUserId == userId))
          .toList();
    } else {
      throw ArgumentError('Invalid blockType: $blockType');
    }
  }

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _friendships.add(
      Amitie(
        firstUserId: fromUserId,
        secondUserId: toUserId,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> acceptFriendRequest(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _friendships.indexWhere((a) =>
        (a.firstUserId == userId1 && a.secondUserId == userId2) ||
        (a.firstUserId == userId2 && a.secondUserId == userId1));
    if (index != -1) {
      _friendships[index] = Amitie(
        firstUserId: _friendships[index].firstUserId,
        secondUserId: _friendships[index].secondUserId,
        status: 'accepted',
        createdAt: _friendships[index].createdAt,
      );
    }
  }

  @override
  Future<void> rejectFriendRequest(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _friendships.removeWhere((a) =>
        (a.firstUserId == userId1 && a.secondUserId == userId2) ||
        (a.firstUserId == userId2 && a.secondUserId == userId1));
  }

  @override
  Future<void> removeFriend(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _friendships.removeWhere((a) =>
        (a.firstUserId == userId1 && a.secondUserId == userId2) ||
        (a.firstUserId == userId2 && a.secondUserId == userId1));
  }

  @override
  Future<void> blockUser(String fromUserId, String toUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _friendships.indexWhere((a) =>
        (a.firstUserId == fromUserId && a.secondUserId == toUserId) ||
        (a.firstUserId == toUserId && a.secondUserId == fromUserId));
    if (index != -1) {
      _friendships[index] = Amitie(
        firstUserId: _friendships[index].firstUserId,
        secondUserId: _friendships[index].secondUserId,
        status: 'blocked',
        createdAt: _friendships[index].createdAt,
      );
    }
  }

  @override
  Future<void> unblockUser(String fromUserId, String toUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _friendships.indexWhere((a) =>
        (a.firstUserId == fromUserId && a.secondUserId == toUserId) ||
        (a.firstUserId == toUserId && a.secondUserId == fromUserId));
    if (index != -1) {
      _friendships.removeAt(index);
    }
  }

  @override
  Future<Amitie?> friendshipByUsersId(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 200));
    Amitie? friendship;
    try {
      friendship = _friendships.firstWhere(
        (a) =>
            (a.firstUserId == userId1 && a.secondUserId == userId2) ||
            (a.firstUserId == userId2 && a.secondUserId == userId1),
      );
    } catch (_) {
      friendship = null;
    }

    if (friendship == null) return null;
    return friendship;
  }

  @override
  Future<int> getUserNbPendingFriendRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pendingRequests = _friendships
        .where((a) => a.status == 'pending' && a.secondUserId == userId)
        .toList();
    return pendingRequests.length;
  }
}
