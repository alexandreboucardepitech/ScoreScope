// lib/widgets/match/match_tile.dart
import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/views/match_details.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/get_lignes_buteurs.dart';

class MatchTile extends StatefulWidget {
  final Match match;
  final MatchUserData? userData;

  const MatchTile({required this.match, this.userData, super.key});

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arrowAnim;
  late final Animation<double> _heightFactor;
  Joueur? _mvpJoueur;

  // simple shimmer controller for placeholders
  late final AnimationController _shimmerController;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _arrowAnim = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
    _heightFactor =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    if (widget.userData?.mvpVoteId != null) {
      _fetchMvpJoueur(widget.userData!.mvpVoteId!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchMvpJoueur(String joueurId) async {
    try {
      final joueur =
          await RepositoryProvider.joueurRepository.fetchJoueurById(joueurId);
      if (mounted) {
        setState(() {
          _mvpJoueur = joueur;
        });
      }
    } catch (_) {}
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(match: widget.match),
      ),
    );
  }

  List<Widget> _buildClickableButeurs(List<String> lines,
      {required bool alignRight}) {
    return lines.map((line) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Text(
          line,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 13,
            color: ColorPalette.textSecondary(context),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNoteBadge(int note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorPalette.buttonSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, size: 14),
          const SizedBox(width: 6),
          Text(
            '$note/10',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMvpBadge() {
    final joueur = _mvpJoueur;

    if (joueur == null) {
      return FadeTransition(
        opacity: Tween(begin: 0.4, end: 1.0).animate(_shimmerController),
        child: Container(
          width: 120,
          height: 28,
          decoration: BoxDecoration(
            color: ColorPalette.buttonSecondary(context),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorPalette.buttonSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // prend juste la taille nécessaire
        children: [
          Flexible(
            child: Text(
              joueur.fullName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.how_to_vote, size: 14),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final MatchUserData? userData = widget.userData;

    return Container(
      color: ColorPalette.tileBackground(context),
      child: Column(
        children: [
          Material(
            color: ColorPalette.tileBackground(context),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _navigateToDetails,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        children: [
                          // Logo ligue
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 16),
                            child: SizedBox(
                              width: 30,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.transparent,
                                child: Image.asset(
                                  'assets/competitions/ligue1.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          // Équipe domicile
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  match.equipeDomicile.nom,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),

                          // Score
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),

                          // Équipe extérieur
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  match.equipeExterieur.nom,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Flèche : uniquement elle contrôle l'expansion
                IconButton(
                  splashRadius: 20,
                  icon: RotationTransition(
                    turns: _arrowAnim,
                    child: const Icon(Icons.expand_more),
                  ),
                  onPressed: _toggleExpanded,
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: InkWell(
                onTap: _navigateToDetails,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _buildClickableButeurs(
                          getLignesButeurs(
                            buts: match.butsEquipeDomicile,
                            domicile: true,
                            fullName: false,
                          ),
                          alignRight: true,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 20, start: 20),
                      child: Icon(Icons.sports_soccer, size: 16),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildClickableButeurs(
                          getLignesButeurs(
                            buts: match.butsEquipeExterieur,
                            domicile: false,
                            fullName: false,
                          ),
                          alignRight: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (userData != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (userData.note != null) _buildNoteBadge(userData.note!),
                    const Spacer(),
                    if (userData.mvpVoteId != null) _buildMvpBadge(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
