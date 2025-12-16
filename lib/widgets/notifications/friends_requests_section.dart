import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendRequestsSection extends StatelessWidget {
  final List<Amitie> requests;
  final Map<String, AppUser?> userCache;
  final Map<String, bool> processing;
  final String currentUserId;

  final void Function(Amitie) onAccept;
  final void Function(Amitie) onReject;

  const FriendRequestsSection({
    super.key,
    required this.requests,
    required this.userCache,
    required this.processing,
    required this.currentUserId,
    required this.onAccept,
    required this.onReject,
  });

  String _senderIdFor(Amitie a) =>
      a.firstUserId == currentUserId ? a.secondUserId : a.firstUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Demandes d\'amis'),
        if (requests.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aucune demande reçue',
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ),
        ...requests.asMap().entries.map((entry) {
          final index = entry.key;
          final a = entry.value;
          final isLast = index == requests.length - 1;

          return Column(
            children: [
              _friendRequestTile(context, a),
              if (!isLast)
                Divider(
                  height: 1,
                  color: ColorPalette.border(context),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary(context),
        ),
      ),
    );
  }

  Widget _friendRequestTile(BuildContext context, Amitie a) {
    final senderId = _senderIdFor(a);
    final profile = userCache[senderId];
    final isProcessing = processing[senderId] == true;

    return Container(
      width: double.infinity,
      color: ColorPalette.tileSelected(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _avatar(context, profile),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? senderId,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(a.createdAt, locale: 'fr'),
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorPalette.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _actionButton(
            context,
            icon: Icons.close,
            color: ColorPalette.error(context),
            onTap: isProcessing ? null : () => onReject(a),
          ),
          _actionButton(
            context,
            icon: Icons.check,
            color: ColorPalette.success(context),
            onTap: isProcessing ? null : () => onAccept(a),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return IconButton(
      iconSize: 22,
      splashRadius: 20,
      onPressed: onTap,
      icon: Icon(icon, color: color),
    );
  }

  Widget _avatar(BuildContext context, AppUser? user) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPalette.border(context),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: ColorPalette.pictureBackground(context),
        backgroundImage:
            user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
        child: user?.photoUrl == null
            ? Text(
                user?.displayName?.characters.first.toUpperCase() ?? '?',
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                ),
              )
            : null,
      ),
    );
  }
}
