import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class VisionnageMatchCard extends StatefulWidget {
  final MatchModel match;
  final ValueChanged<VisionnageMatch>? onSelected;

  const VisionnageMatchCard({
    super.key,
    required this.match,
    this.onSelected,
  });

  @override
  State<VisionnageMatchCard> createState() => _VisionnageMatchCardState();
}

class _VisionnageMatchCardState extends State<VisionnageMatchCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController;
  bool _loading = true;
  bool _isSaving = false;
  VisionnageMatch _currentType = VisionnageMatch.tele;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _loadTypeVisionnage();
  }

  @override
  void didUpdateWidget(covariant VisionnageMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le match.id change, réinitialiser l'affichage et recharger la valeur depuis la BDD
    if (widget.match.id != oldWidget.match.id) {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _isSaving = false;
        _currentType = VisionnageMatch.tele; // valeur par défaut temporaire
      });
      _loadTypeVisionnage();
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  Future<void> _loadTypeVisionnage() async {
    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _currentType = VisionnageMatch.tele;
        });
        return;
      }

      VisionnageMatch? res = await RepositoryProvider.userRepository
          .getVisionnageMatch(currentUser.uid, widget.match.id);

      if (!mounted) return;
      setState(() {
        _currentType = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _currentType = VisionnageMatch.tele;
      });
    }
  }

  Future<void> _handleTap() async {
    final choix =
        await showVisionnageSelectionDialog(context, initial: _currentType);

    if (choix == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final AppUser? currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();

      if (currentUser == null) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Impossible de récupérer l'utilisateur.")),
        );
        return;
      }

      await RepositoryProvider.userRepository.setVisionnageMatch(
        widget.match.id,
        currentUser.uid,
        widget.match.date,
        choix,
      );

      if (!mounted) return;

      setState(() {
        _currentType = choix;
        _isSaving = false;
      });

      widget.onSelected?.call(choix);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Échec de la sauvegarde — réessaye plus tard.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visionnage',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: _loading
                  ? FadeTransition(
                      opacity: Tween(begin: 0.4, end: 1.0)
                          .animate(_shimmerController!),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ColorPalette.buttonSecondary(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 90,
                            color: ColorPalette.opposite(context)
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 64,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorPalette.buttonSecondary(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentType.emoji,
                            style: const TextStyle(fontSize: 44),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 90,
                            color: ColorPalette.opposite(context)
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _currentType.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: 260,
      height: 140,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: (_loading || _isSaving) ? null : _handleTap,
              child: card,
            ),
          ),
          if (_isSaving)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      ColorPalette.background(context).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<VisionnageMatch?> showVisionnageSelectionDialog(BuildContext context,
    {VisionnageMatch? initial}) {
  return showDialog<VisionnageMatch>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Choisir le mode de visionnage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(null),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: VisionnageMatch.values.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: ColorPalette.divider(context),
                    ),
                  ),
                  itemBuilder: (context, i) {
                    final VisionnageMatch v = VisionnageMatch.values[i];
                    final bool selected = v == initial;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? ColorPalette.tileSelected(context)
                              : Colors.transparent,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(v),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: ColorPalette.accent(context)
                                .withValues(alpha: 0.12),
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: ColorPalette.highlight(context),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      v.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      v.label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            ColorPalette.textPrimary(context),
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    Icon(Icons.check_circle,
                                        color: ColorPalette.accent(context))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
