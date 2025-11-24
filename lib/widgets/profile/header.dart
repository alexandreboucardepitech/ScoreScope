import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/profile/profile_action.dart';
import 'package:scorescope/widgets/profile/stat_tile.dart';
import 'package:shimmer/shimmer.dart';

class Header extends StatelessWidget {
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
  final String? currentUserId;
  final bool isPerformingFriendAction;
  final void Function(String action)? onActionRequested;

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
    this.currentUserId,
    this.isPerformingFriendAction = false,
    this.onActionRequested,
  });

  @override
  Widget build(BuildContext context) {
    const double statsLabelHeight = 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child:
              user.photoUrl == null && (user.displayName?.isNotEmpty ?? false)
                  ? Text(user.displayName!.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          fontSize: 36,
                          color: ColorPalette.textAccent(context)))
                  : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName ?? 'Utilisateur',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
        ),
        const SizedBox(height: 6),
        if (user.bio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(user.bio!,
                style: TextStyle(
                    fontSize: 14, color: ColorPalette.textSecondary(context)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        const SizedBox(height: 10),
        ProfileAction(
          amitie: friendship,
          user: user,
          isMe: isMe,
          currentUserId: currentUserId,
          onActionRequested:
              isPerformingFriendAction ? null : onActionRequested,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ProfileStatTile(
                  label: 'Amis',
                  labelHeight: statsLabelHeight,
                  valueWidget: isLoadingNbAmis
                      ? const _ShimmerBox(width: 24, height: 12)
                      : Text(userNbAmis?.toString() ?? '0',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.textPrimary(context))),
                ),
              ),
            ),
            ProfileStatTile(
              label: 'Matchs',
              labelHeight: statsLabelHeight,
              valueWidget: isLoadingNbMatchsRegardes
                  ? const _ShimmerBox(width: 24, height: 12)
                  : Text(userNbMatchsRegardes?.toString() ?? '0',
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
                  valueWidget: isLoadingNbButs
                      ? const _ShimmerBox(width: 24, height: 12)
                      : Text(userNbButs?.toString() ?? '0',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.textPrimary(context))),
                ),
              ),
            ),
          ],
        ),
        Flexible(child: const SizedBox(height: 160)),
      ],
    );
  }
}

class HeaderShimmer extends StatelessWidget {
  const HeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: ColorPalette.shimmerPrimary(context),
        highlightColor: ColorPalette.shimmerSecondary(context),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorPalette.surface(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: ColorPalette.surface(context),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 150,
                        color: ColorPalette.surface(context),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 62,
                            height: 40,
                            color: ColorPalette.surface(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 62,
                            height: 40,
                            color: ColorPalette.surface(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 62,
                            height: 40,
                            color: ColorPalette.surface(context),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
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
