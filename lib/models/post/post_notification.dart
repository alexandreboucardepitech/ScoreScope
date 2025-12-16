import 'package:cloud_firestore/cloud_firestore.dart';

class PostNotification {
  final String ownerUserId;
  final String matchId;

  final bool hasNewComments;
  final bool hasNewReactions;

  /// userId -> number of comments
  final Map<String, int> commentCounts;

  /// userId -> number of reactions
  final Map<String, int> reactionCounts;

  final DateTime lastPostActivity;

  PostNotification({
    required this.ownerUserId,
    required this.matchId,
    required this.hasNewComments,
    required this.hasNewReactions,
    required this.commentCounts,
    required this.reactionCounts,
    required this.lastPostActivity,
  });

  factory PostNotification.fromJson(Map<String, dynamic> json) {
    Map<String, int> _parseCounts(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
      return {};
    }

    return PostNotification(
      ownerUserId: json['ownerUserId'] as String,
      matchId: json['matchId'] as String,
      hasNewComments: json['hasNewComments'] as bool? ?? false,
      hasNewReactions: json['hasNewReactions'] as bool? ?? false,
      commentCounts: _parseCounts(json['commentCounts']),
      reactionCounts: _parseCounts(json['reactionCounts']),
      lastPostActivity: (json['lastPostActivity'] is Timestamp)
          ? (json['lastPostActivity'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'matchId': matchId,
      'hasNewComments': hasNewComments,
      'hasNewReactions': hasNewReactions,
      'commentCounts': commentCounts,
      'reactionCounts': reactionCounts,
      'lastPostActivity': lastPostActivity,
    };
  }

  PostNotification copyWith({
    bool? hasNewComments,
    bool? hasNewReactions,
    Map<String, int>? commentCounts,
    Map<String, int>? reactionCounts,
    DateTime? lastPostActivity,
  }) {
    return PostNotification(
      ownerUserId: ownerUserId,
      matchId: matchId,
      hasNewComments: hasNewComments ?? this.hasNewComments,
      hasNewReactions: hasNewReactions ?? this.hasNewReactions,
      commentCounts: commentCounts ?? this.commentCounts,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      lastPostActivity: lastPostActivity ?? this.lastPostActivity,
    );
  }
}
