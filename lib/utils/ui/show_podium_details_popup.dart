import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/widgets/statistiques/podium_detail_popup.dart';

void showPodiumDetailsPopup<T extends PodiumDisplayable>({
  required BuildContext context,
  required String title,
  required int watchedMatchesCount,
  required List<PodiumEntry<T>> entries,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Center(
        child: PodiumDetailsPopup<T>(
          title: title,
          watchedMatchesCount: watchedMatchesCount,
          entries: entries,
        ),
      );
    },
  );
}
