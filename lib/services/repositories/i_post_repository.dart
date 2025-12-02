import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/reaction.dart';

abstract class IPostRepository {
  Future<List<FriendMatchEntry>> fetchFriendsMatchesUserData(String userId);
  Future<List<FriendMatchEntry>> fetchFriendsMatchUserDataForMatch(
      String matchId, String userId);

  Future<void> addComment({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String text,
  });

  Future<void> editComment({
    required String ownerUserId,
    required String matchId,
    required String commentId,
    required String newText,
  });

  Future<void> deleteComment({
    required String ownerUserId,
    required String matchId,
    required String commentId,
  });

  Future<List<Commentaire>> fetchComments({
    required String ownerUserId,
    required String matchId,
    int? limit,
  });

  Future<void> addReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String emoji,
  });

  Future<void> deleteReaction({
    required String ownerUserId,
    required String matchId,
    required String authorId,
    required String emoji,
  });

  Future<List<Reaction>> fetchReactions({
    required String ownerUserId,
    required String matchId,
    int? limit,
  });
}
