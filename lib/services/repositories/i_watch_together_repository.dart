import 'package:scorescope/models/watch_together.dart';
import 'package:scorescope/models/watch_together/watch_together_season_summary.dart';

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

  Future<void> acceptWatchTogether({
    required String matchId,
    required String ownerId,
    required String friendId,
  });

  Future<void> removeAllWatchTogetherForUser({
    required String userId,
  });

  Future<WatchTogetherSeasonSummary> fetchUserWatchTogetherSummary({
    required String userId,
    required List<String> matchIds,
  });
}
