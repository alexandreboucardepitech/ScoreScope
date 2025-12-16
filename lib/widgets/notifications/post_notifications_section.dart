import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/post/post_notification.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/amis/comments_page.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostNotificationsSection extends StatefulWidget {
  final List<PostNotification> notifications;
  final Map<String, MatchModel> matchCache;
  final Map<String, AppUser?> userCache;
  final VoidCallback onNotificationOpened;
  final String? currentUserId;

  const PostNotificationsSection({
    super.key,
    required this.notifications,
    required this.matchCache,
    required this.userCache,
    required this.onNotificationOpened,
    this.currentUserId,
  });

  @override
  State<PostNotificationsSection> createState() =>
      _PostNotificationsSectionState();
}

class _PostNotificationsSectionState extends State<PostNotificationsSection> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      if (widget.currentUserId != null) {
        _currentUserId = widget.currentUserId;
        return;
      }
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (mounted) setState(() => _currentUserId = user!.uid);
    } catch (e) {
      // Si échec, laisse _currentUserId null — on n'interrompt pas l'UI.
      if (mounted) setState(() => _currentUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTiles =
        widget.notifications.expand((n) => _splitNotification(n)).toList();

    allTiles.sort(
      (a, b) => b.notification.lastPostActivity
          .compareTo(a.notification.lastPostActivity),
    );

    final newTiles = allTiles.where((t) => t.isNew).toList();
    final oldTiles = allTiles.where((t) => !t.isNew).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Notifications'),
        if (newTiles.isEmpty && oldTiles.isEmpty)
          Center(
            child: Text(
              'Aucune notification',
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ),
        ..._buildTiles(context, newTiles),
        newTiles.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.buttonSecondary(context),
                    ),
                    onPressed: () {
                      if (_currentUserId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur : utilisateur non connecté'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      RepositoryProvider.notificationRepository
                          .markAllNotificationsSeen(userId: _currentUserId!);
                      widget
                          .onNotificationOpened(); // re fetch les notifications pour mettre à jour l'affichage
                    },
                    child: Text(
                      "Tout marquer comme vu",
                      style: TextStyle(
                        color: ColorPalette.textAccent(context),
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  'Aucune nouvelle notification',
                  style: TextStyle(
                    color: ColorPalette.textSecondary(context),
                  ),
                ),
              ),
        if (oldTiles.isNotEmpty) ...[
          _sectionHeader(context, 'Déjà vues'),
          ..._buildTiles(context, oldTiles),
        ],
      ],
    );
  }

  List<_NotificationTileData> _splitNotification(
    PostNotification notification,
  ) {
    final tiles = <_NotificationTileData>[];

    if (notification.commentCounts.isNotEmpty) {
      tiles.add(
        _NotificationTileData(
          notification: notification,
          type: 'comments',
          isNew: notification.hasNewComments,
        ),
      );
    }

    if (notification.reactionCounts.isNotEmpty) {
      tiles.add(
        _NotificationTileData(
          notification: notification,
          type: 'reactions',
          isNew: notification.hasNewReactions,
        ),
      );
    }

    return tiles;
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

  List<Widget> _buildTiles(
    BuildContext context,
    List<_NotificationTileData> tiles,
  ) {
    return tiles.asMap().entries.map((entry) {
      final index = entry.key;
      final tile = entry.value;

      final isLast = index == tiles.length - 1;

      return Column(
        children: [
          _buildNotificationTile(context, tile),
          if (!isLast)
            Divider(
              height: 1,
              color: ColorPalette.border(context),
            ),
        ],
      );
    }).toList();
  }

  Widget _buildNotificationTile(
    BuildContext context,
    _NotificationTileData data,
  ) {
    final notification = data.notification;
    final match = widget.matchCache[notification.matchId];

    final counts = data.type == 'comments'
        ? notification.commentCounts
        : notification.reactionCounts;

    final users = counts.keys
        .map((id) => widget.userCache[id])
        .whereType<AppUser>()
        .toList()
        .reversed
        .toList();

    return GestureDetector(
      onTap: () async {
        if (_currentUserId != null) {
          await RepositoryProvider.notificationRepository.markNotificationSeen(
            userId: _currentUserId!,
            ownerUserId: notification.ownerUserId,
            matchId: notification.matchId,
            type: data.type,
          );
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentsPage(
              matchId: notification.matchId,
              ownerUserId: notification.ownerUserId,
            ),
          ),
        );
        widget.onNotificationOpened();
      },
      child: Container(
        width: double.infinity,
        color: data.isNew
            ? ColorPalette.tileSelected(context)
            : ColorPalette.tileBackground(context),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatars(context, users),
            const SizedBox(width: 12),
            Expanded(
              child: _buildText(
                context,
                notification,
                users,
                data.type,
                data.isNew,
              ),
            ),
            const SizedBox(width: 12),
            if (match != null) _buildMiniMatch(context, match),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatars(BuildContext context, List<AppUser> users) {
    if (users.isEmpty) {
      return _avatar(context, null);
    }

    if (users.length == 1) {
      return _avatar(context, users.first);
    }

    final displayed = users.take(3).toList();
    final extra = users.length - displayed.length;

    const double avatarRadius = 18;
    const double avatarSize = avatarRadius * 2 + 3; // + bordure
    const double spacing = 10;

    final double stackWidth = avatarSize + spacing * (displayed.length - 1);

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          for (int i = displayed.length - 1; i >= 0; i--)
            Positioned(
              left: (48 - stackWidth) / 2 + i * spacing,
              child: _avatar(
                context,
                displayed[i],
                radius: avatarRadius,
              ),
            ),
          if (extra > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorPalette.accent(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorPalette.border(context),
                  ),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatar(
    BuildContext context,
    AppUser? user, {
    double radius = 18,
  }) {
    return GestureDetector(
      onTap: () {
        if (user == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileView(
              user: user,
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(1.5), // épaisseur de la bordure
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorPalette.border(context),
        ),
        child: CircleAvatar(
          radius: radius,
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
      ),
    );
  }

  Widget _buildText(
    BuildContext context,
    PostNotification notification,
    List<AppUser> users,
    String type,
    bool isNew,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: _buildNotificationText(context, users, type),
        ),
        const SizedBox(height: 4),
        Text(
          timeago.format(notification.lastPostActivity, locale: 'fr'),
          style: TextStyle(
            fontSize: 12,
            color: ColorPalette.textSecondary(context),
          ),
        ),
      ],
    );
  }

  TextSpan _buildNotificationText(
    BuildContext context,
    List<AppUser> users,
    String type,
  ) {
    final displayed = users.length > 2 ? users.take(2).toList() : users;
    final remaining = users.length - displayed.length;

    final action = type == 'comments'
        ? (displayed.length > 1
            ? 'ont commenté votre match'
            : 'a commenté votre match')
        : (displayed.length > 1
            ? 'ont réagi à votre match'
            : 'a réagi à votre match');

    return TextSpan(
      style: TextStyle(
        fontSize: 14,
        color: ColorPalette.textPrimary(context),
      ),
      children: [
        for (int i = 0; i < displayed.length; i++) ...[
          TextSpan(
            text: displayed[i].displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileView(
                      user: users[i],
                      onBackPressed: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
          ),
          if (i < displayed.length - 1) const TextSpan(text: ' et '),
        ],
        if (remaining > 0) TextSpan(text: ' et $remaining autres'),
        TextSpan(text: ' $action'),
      ],
    );
  }

  Widget _buildMiniMatch(BuildContext context, MatchModel match) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _teamLogo(match.equipeDomicile.logoPath),
            const SizedBox(width: 6),
            _teamLogo(match.equipeExterieur.logoPath),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorPalette.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _teamLogo(String? url) {
    if (url == null) {
      return const SizedBox(width: 24, height: 24);
    }

    return Image.asset(
      url,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}

class _NotificationTileData {
  final PostNotification notification;
  final String type;
  final bool isNew;

  _NotificationTileData({
    required this.notification,
    required this.type,
    required this.isNew,
  });
}
