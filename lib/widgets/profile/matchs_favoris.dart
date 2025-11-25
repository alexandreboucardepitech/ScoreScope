import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';

class MatchsFavoris extends StatelessWidget {
  final List<String>? matchsFavorisId;
  final bool isLoading;
  final VoidCallback? onVoirPlus;

  const MatchsFavoris({
    super.key,
    required this.matchsFavorisId,
    this.isLoading = false,
    this.onVoirPlus,
  });
  @override
  Widget build(BuildContext context) {
    final ids = matchsFavorisId ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        if (isLoading)
          _buildShimmer(context)
        else if (ids.isEmpty)
          _buildEmptyMessage(context, "Aucun match favori")
        else
          MatchList(ids: ids),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Matchs favoris',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onVoirPlus,
          child: Text(
            'Voir plus',
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessage(BuildContext context, String msg) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border,
                size: 32, color: ColorPalette.textSecondary(context)),
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // titre shimmer
        Shimmer.fromColors(
          baseColor: ColorPalette.shimmerPrimary(context),
          highlightColor: ColorPalette.shimmerSecondary(context),
          child: Container(
            height: 18,
            width: 140,
            margin: const EdgeInsets.only(bottom: 8),
            color: ColorPalette.surface(context),
          ),
        ),
        // 3 tuiles shimmer
        Shimmer.fromColors(
          baseColor: ColorPalette.shimmerPrimary(context),
          highlightColor: ColorPalette.shimmerSecondary(context),
          child: Column(
            children: List.generate(
              3,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: _MatchShimmerTile(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchShimmerTile extends StatelessWidget {
  const _MatchShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
              width: 48, height: 48, color: ColorPalette.surface(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, color: ColorPalette.surface(context)),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 100,
                  color: ColorPalette.surface(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
