import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/string/display_score_or_match_date.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/views/details/match_details_page.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/get_lignes_buteurs.dart';
import 'package:scorescope/views/details/player_details_page.dart';

class MatchTile extends StatefulWidget {
  final MatchModel match;
  final MatchUserData? userData;
  final AppUser? user;
  final bool displayUserData;

  const MatchTile({
    required this.match,
    this.userData,
    this.user,
    this.displayUserData = false,
    super.key,
  });

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arrowAnim;
  late final Animation<double> _heightFactor;
  Joueur? _mvpJoueur;

  late final AnimationController _shimmerController;

  bool _isExpanded = false;

  MatchUserData? userData;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _arrowAnim = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
    _heightFactor =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    if (userData?.mvpVoteId != null) {
      _fetchMvpJoueur(userData!.mvpVoteId!);
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

  void _toggleNotifications(bool value) async {
    if (userData != null) {
      MatchUserData newUserData = MatchUserData(
        matchId: userData!.matchId,
        comments: userData!.comments,
        favourite: userData!.favourite,
        matchDate: userData!.matchDate,
        mvpVoteId: userData!.mvpVoteId,
        note: userData!.note,
        notifications: value,
        private: userData!.private,
        reactions: userData!.reactions,
        visionnageMatch: userData!.visionnageMatch,
        watchedAt: userData!.watchedAt,
      );
      setState(() {
        userData = newUserData;
      });
    } else {
      setState(() {
        userData = MatchUserData(
          matchId: widget.match.id,
          notifications: value,
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications ${value ? 'activées' : 'désactivées'} pour ${widget.match.equipeDomicile.nomCourt ?? widget.match.equipeDomicile.nom} - ${widget.match.equipeExterieur.nomCourt ?? widget.match.equipeExterieur.nom}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    AppUser? currentUser = RepositoryProvider.userRepository.currentUser;
    if (currentUser != null) {
      await RepositoryProvider.userRepository.updateMatchNotifications(
        matchId: widget.match.id,
        userId: currentUser.uid,
        matchDate: widget.match.date,
        activateNotifications: value,
      );
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

  List<Widget> _buildClickableButeurs(List<ButeurLine> lines,
      {required bool alignRight}) {
    return lines.map((line) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PlayerDetailsPage(playerId: line.joueur.id),
              ),
            );
          },
          child: Text(
            line.nomJoueur,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: 13,
              color: ColorPalette.textSecondary(context),
            ),
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
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildAdaptiveTeamName(
    BuildContext context, {
    required String nomComplet,
    required String? nomCourt,
    required bool isWinner,
    required TextAlign align,
  }) {
    final textColor = isWinner
        ? ColorPalette.textAccent(context)
        : ColorPalette.textPrimary(context);

    final TextStyle baseStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: nomComplet, style: baseStyle),
          maxLines: 2,
          textDirection: ui.TextDirection.ltr,
          textAlign: align,
          textScaler: MediaQuery.of(context).textScaler,
        )..layout(maxWidth: constraints.maxWidth);

        final metrics = textPainter.computeLineMetrics();
        bool isUglyWrap = false;

        if (metrics.length > 1) {
          final endOfFirstLine =
              textPainter.getLineBoundary(const TextPosition(offset: 0)).end;
          if (endOfFirstLine <= 3) {
            isUglyWrap = true;
          }
        }

        final bool fitsComfortably =
            (textPainter.width * 1.1) <= constraints.maxWidth;

        if (!isUglyWrap && fitsComfortably) {
          return Text(
            nomComplet,
            textAlign: align,
            maxLines: 2,
            style: baseStyle,
          );
        }

        if (nomCourt != null) {
          return Text(
            nomCourt,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: baseStyle,
          );
        }

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: align == TextAlign.end
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Text(
            nomComplet,
            style: baseStyle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;

    final bool displayScore = match.status == MatchStatus.live ||
        match.status == MatchStatus.finished;

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
                          horizontal: 12.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ColorPalette.accentVariant(context),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.network(
                                match.competition.logoUrl ??
                                    'https://media.api-sports.io/football/leagues/1.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    CircleAvatar(
                                  radius: 14,
                                  child: Icon(Icons.emoji_events, size: 16),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: _buildAdaptiveTeamName(
                                    context,
                                    nomComplet: match.equipeDomicile.nom,
                                    nomCourt: match.equipeDomicile.nomCourt,
                                    isWinner: match.scoreEquipeDomicile >
                                        match.scoreEquipeExterieur,
                                    align: TextAlign.end,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                buildTeamLogo(
                                  context,
                                  match.equipeDomicile.logoPath,
                                  equipeId: match.equipeDomicile.id,
                                  size: 28,
                                  clickable: false,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: displayScore ? 0.0 : 8.0,
                            ),
                            child: Container(
                              width: 44,
                              alignment: Alignment.center,
                              child: Text(
                                displayScoreOrMatchDate(match),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: ColorPalette.textPrimary(context),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildTeamLogo(
                                  context,
                                  match.equipeExterieur.logoPath,
                                  equipeId: match.equipeExterieur.id,
                                  size: 28,
                                  clickable: false,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: _buildAdaptiveTeamName(
                                    context,
                                    nomComplet: match.equipeExterieur.nom,
                                    nomCourt: match.equipeExterieur.nomCourt,
                                    isWinner: match.scoreEquipeExterieur >
                                        match.scoreEquipeDomicile,
                                    align: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (match.isScheduled)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => _toggleNotifications(
                        !(userData?.notifications ?? false),
                      ),
                      child: Icon(
                        userData?.notifications ?? false
                            ? Icons.notifications_active
                            : Icons.notifications_outlined,
                        color: ColorPalette.accent(context),
                      ),
                    ),
                  )
                else
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
                    if (match.scoreEquipeDomicile > 0 ||
                        match.scoreEquipeExterieur > 0)
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
          if (userData != null && widget.displayUserData)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (userData!.note != null)
                      _buildNoteBadge(userData!.note!),
                    const Spacer(),
                    if (userData!.mvpVoteId != null) _buildMvpBadge(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
