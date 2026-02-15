import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';

bool canAccessPrivateInfos(Amitie? friendship, AppUser userToAccessInfos) {
  return (userToAccessInfos.privateAccount == false ||
      (friendship != null && friendship.status == 'accepted'));
  // soit c'est un compte public soit on est amis
}

Future<bool> canAccessPrivateInfosAsync(
    AppUser me, AppUser userToAccessInfos) async {
  Amitie? friendship = await RepositoryProvider.amitieRepository
      .friendshipByUsersId(me.uid, userToAccessInfos.uid);

  return (userToAccessInfos.privateAccount == false ||
      (friendship != null && friendship.status == 'accepted'));
}
