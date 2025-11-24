import 'package:scorescope/models/enum/visionnage_match.dart';

class MatchUserData {
  final String matchId;
  final bool favourite;
  final int? note;
  final String? mvpVoteId;
  final VisionnageMatch visionnageMatch;
  final bool private;

  MatchUserData({
    required this.matchId,
    this.favourite = false,
    this.note,
    this.mvpVoteId,
    this.visionnageMatch = VisionnageMatch.tele,
    this.private = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'favourite': favourite,
      if (note != null) 'note': note,
      if (mvpVoteId != null) 'mvpVoteId': mvpVoteId,
      'visionnageMatch': visionnageMatch,
      'private': private,
    };
  }

  factory MatchUserData.fromJson(Map<String, dynamic> json) {
    return MatchUserData(
      matchId: json['matchId'] as String,
      favourite: json['favourite'],
      note: json['note'] as int?,
      mvpVoteId: json['mvpVoteId'] as String?,
      visionnageMatch: json['visionnageMatch'] == null
          ? VisionnageMatch.tele
          : VisionnageMatchExt.fromString(json['visionnageMatch']) ??
              VisionnageMatch.tele,
      // visionnageMatch: si il y a rien ou que "fromString" renvoie null on met "tele" par défaut
      private: json['private'] ?? false,
    );
  }
}
