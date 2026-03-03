import 'package:scorescope/models/watch_together.dart';
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
}
