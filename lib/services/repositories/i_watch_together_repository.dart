import 'package:scorescope/models/watch_together.dart';

abstract class IWatchTogetherRepository {
  Future<List<WatchTogether>> getFriendsWatchedWith(
    String ownerId,
    String matchId,
  );

  Future<void> createWatchTogether({
    required String matchId,
    required String ownerId,
    required String friendId,
  });

  Future<void> removeWatchTogether({
    required String matchId,
    required String ownerId,
    required String friendId,
  });
}
