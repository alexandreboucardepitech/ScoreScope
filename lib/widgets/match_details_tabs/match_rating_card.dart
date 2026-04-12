import 'package:flutter/material.dart';
import 'package:scorescope/utils/string/get_reaction_emoji.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/slider_degrade_couleur.dart';

Color getThumbColor(double value) {
  final t = value / 10;
  final gradientColors = [
    Colors.blue.shade300,
    Colors.cyan,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red.shade400,
  ];
  final n = gradientColors.length - 1;
  final segment = (t * n).floor().clamp(0, n - 1);
  final localT = (t * n) - segment;
  return Color.lerp(
      gradientColors[segment], gradientColors[segment + 1], localT)!;
}

class MatchRatingCard extends StatefulWidget {
  final double noteMoyenne;
  final int? userVote;
  final ValueChanged<bool>? onCancelled;
  final ValueChanged<int?>? onConfirm;

  const MatchRatingCard({
    super.key,
    required this.noteMoyenne,
    this.userVote,
    this.onCancelled,
    this.onConfirm,
  });

  @override
  State<MatchRatingCard> createState() => _MatchRatingCardState();
}

class _MatchRatingCardState extends State<MatchRatingCard> {
  int? _rating;

  double get ratingDouble => (_rating ?? 0).toDouble();

  @override
  void initState() {
    super.initState();
    _rating = widget.userVote;
  }

  void _updateFromDouble(double value) {
    final int intValue = value.round();
    setState(() => _rating = intValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note du match',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, right: 5.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20,
                            ),
                            thumbColor: getThumbColor(ratingDouble),
                            trackShape: SliderDegradeCouleur(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.cyan,
                                  Colors.green,
                                  Colors.yellow,
                                  Colors.orange,
                                  Colors.red.shade400,
                                ],
                              ),
                              inactiveColor: Colors.grey.shade300,
                            ),
                          ),
                          child: Slider(
                            value: ratingDouble,
                            min: 0,
                            max: 10,
                            divisions: 10,
                            onChanged: _updateFromDouble,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(11, (i) {
                          final isSelected = _rating == i;
                          return Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: isSelected
                                  ? ColorPalette.accent(context)
                                  : Colors.grey.shade600,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (_rating != null)
                        ? ColorPalette.surface(context).withValues(alpha: 0.8)
                        : ColorPalette.surface(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _rating != null ? getReactionEmoji(_rating!) : '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _rating != null
                            ? ColorPalette.textPrimary(context)
                            : ColorPalette.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.noteMoyenne != -1)
                  Text(
                    'Note moyenne : ${widget.noteMoyenne.toStringAsPrecision(3)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorPalette.textAccent(context),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _rating = null);
                    widget.onCancelled?.call(true);
                  },
                  child: Text(
                    'Vider',
                    style: TextStyle(
                      color: ColorPalette.textSecondary(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.buttonSecondary(context),
                  ),
                  onPressed: () {
                    widget.onConfirm?.call(_rating);
                  },
                  child: Text(
                    'Valider',
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MatchRatingCardShimmer extends StatefulWidget {
  const MatchRatingCardShimmer({
    super.key,
  });

  @override
  State<MatchRatingCardShimmer> createState() => _MatchRatingCardShimmerState();
}

class _MatchRatingCardShimmerState extends State<MatchRatingCardShimmer> {
  final int? _rating = null;

  double get ratingDouble => (_rating ?? 0).toDouble();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note du match',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, right: 5.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20,
                            ),
                            thumbColor: getThumbColor(ratingDouble),
                            trackShape: SliderDegradeCouleur(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.cyan,
                                  Colors.green,
                                  Colors.yellow,
                                  Colors.orange,
                                  Colors.red.shade400,
                                ],
                              ),
                              inactiveColor: Colors.grey.shade300,
                            ),
                          ),
                          child: Slider(
                            value: 0,
                            min: 0,
                            max: 10,
                            divisions: 10,
                            onChanged: null,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(11, (i) {
                          final isSelected = _rating == i;
                          return Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: isSelected
                                  ? ColorPalette.accent(context)
                                  : Colors.grey.shade600,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (_rating != null)
                        ? ColorPalette.surface(context).withValues(alpha: 0.8)
                        : ColorPalette.surface(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorPalette.accent(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: null,
                  child: Text(
                    'Vider',
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.buttonDisabled(context),
                  ),
                  onPressed: null,
                  child: Text(
                    'Valider',
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
