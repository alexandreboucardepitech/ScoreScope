import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';

bool canAccessPrivateInfos({
  Amitie? friendship,
  required AppUser userToAccessInfos,
  bool isMe = false,
  AppUser? me,
}) {
  if (isMe) return true;
  return ((userToAccessInfos.private == false ||
          (friendship != null && friendship.status == 'accepted')) ||
      userToAccessInfos.uid == me?.uid);
  // soit c'est un compte public soit on est amis
}

Future<bool> canAccessPrivateInfosAsync(
    AppUser me, AppUser userToAccessInfos) async {
  if (userToAccessInfos.uid == me.uid) return true;
  Amitie? friendship = await RepositoryProvider.amitieRepository
      .friendshipByUsersId(me.uid, userToAccessInfos.uid);

  return (userToAccessInfos.private == false ||
      (friendship != null && friendship.status == 'accepted'));
}
