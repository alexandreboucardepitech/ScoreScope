
class MatchUserData {
  final String matchId;
  final bool favourite;
  final int? note;
  final String? mvpVoteId;

  MatchUserData({
    required this.matchId,
    this.favourite = false,
    this.note,
    this.mvpVoteId,
  });

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'favourite': favourite,
      if (note != null) 'note': note,
      if (mvpVoteId != null) 'mvpVoteId': mvpVoteId,
    };
  }

  factory MatchUserData.fromJson(Map<String, dynamic> json) {
    return MatchUserData(
      matchId: json['matchId'] as String,
      favourite: json['favourite'],
      note: json['note'] as int?,
      mvpVoteId: json['mvpVoteId'] as String?,
    );
  }
}
