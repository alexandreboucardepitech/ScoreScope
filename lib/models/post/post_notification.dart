import 'package:cloud_firestore/cloud_firestore.dart';

class PostNotification {
  final String ownerUserId;
  final String matchId;

  final int newCommentsCount;
  final int newReactionsCount;
  final int newWatchTogetherInvitationsCount;

  /// userId -> number of comments
  final Map<String, int> commentCounts;

  /// userId -> number of reactions
  final Map<String, int> reactionCounts;

  /// userId -> number of watch together invitations
  final Map<String, int> watchTogetherInvitationsCounts;

  final DateTime lastPostActivity;

  PostNotification({
    required this.ownerUserId,
    required this.matchId,
    required this.newCommentsCount,
    required this.newReactionsCount,
    required this.newWatchTogetherInvitationsCount,
    required this.commentCounts,
    required this.reactionCounts,
    required this.watchTogetherInvitationsCounts,
    required this.lastPostActivity,
  });

  bool hasNewComments() {
    return newCommentsCount > 0;
  }

  bool hasNewReactions() {
    return newReactionsCount > 0;
  }

  bool hasNewWatchTogetherInvitations() {
    return newWatchTogetherInvitationsCount > 0;
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
    Map<String, int> watchTogetherInvitationsCounts =
        parseCounts(json['watchTogetherInvitationsCounts']);

    return PostNotification(
      ownerUserId: json['ownerUserId'] as String,
      matchId: json['matchId'] as String,
      newCommentsCount: json['newCommentsCount'] as int? ?? 0,
      newReactionsCount: json['newReactionsCount'] as int? ?? 0,
      newWatchTogetherInvitationsCount:
          json['newWatchTogetherInvitationsCount'] as int? ?? 0,
      commentCounts: commentCounts,
      reactionCounts: reactionCounts,
      watchTogetherInvitationsCounts: watchTogetherInvitationsCounts,
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
      'newWatchTogetherInvitationsCount': newWatchTogetherInvitationsCount,
      'commentCounts': commentCounts,
      'reactionCounts': reactionCounts,
      'watchTogetherInvitationsCounts': watchTogetherInvitationsCounts,
      'lastPostActivity': lastPostActivity,
    };
  }

  PostNotification copyWith({
    int? newCommentsCount,
    int? newReactionsCount,
    int? newWatchTogetherInvitationsCount,
    Map<String, int>? commentCounts,
    Map<String, int>? reactionCounts,
    Map<String, int>? watchTogetherInvitationsCounts,
    DateTime? lastPostActivity,
  }) {
    return PostNotification(
      ownerUserId: ownerUserId,
      matchId: matchId,
      newCommentsCount: newCommentsCount ?? this.newCommentsCount,
      newReactionsCount: newReactionsCount ?? this.newReactionsCount,
      newWatchTogetherInvitationsCount: newWatchTogetherInvitationsCount ??
          this.newWatchTogetherInvitationsCount,
      commentCounts: commentCounts ?? this.commentCounts,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      watchTogetherInvitationsCounts:
          watchTogetherInvitationsCounts ?? this.watchTogetherInvitationsCounts,
      lastPostActivity: lastPostActivity ?? this.lastPostActivity,
    );
  }
}
