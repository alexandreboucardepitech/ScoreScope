import 'package:flutter/material.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/fil_actu_amis/match_regarde_ami_card.dart';

class MatchRegardeAmiListView extends StatelessWidget {
  final List<MatchRegardeAmi> entries;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final bool matchDetails;

  const MatchRegardeAmiListView({
    super.key,
    required this.entries,
    this.shrinkWrap = true,
    this.padding,
    this.onRefresh,
    this.matchDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined,
                size: 64, color: ColorPalette.pictureBackground(context)),
            const SizedBox(height: 12),
            Text(
              "Aucun ami n'a vu ce match.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    final list = ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding ?? EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return MatchRegardeAmiCard(entry: entry, matchDetails: matchDetails);
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: list,
      );
    } else {
      return list;
    }
  }
}
