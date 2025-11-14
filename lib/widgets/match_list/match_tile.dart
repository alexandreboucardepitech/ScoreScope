// lib/widgets/match/match_tile.dart
import 'package:flutter/material.dart';
import 'package:scorescope/utils/Color_palette.dart';
import 'package:scorescope/views/match_details.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/get_lignes_buteurs.dart';

class MatchTile extends StatefulWidget {
  final Match match;
  const MatchTile({required this.match, super.key});

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arrowAnim;
  late final Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _arrowAnim = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
    _heightFactor =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final match = widget.match;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: ColorPalette.secondary(context),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
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
                              padding:
                                  const EdgeInsetsDirectional.only(end: 16),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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

            // Contenu déroulé : animé. Les taps sur les enfants naviguent aussi.
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
          ],
        ),
      ),
    );
  }
}
