import 'package:cloud_firestore/cloud_firestore.dart';

class PostNotification {
  final String ownerUserId;
  final String matchId;

  final int newCommentsCount;
  final int newReactionsCount;

  /// userId -> number of comments
  final Map<String, int> commentCounts;

  /// userId -> number of reactions
  final Map<String, int> reactionCounts;

  final DateTime lastPostActivity;

  PostNotification({
    required this.ownerUserId,
    required this.matchId,
    required this.newCommentsCount,
    required this.newReactionsCount,
    required this.commentCounts,
    required this.reactionCounts,
    required this.lastPostActivity,
  });

  bool hasNewComments() {
    return newCommentsCount > 0;
  }

  bool hasNewReactions() {
    return newReactionsCount > 0;
  }

  factory PostNotification.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseCounts(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
      return {};
    }

    Map<String, int> commentCounts = parseCounts(json['commentCounts']);
    Map<String, int> reactionCounts = parseCounts(json['reactionCounts']);

    return PostNotification(
      ownerUserId: json['ownerUserId'] as String,
      matchId: json['matchId'] as String,
      newCommentsCount: json['newCommentsCount'] as int? ?? 0,
      newReactionsCount: json['newReactionsCount'] as int? ?? 0,
      commentCounts: commentCounts,
      reactionCounts: reactionCounts,
      lastPostActivity: (json['lastPostActivity'] is Timestamp)
          ? (json['lastPostActivity'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'matchId': matchId,
      'newCommentsCount': newCommentsCount,
      'newReactionsCount': newReactionsCount,
      'commentCounts': commentCounts,
      'reactionCounts': reactionCounts,
      'lastPostActivity': lastPostActivity,
    };
  }

  PostNotification copyWith({
    int? newCommentsCount,
    int? newReactionsCount,
    Map<String, int>? commentCounts,
    Map<String, int>? reactionCounts,
    DateTime? lastPostActivity,
  }) {
    return PostNotification(
      ownerUserId: ownerUserId,
      matchId: matchId,
      newCommentsCount: newCommentsCount ?? this.newCommentsCount,
      newReactionsCount: newReactionsCount ?? this.newReactionsCount,
      commentCounts: commentCounts ?? this.commentCounts,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      lastPostActivity: lastPostActivity ?? this.lastPostActivity,
    );
  }
}
