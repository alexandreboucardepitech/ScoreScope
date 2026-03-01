import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/equipe.dart';

class FriendItem {
  final AppUser user;
  final DateTime friendshipDate;
  final bool alreadyInvited;
  final List<Equipe> equipesPreferees;

  FriendItem({
    required this.user,
    required this.friendshipDate,
    required this.alreadyInvited,
    required this.equipesPreferees,
  });
}
