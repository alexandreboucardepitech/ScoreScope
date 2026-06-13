import 'package:flutter/material.dart';
import 'package:scorescope/utils/string/get_reaction_emoji.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
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
  final void Function(bool hasUnsaved, int? currentRating)? onUnsavedChanged;

  const MatchRatingCard({
    super.key,
    required this.noteMoyenne,
    this.userVote,
    this.noteCount,
    this.noteMin,
    this.noteMax,
    this.onCancelled,
    this.onConfirm,
    this.onUnsavedChanged,
  });

  @override
  State<MatchRatingCard> createState() => _MatchRatingCardState();
}

class _MatchRatingCardState extends State<MatchRatingCard> {
  int? _rating;

  double get ratingDouble => (_rating ?? 0).toDouble();

  bool get _hasUnsavedChange => _rating != widget.userVote;
  bool get _isAlreadyVoted => widget.userVote != null;
  bool get _isConfirmed => _isAlreadyVoted && !_hasUnsavedChange;

  bool get _canConfirm => _rating != null;

  bool get _hasStats =>
      widget.noteMoyenne != -1 ||
      widget.noteMin != null ||
      widget.noteMax != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.userVote;
  }

  @override
  void didUpdateWidget(covariant MatchRatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userVote != oldWidget.userVote) {
      setState(() => _rating = widget.userVote);
    }
  }

  void _updateFromDouble(double value) {
    setState(() => _rating = value.round());
    widget.onUnsavedChanged?.call(_hasUnsavedChange, _rating);
  }

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
                  translate.noteDuMatch,
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
                      translate.xVoteX(widget.noteCount!.toString(),
                          (widget.noteCount! > 1) ? 's' : ''),
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
                    color: _rating != null
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
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_hasStats) ...[
                  _buildStatChip(
                    context,
                    translate.moyenne,
                    widget.noteMoyenne != -1
                        ? widget.noteMoyenne.toStringAsPrecision(3)
                        : '—',
                    placeholder: widget.noteMoyenne == -1,
                  ),
                  if (widget.noteMin != null) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(context, translate.min, '${widget.noteMin}'),
                  ],
                  if (widget.noteMax != null) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(context, translate.max, '${widget.noteMax}'),
                  ],
                ],
                const Spacer(),
                IconButton(
                  onPressed: (_rating != null || _isAlreadyVoted)
                      ? () {
                          setState(() => _rating = null);
                          widget.onCancelled?.call(true);
                        }
                      : null,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: (_rating != null || _isAlreadyVoted)
                        ? ColorPalette.textSecondary(context)
                        : ColorPalette.textSecondary(context)
                            .withValues(alpha: 0.3),
                  ),
                  tooltip: translate.effacerMaNote,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                if (_isConfirmed)
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: Text(translate.note2),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.accent(context),
                      disabledForegroundColor: ColorPalette.accent(context),
                      side: BorderSide(
                        color:
                            ColorPalette.accent(context).withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  GradientButton(
                    onPressed: _canConfirm
                        ? () {
                            widget.onConfirm?.call(_rating);
                            widget.onUnsavedChanged?.call(false, _rating);
                          }
                        : null,
                    icon: _isAlreadyVoted ? Icons.refresh : Icons.check_rounded,
                    label: translate.valider,
                  ),
              ],
            ),
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
              translate.noteDuMatch,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatChip(context, translate.moyenne, '—',
                    placeholder: true),
                const SizedBox(width: 8),
                _buildStatChip(context, translate.min, '—', placeholder: true),
                const SizedBox(width: 8),
                _buildStatChip(context, translate.max, '—', placeholder: true),
                const Spacer(),
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: ColorPalette.textSecondary(context)
                        .withValues(alpha: 0.3),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                GradientButton(
                  onPressed: null,
                  icon: Icons.check_rounded,
                  label: translate.valider,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
