import 'package:flutter/material.dart';
import 'package:scorescope/utils/string/get_reaction_emoji.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/gradient_button.dart';
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

Widget _buildStatChip(
  BuildContext context,
  String label,
  String value, {
  bool placeholder = false,
  IconData? icon,
}) {
  final accent = ColorPalette.accent(context);
  final borderColor = placeholder
      ? ColorPalette.textSecondary(context).withValues(alpha: 0.25)
      : accent;
  final iconColor = placeholder ? ColorPalette.textSecondary(context) : accent;
  final bgColor = placeholder
      ? ColorPalette.surface(context)
      : accent.withValues(alpha: 0.07);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border(
        left: BorderSide(color: borderColor, width: 2.5),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: placeholder
                    ? ColorPalette.textSecondary(context)
                    : iconColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: placeholder
                    ? ColorPalette.textSecondary(context)
                    : ColorPalette.textPrimary(context),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class MatchRatingCard extends StatefulWidget {
  final double noteMoyenne;
  final int? userVote;

  final int? noteCount;

  final int? noteMin;

  final int? noteMax;

  final ValueChanged<bool>? onCancelled;
  final ValueChanged<int?>? onConfirm;

  const MatchRatingCard({
    super.key,
    required this.noteMoyenne,
    this.userVote,
    this.noteCount,
    this.noteMin,
    this.noteMax,
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
    setState(() => _rating = value.round());
  }

  bool get _hasStats =>
      widget.noteMoyenne != -1 ||
      widget.noteMin != null ||
      widget.noteMax != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasVoteCount = widget.noteCount != null && widget.noteCount! > 0;

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Note du match',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
                const Spacer(),
                if (hasVoteCount)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          ColorPalette.accent(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.noteCount} vote${widget.noteCount! > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.accent(context),
                      ),
                    ),
                  ),
              ],
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
            if (_hasStats) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (widget.noteMoyenne != -1)
                    _buildStatChip(
                      context,
                      'Moyenne',
                      widget.noteMoyenne.toStringAsPrecision(3),
                    ),
                  if (widget.noteMin != null) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(context, 'Min', '${widget.noteMin}'),
                  ],
                  if (widget.noteMax != null) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(context, 'Max', '${widget.noteMax}'),
                  ],
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() => _rating = null);
                      widget.onCancelled?.call(true);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: ColorPalette.accent(context),
                    ),
                  ),
                  GradientButton(
                    onPressed: () => widget.onConfirm?.call(_rating),
                    icon: Icons.check_rounded,
                    label: 'Valider',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MatchRatingCardShimmer extends StatelessWidget {
  const MatchRatingCardShimmer({super.key});

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
                            thumbColor: getThumbColor(0),
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
                          return Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
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
                    color: ColorPalette.surface(context),
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
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatChip(context, 'Moyenne', '—', placeholder: true),
                const SizedBox(width: 8),
                _buildStatChip(context, 'Min', '—', placeholder: true),
                const SizedBox(width: 8),
                _buildStatChip(context, 'Max', '—', placeholder: true),
                Spacer(),
                GradientButton(
                  onPressed: null,
                  icon: Icons.check_rounded,
                  label: 'Valider',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 15,
                    color: ColorPalette.accent(context),
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
