class WatchTogetherFriendStat {
  final String friendId;
  final String friendName;
  final String? friendPhoto;
  final int matchesTogether;

  const WatchTogetherFriendStat({
    required this.friendId,
    required this.friendName,
    this.friendPhoto,
    required this.matchesTogether,
  });
}

class WatchTogetherSeasonSummary {
  final int totalMatchesWithFriends;
  final int distinctFriendsCount;
  final List<WatchTogetherFriendStat> topFriends;

  const WatchTogetherSeasonSummary({
    required this.totalMatchesWithFriends,
    required this.distinctFriendsCount,
    required this.topFriends,
  });

  static const empty = WatchTogetherSeasonSummary(
    totalMatchesWithFriends: 0,
    distinctFriendsCount: 0,
    topFriends: [],
  );
}