import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/slider_degrade_couleur.dart';

Color getThumbColor(double value) {
  final t = value / 10; // normalise 0..1
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
  final ValueChanged<int>? onChanged;
  final ValueChanged<int?>? onConfirm;

  MatchRatingCard({
    super.key,
    required this.noteMoyenne,
    this.userVote,
    this.onChanged,
    this.onConfirm,
  });

  @override
  State<MatchRatingCard> createState() => _MatchRatingCardState();
}

class _MatchRatingCardState extends State<MatchRatingCard> {
  late int? _rating;
  double get ratingDouble => (_rating ?? 0).toDouble();
  final List<String> emojis = [
    '😴',
    '🥶',
    '😵‍💫',
    '😬',
    '😐',
    '🙂',
    '😎',
    '🫣',
    '🥵',
    '🤩',
    '🤯'
  ];

  @override
  void initState() {
    super.initState();
    _rating = widget.userVote;
  }

  void _updateFromDouble(double value) {
    final int intValue = value.round();
    setState(() => _rating = intValue);
    widget.onChanged?.call(intValue);
  }

  @override
  void didUpdateWidget(covariant MatchRatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userVote != widget.userVote) {
      setState(() {
        _rating = widget.userVote;
      });
    }
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
                                  enabledThumbRadius: 10),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 20),
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
                          )),
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

                // Bloc avec valeur (grand) à droite
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
                      _rating != null ? emojis[_rating!] : '-',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _rating != null
                              ? ColorPalette.textPrimary(context)
                              : ColorPalette.textSecondary(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Partie gauche : note moyenne
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
                    widget.onChanged?.call(0);
                  },
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
                    backgroundColor: ColorPalette.buttonSecondary(context),
                  ),
                  onPressed: () => widget.onConfirm?.call(_rating),
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
