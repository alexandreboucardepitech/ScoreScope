import 'package:scorescope/models/post/post_notification.dart';

abstract class INotificationRepository {
  Future<List<PostNotification>> fetchNotifications({
    required String userId,
  });

  Future<void> markNotificationSeen({
    required String userId,
    required String ownerUserId,
    required String matchId,
    String? type,
  });

  Future<void> markAllNotificationsSeen({required String userId});

  Future<void> notifyNewComment({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  });

  Future<void> notifyCommentDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  });

  Future<void> notifyNewReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  });

  Future<void> notifyReactionDeleted({
    required String ownerUserId,
    required String matchId,
    required String authorId,
  });

  Future<void> deleteOldNotifications({
    required String userId,
    required int daysLimit,
  });

  Future<int> getNumberNotifications({required String userId});
}
