import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/string/build_adaptative_team_name.dart';
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

  Widget _buildTrailing(BuildContext context) {
    final match = widget.match;

    Widget content;

    if (match.isScheduled) {
      content = InkWell(
        onTap: () => _toggleNotifications(
          !(userData?.notifications ?? false),
        ),
        child: Icon(
          userData?.notifications ?? false
              ? Icons.notifications_active
              : Icons.notifications_outlined,
          color: ColorPalette.accent(context),
          size: 20,
        ),
      );
    } else if (match.isLive && match.liveMinute != null) {
      content = InkWell(
        splashColor: Colors.transparent,
        onTap: _navigateToDetails,
        child: Text(
          "${match.liveMinute!}'",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorPalette.accent(context),
            fontSize: 13,
          ),
        ),
      );
    } else {
      content = RotationTransition(
        turns: _arrowAnim,
        child: InkWell(
          splashColor: Colors.transparent,
          onTap: _toggleExpanded,
          child: Icon(
            Icons.expand_more,
            color: ColorPalette.accent(context),
            size: 22,
          ),
        ),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(child: content),
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
                                color: ColorPalette.logoBackground(context),
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
                                  child: buildAdaptiveTeamName(
                                    context,
                                    nomComplet: match.equipeDomicile.nom,
                                    nomCourt: match.equipeDomicile.nomCourt,
                                    isWinner: match.scoreEquipeDomicile >
                                        match.scoreEquipeExterieur,
                                    isLive: match.isLive,
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
                                  child: buildAdaptiveTeamName(
                                    context,
                                    nomComplet: match.equipeExterieur.nom,
                                    nomCourt: match.equipeExterieur.nomCourt,
                                    isWinner: match.scoreEquipeExterieur >
                                        match.scoreEquipeDomicile,
                                    isLive: match.isLive,
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
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildTrailing(context),
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
