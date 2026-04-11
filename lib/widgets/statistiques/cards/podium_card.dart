import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/show_podium_details_popup.dart';

class PodiumCard<T> extends StatelessWidget {
  final String title;
  final List<PodiumEntry> items;
  final AppUser user;
  final String emptyStateText;
  final bool logoBackground;

  const PodiumCard({
    super.key,
    required this.title,
    required this.items,
    required this.user,
    this.emptyStateText = 'Aucune donnée disponible',
    this.logoBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        int nbMatchsRegardes = await RepositoryProvider.userRepository
            .getUserNbMatchsRegardes(user.uid,
                user.uid != RepositoryProvider.userRepository.currentUser?.uid);
        return showPodiumDetailsPopup(
          context: context,
          title: title,
          watchedMatchesCount: nbMatchsRegardes,
          entries: items,
          user: user,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.tileBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorPalette.border(context)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 4),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: ColorPalette.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    if (items.length == 1) {
      return _buildSingle(context, items.first, true, logoBackground);
    }

    if (items.length == 2) {
      return _buildDuo(context, items.take(2).toList(), logoBackground);
    }

    return _buildPodium(context, items.take(3).toList(), logoBackground);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: ColorPalette.accent(context),
            ),
            Text(
              emptyStateText,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingle(
    BuildContext context,
    PodiumEntry podiumEntry,
    bool large,
    bool logoBackground,
  ) {
    final content = InkWell(
      child: podiumEntry.item.buildPodiumCard(
        context: context,
        podium: PodiumContext(
          rank: 1,
          value: podiumEntry.value,
          color: podiumEntry.color,
        ),
        logoBackground: logoBackground,
      ),
    );

    if (large) {
      return Expanded(
        child: Center(child: content),
      );
    }

    return content;
  }

  Widget _buildDuo(
    BuildContext context,
    List<PodiumEntry> duo,
    bool logoBackground,
  ) {
    return Column(
      children: [
        InkWell(
          child: duo[0].item.buildPodiumCard(
                context: context,
                podium: PodiumContext(
                  rank: 1,
                  value: duo[0].value,
                  color: duo[0].color,
                ),
                logoBackground: logoBackground,
              ),
        ),
        Divider(color: ColorPalette.border(context)),
        InkWell(
          child: duo[1].item.buildPodiumCard(
                context: context,
                podium: PodiumContext(
                  rank: 2,
                  value: duo[1].value,
                  color: duo[1].color,
                ),
                logoBackground: logoBackground,
              ),
        ),
      ],
    );
  }

  Widget _buildPodium(
    BuildContext context,
    List<PodiumEntry> podium,
    bool logoBackground,
  ) {
    return Column(
      children: [
        InkWell(
          child: podium[0].item.buildPodiumCard(
                context: context,
                podium: PodiumContext(
                  rank: 1,
                  value: podium[0].value,
                  color: podium[0].color,
                ),
                logoBackground: logoBackground,
              ),
        ),
        Divider(
          color: ColorPalette.border(context),
          height: 12,
        ),
        InkWell(
          child: podium[1].item.buildPodiumCard(
                context: context,
                podium: PodiumContext(
                  rank: 2,
                  value: podium[1].value,
                  color: podium[1].color,
                ),
                logoBackground: logoBackground,
              ),
        ),
        if (podium.length > 2)
          InkWell(
            child: podium[2].item.buildPodiumCard(
                  context: context,
                  podium: PodiumContext(
                    rank: 3,
                    value: podium[2].value,
                    color: podium[2].color,
                  ),
                  logoBackground: logoBackground,
                ),
          ),
      ],
    );
  }
}
