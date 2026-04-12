import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

enum WatchStatus { accepted, pending }

class WatchFriend {
  final AppUser user;
  final WatchStatus status;

  WatchFriend({
    required this.user,
    required this.status,
  });
}

class WatchWithFriendsCard extends StatelessWidget {
  final List<WatchFriend> friends;
  final VoidCallback onAddFriend;
  final Function(AppUser user)? onRemoveFriend;

  const WatchWithFriendsCard({
    super.key,
    required this.friends,
    required this.onAddFriend,
    this.onRemoveFriend,
  });

  Widget _buildAvatar(BuildContext context, AppUser user) {
    final photo = user.photoUrl;

    if (photo != null && photo.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              width: 36,
              height: 36,
              errorWidget: (_, __, ___) => _fallbackAvatar(context, user),
            ),
          ),
        ),
      );
    }

    return _fallbackAvatar(context, user);
  }

  Widget _fallbackAvatar(BuildContext context, AppUser user) {
    final name = user.displayName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: ColorPalette.pictureBackground(context),
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, WatchStatus status) {
    final isAccepted = status == WatchStatus.accepted;

    final bgColor = isAccepted
        ? ColorPalette.success(context).withOpacity(0.15)
        : ColorPalette.warning(context).withOpacity(0.15);

    final fgColor = isAccepted
        ? ColorPalette.success(context)
        : ColorPalette.warning(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isAccepted ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: fgColor,
          ),
          const SizedBox(width: 4),
          Text(
            isAccepted ? "Confirmé" : "En attente",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFriends = friends.isNotEmpty;

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                hasFriends
                    ? "Regardé avec"
                    : "Tu as regardé ce match avec des amis ?",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.textAccent(context),
                    ),
              ),
            ),
            const SizedBox(height: 10),
            if (!hasFriends) ...[
              Center(
                child: Text(
                  "Ajoute les amis avec qui tu as vu ce match.",
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: onAddFriend,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text(
                    "Ajouter un ami",
                    style: TextStyle(
                      color: ColorPalette.textPrimary(
                        context,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.buttonSecondary(context),
                  ),
                ),
              ),
            ],
            if (hasFriends) ...[
              ...friends.map(
                (friend) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      _buildAvatar(context, friend.user),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          friend.user.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textAccent(context),
                          ),
                        ),
                      ),
                      _buildStatusChip(context, friend.status),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: ColorPalette.textSecondary(context),
                        ),
                        onPressed: () {
                          if (onRemoveFriend != null) {
                            onRemoveFriend!(friend.user);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: ColorPalette.divider(context)),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: onAddFriend,
                  icon: Icon(
                    Icons.add,
                    color: ColorPalette.accent(context),
                  ),
                  label: Text(
                    "Ajouter un ami",
                    style: TextStyle(
                      color: ColorPalette.accent(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
