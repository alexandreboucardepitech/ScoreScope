import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/reaction.dart';

class MatchUserData {
  final String matchId;
  final bool favourite;
  final int? note;
  final String? mvpVoteId;
  final VisionnageMatch visionnageMatch;
  final bool private;
  final DateTime? watchedAt;
  late List<Commentaire> comments;
  late List<Reaction> reactions;

  MatchUserData({
    required this.matchId,
    this.favourite = false,
    this.note,
    this.mvpVoteId,
    this.visionnageMatch = VisionnageMatch.tele,
    this.private = false,
    this.watchedAt,
    this.comments = const [],
    this.reactions = const [],
  });

  Map<String, int> countsReactions() {
    final Map<String, int> counts = {};
    for (final r in reactions) {
      counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, List<String>> reactionsUserToEmojiMap() {
    final Map<String, List<String>> map = {};
    for (final r in reactions) {
      if (map[r.userId] == null) {
        map[r.userId] = [];
      }
      map[r.userId]!.add(r.emoji);
    }
    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'favourite': favourite,
      if (note != null) 'note': note,
      if (mvpVoteId != null) 'mvpVoteId': mvpVoteId,
      'visionnageMatch': visionnageMatch,
      'private': private,
      if (watchedAt != null) 'watchedAt': watchedAt,
      'comments': comments,
      'reactions': reactions,
    };
  }

  factory MatchUserData.fromJson(Map<String, dynamic> json) {
    List<Commentaire> parseComments(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        final List<Commentaire> out = [];
        for (final e in raw) {
          if (e is Map<String, dynamic>) {
            final id = e['id'] as String?;
            if (id == null || id.isEmpty) {
              continue;
            }
            try {
              out.add(Commentaire.fromJson(e, id));
            } catch (_) {
              continue;
            }
          }
        }
        return out;
      }
      return [];
    }

    List<Reaction> parseReactions(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        final List<Reaction> out = [];
        for (final e in raw) {
          if (e is Map<String, dynamic>) {
            final id = e['id'] as String?;
            if (id == null || id.isEmpty) {
              continue;
            }
            try {
              out.add(Reaction.fromJson(e, id));
            } catch (_) {
              continue;
            }
          }
        }
        return out;
      }
      return [];
    }

    return MatchUserData(
      matchId: json['matchId'] as String,
      favourite: json['favourite'] as bool? ?? false,
      note: json['note'] as int?,
      mvpVoteId: json['mvpVoteId'] as String?,
      visionnageMatch: json['visionnageMatch'] == null
          ? VisionnageMatch.tele
          : VisionnageMatchExt.fromString(json['visionnageMatch']) ??
              VisionnageMatch.tele,
      private: json['private'] as bool? ?? false,
      watchedAt: json['watchedAt'] is Timestamp
          ? (json['watchedAt'] as Timestamp).toDate()
          : (json['watchedAt'] is DateTime
              ? json['watchedAt'] as DateTime
              : null),
      comments: parseComments(json['comments']),
      reactions: parseReactions(json['reactions']),
    );
  }
}
