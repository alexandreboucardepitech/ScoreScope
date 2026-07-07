import 'package:scorescope/models/watch_together.dart';
import 'package:scorescope/models/watch_together/watch_together_season_summary.dart';
import 'package:scorescope/services/repositories/i_watch_together_repository.dart';

class MockWatchTogetherRepository implements IWatchTogetherRepository {
  MockWatchTogetherRepository() {
    _seed();
  }

  final List<WatchTogether> _watchTogether = [];

  void _seed() {
    _watchTogether.add(
      WatchTogether(
        ownerId: 'u_alex',
        friendId: 'u_marie',
        matchId: '1', // Nantes PSG
        status: 'accepted',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
      ),
    );

    _watchTogether.add(
      WatchTogether(
        ownerId: 'u_alex',
        friendId: 'u_jules',
        matchId: '2',
        status: 'accepted',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
      ),
    );
  }

  @override
  Future<List<WatchTogether>> getFriendsWatchedWith(
    String ownerId,
    String matchId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _watchTogether
        .where((wt) => wt.ownerId == ownerId && wt.matchId == matchId)
        .toList();
  }

  @override
  Future<void> createWatchTogether(
      {required String matchId,
      required String ownerId,
      required String friendId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _watchTogether.add(
      WatchTogether(
        ownerId: ownerId,
        friendId: friendId,
        matchId: matchId,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> removeWatchTogether({
    required String matchId,
    required String ownerId,
    required String friendId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _watchTogether.removeWhere((wt) =>
        wt.ownerId == ownerId &&
        wt.friendId == friendId &&
        wt.matchId == matchId);
  }

  @override
  Future<void> acceptWatchTogether(
      {required String matchId,
      required String ownerId,
      required String friendId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _watchTogether.indexWhere((wt) =>
        wt.ownerId == ownerId &&
        wt.friendId == friendId &&
        wt.matchId == matchId);

    if (index != -1) {
      _watchTogether[index] = WatchTogether(
        ownerId: ownerId,
        friendId: friendId,
        matchId: matchId,
        status: 'accepted',
        createdAt: _watchTogether[index].createdAt,
      );
    } else {
      throw Exception('WatchTogether not found for acceptance');
    }
  }

  @override
  Future<void> removeAllWatchTogetherForUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _watchTogether
        .removeWhere((wt) => wt.ownerId == userId || wt.friendId == userId);
  }

  @override
  Future<WatchTogetherSeasonSummary> fetchUserWatchTogetherSummary({
    required String userId,
    required List<String> matchIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final filtered = _watchTogether.where((wt) =>
        (wt.ownerId == userId || wt.friendId == userId) &&
        matchIds.contains(wt.matchId));

    final totalMatchesWithFriends = filtered.length;

    final friendStatsMap = <String, WatchTogetherFriendStat>{};

    for (var wt in filtered) {
      final friendId = wt.ownerId == userId ? wt.friendId : wt.ownerId;
      if (!friendStatsMap.containsKey(friendId)) {
        friendStatsMap[friendId] = WatchTogetherFriendStat(
          friendId: friendId,
          friendName: 'Friend $friendId', // Placeholder name
          matchesTogether: 0,
        );
      }
      friendStatsMap[friendId] = WatchTogetherFriendStat(
        friendId: friendStatsMap[friendId]!.friendId,
        friendName: friendStatsMap[friendId]!.friendName,
        matchesTogether: friendStatsMap[friendId]!.matchesTogether + 1,
      );
    }

    final topFriends = friendStatsMap.values.toList()
      ..sort((a, b) => b.matchesTogether.compareTo(a.matchesTogether));

    return WatchTogetherSeasonSummary(
      totalMatchesWithFriends: totalMatchesWithFriends,
      distinctFriendsCount: friendStatsMap.length,
      topFriends: topFriends,
    );
  }
}
