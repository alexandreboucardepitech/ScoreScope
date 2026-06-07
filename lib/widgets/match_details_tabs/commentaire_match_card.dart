import 'package:flutter/material.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/gradient_button.dart';

class CommentaireMatchCard extends StatefulWidget {
  final String? commentaireInitial;
  final Future<void> Function(String commentaire) onSave;
  final Future<void> Function() onDelete;

  const CommentaireMatchCard({
    super.key,
    required this.commentaireInitial,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<CommentaireMatchCard> createState() => _CommentaireMatchCardState();
}

class _CommentaireMatchCardState extends State<CommentaireMatchCard> {
  static const int _maxLength = 140;

  late final TextEditingController _controller;
  bool _isFocused = false;
  bool _isSaving = false;

  bool get _hasCommentaire =>
      widget.commentaireInitial != null &&
      widget.commentaireInitial!.isNotEmpty;

  bool get _hasUnsavedChange =>
      _controller.text.trim() != (widget.commentaireInitial ?? '');

  bool get _canPublish =>
      _controller.text.trim().isNotEmpty && _hasUnsavedChange;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.commentaireInitial ?? '');
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant CommentaireMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.commentaireInitial != oldWidget.commentaireInitial) {
      if (!_hasUnsavedChange) {
        _controller.text = widget.commentaireInitial ?? '';
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSaving = true);
    await widget.onSave(text);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isFocused = false;
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          translate.supprimerLeCommentaire,
          style: TextStyle(
            color: ColorPalette.textAccent(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          translate.voulezVousSupprimerVotreCommentaire,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              translate.annuler,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              translate.supprimer,
              style: TextStyle(
                color: ColorPalette.textAccent(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isSaving = true);
    await widget.onDelete();
    if (!mounted) return;
    _controller.clear();
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = ColorPalette.accent(context);
    final remaining = _maxLength - _controller.text.trim().length;
    final isOverLimit = remaining < 0;

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate.monCommentaire,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.textPrimary(context),
                  ),
            ),
            const SizedBox(height: 10),
            Focus(
              onFocusChange: (hasFocus) =>
                  setState(() => _isFocused = hasFocus),
              child: TextField(
                controller: _controller,
                maxLines: null,
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: translate.quAstuPenseDeCeMatch,
                  hintStyle: TextStyle(
                    color: ColorPalette.textSecondary(context),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: ColorPalette.surface(context),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: _isFocused
                      ? null
                      : Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: ColorPalette.textSecondary(context)
                              .withValues(alpha: 0.6),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: accent, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_isFocused) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverLimit
                        ? Colors.redAccent
                        : ColorPalette.textSecondary(context),
                    fontWeight:
                        isOverLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (_hasCommentaire) ...[
                  IconButton(
                    onPressed: _isSaving ? null : _confirmDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: _isSaving
                          ? ColorPalette.textSecondary(context)
                              .withValues(alpha: 0.3)
                          : ColorPalette.textSecondary(context),
                    ),
                    tooltip: translate.supprimerLeCommentaire,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 4),
                ],
                const Spacer(),
                if (_isSaving)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                else if (_canPublish)
                  GradientButton(
                    onPressed: _save,
                    icon: Icons.check_rounded,
                    label:
                        _hasCommentaire ? translate.valider : translate.publier,
                  )
                else
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: Icon(
                      _hasCommentaire
                          ? Icons.edit_outlined
                          : Icons.check_rounded,
                      size: 15,
                    ),
                    label: Text(
                      _hasCommentaire ? translate.valider : translate.publier,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.textSecondary(context),
                      disabledForegroundColor:
                          ColorPalette.textSecondary(context)
                              .withValues(alpha: 0.4),
                      side: BorderSide(
                        color: ColorPalette.textSecondary(context)
                            .withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
