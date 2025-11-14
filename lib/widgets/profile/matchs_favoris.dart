import 'package:flutter/material.dart';
import 'package:scorescope/utils/Color_palette.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';

class MatchsFavoris extends StatelessWidget {
  final List<String>? matchsFavorisId;
  final bool isLoading;

  const MatchsFavoris(
      {super.key, required this.matchsFavorisId, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // On affiche juste un MatchList vide pour déclencher les placeholders/shimmer
      return const SizedBox(
        height: 88 * 3, // placeholder pour 3 tiles verticales
        child: MatchList(ids: []),
      );
    }

    final ids = matchsFavorisId ?? [];
    if (ids.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matchs favoris',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        MatchList(
          ids: ids,
        ),
      ],
    );
  }
}
