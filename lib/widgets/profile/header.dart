import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/users/can_access_private_infos.dart';
import 'package:scorescope/views/profile/friends_page.dart';
import 'package:scorescope/widgets/profile/profile_action.dart';
import 'package:scorescope/widgets/profile/stat_tile.dart';
import 'package:shimmer/shimmer.dart';

class Header extends StatefulWidget {
  final AppUser user;
  final bool isMe;
  final bool isLoadingNbMatchsRegardes;
  final int? userNbMatchsRegardes;
  final bool isLoadingNbButs;
  final int? userNbButs;
  final bool isLoadingNbAmis;
  final int? userNbAmis;
  final Function(String)? onStatusChanged;
  final Amitie? friendship;
  final AppUser? currentUser;
  final bool isPerformingFriendAction;
  final void Function(String action)? onActionRequested;
  final void Function(void)? onProfileEdited;

  /// Callback appelé quand le contenu du header est "prêt" (après image / layout)
  final VoidCallback? onContentReady;

  const Header({
    super.key,
    required this.user,
    required this.isMe,
    this.isLoadingNbMatchsRegardes = false,
    this.userNbMatchsRegardes,
    this.isLoadingNbButs = false,
    this.userNbButs,
    this.isLoadingNbAmis = false,
    this.userNbAmis,
    this.onStatusChanged,
    this.friendship,
    this.currentUser,
    this.isPerformingFriendAction = false,
    this.onActionRequested,
    this.onProfileEdited,
    this.onContentReady,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _hasNotifiedContentReady = false;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    // si une image réseau est présente, on attache un listener pour notifier
    _maybeListenImage();
  }

  @override
  void didUpdateWidget(covariant Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.photoUrl != widget.user.photoUrl) {
      _removeImageListener();
      _maybeListenImage();
    }
    // on remet _hasNotifiedContentReady à false si le contenu change
    if (oldWidget.user != widget.user) {
      _hasNotifiedContentReady = false;
    }
  }

  void _maybeListenImage() {
    final url = widget.user.photoUrl;
    if (url == null) {
      // pas d'image réseau -> notifier après premier frame
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _notifyContentReadyOnce());
      return;
    }

    final provider = NetworkImage(url);
    final stream = provider.resolve(const ImageConfiguration());
    _imageListener = ImageStreamListener((imageInfo, synchronousCall) {
      // image chargée -> notifier (une seule fois)
      _notifyContentReadyOnce();
    }, onError: (error, stackTrace) {
      // erreur de chargement -> notifier quand même pour permettre la mesure
      _notifyContentReadyOnce();
    });

    stream.addListener(_imageListener!);
  }

  void _removeImageListener() {
    if (_imageListener == null) return;
    final url = widget.user.photoUrl;
    if (url == null) return;
    final provider = NetworkImage(url);
    final stream = provider.resolve(const ImageConfiguration());
    try {
      stream.removeListener(_imageListener!);
    } catch (_) {}
    _imageListener = null;
  }

  void _notifyContentReadyOnce() {
    if (_hasNotifiedContentReady) return;
    _hasNotifiedContentReady = true;
    // notifier après le prochain frame pour s'assurer que le layout est final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onContentReady?.call();
    });
  }

  @override
  void dispose() {
    _removeImageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double statsLabelHeight = 20;

    // On s'assure de notifier aussi si build est appelé et qu'on n'a pas encore notifié
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _notifyContentReadyOnce());

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: widget.user.photoUrl != null
              ? NetworkImage(widget.user.photoUrl!)
              : null,
          child: widget.user.photoUrl == null &&
                  (widget.user.displayName.isNotEmpty)
              ? Text(widget.user.displayName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      fontSize: 36, color: ColorPalette.textAccent(context)))
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          widget.user.displayName,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: widget.user.bio != null && widget.user.bio!.isNotEmpty
              ? Text(
                  widget.user.bio!,
                  style: TextStyle(
                      fontSize: 14, color: ColorPalette.textSecondary(context)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : SizedBox(
                  height: 40,
                  child: Center(
                    child: Container(),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (widget.currentUser != null)
          SizedBox(
            height: 44,
            child: Center(
              child: ProfileAction(
                amitie: widget.friendship,
                user: widget.user,
                isMe: widget.isMe,
                currentUserId: widget.currentUser!.uid,
                onActionRequested: widget.isPerformingFriendAction
                    ? null
                    : widget.onActionRequested,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    if ((widget.isMe ||
                            canAccessPrivateInfos(
                                widget.friendship, widget.user)) &&
                        widget.currentUser != null &&
                        widget.isLoadingNbAmis == false &&
                        widget.userNbAmis != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FriendsPage(
                            currentUser: widget.currentUser!,
                            displayedUser: widget.user,
                            isMe: widget.isMe,
                          ),
                        ),
                      );
                    }
                  },
                  child: ProfileStatTile(
                    label: 'Amis',
                    labelHeight: statsLabelHeight,
                    valueWidget: widget.isLoadingNbAmis
                        ? const _ShimmerBox(width: 24, height: 12)
                        : Text(widget.userNbAmis?.toString() ?? '0',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.textPrimary(context))),
                  ),
                ),
              ),
            ),
            ProfileStatTile(
              label: 'Matchs',
              labelHeight: statsLabelHeight,
              valueWidget: widget.isLoadingNbMatchsRegardes
                  ? const _ShimmerBox(width: 24, height: 12)
                  : Text(widget.userNbMatchsRegardes?.toString() ?? '0',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.textPrimary(context))),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ProfileStatTile(
                  label: 'Buts',
                  labelHeight: statsLabelHeight,
                  valueWidget: widget.isLoadingNbButs
                      ? const _ShimmerBox(width: 24, height: 12)
                      : Text(widget.userNbButs?.toString() ?? '0',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.textPrimary(context))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HeaderShimmer extends StatelessWidget {
  const HeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer structure now mimics the final Header layout to avoid jumps.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: ColorPalette.shimmerPrimary(context),
        highlightColor: ColorPalette.shimmerSecondary(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // avatar centered
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorPalette.surface(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // name placeholder
            Container(
              width: 180,
              height: 22,
              color: ColorPalette.surface(context),
            ),
            const SizedBox(height: 6),
            // bio placeholder (reserve 2 lines)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: ColorPalette.surface(context),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: ColorPalette.surface(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // action placeholder (fixed height)
            Container(
              width: 160,
              height: 44,
              color: ColorPalette.surface(context),
            ),
            const SizedBox(height: 8),
            // stats placeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 64,
                  height: 40,
                  color: ColorPalette.surface(context),
                ),
                Container(
                  width: 64,
                  height: 40,
                  color: ColorPalette.surface(context),
                ),
                Container(
                  width: 64,
                  height: 40,
                  color: ColorPalette.surface(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorPalette.shimmerPrimary(context),
      highlightColor: ColorPalette.shimmerSecondary(context),
      child: Container(
        width: width,
        height: height,
        color: ColorPalette.surface(context),
      ),
    );
  }
}
