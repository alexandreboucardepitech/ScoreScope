import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/date/get_date_format.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/search/search_page_state.dart';
import 'package:scorescope/utils/string/build_adaptative_team_name.dart';
import 'package:scorescope/utils/string/display_score_or_match_date.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/display_prolongations_penaltys.dart';
import 'package:scorescope/views/details/match_details_page.dart';
import 'package:scorescope/views/details/player_details_page.dart';
import 'package:scorescope/views/details/team_details_page.dart';
import 'package:scorescope/widgets/recherche/resultats_section.dart';

class ResultatsRecherche extends StatelessWidget {
  final ResultatsRechercheModel resultats;

  final SearchPageState? pageState;

  final String? loadingSection;

  final void Function(String section)? onLoadMore;

  const ResultatsRecherche({
    super.key,
    required this.resultats,
    this.pageState,
    this.loadingSection,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        ResultatsSection<Equipe>(
          title: translate.equipes,
          items: resultats.equipes,
          hasMore: pageState?.hasMoreEquipes ?? false,
          isLoadingMore: loadingSection == translate.equipes,
          onLoadMore: () => onLoadMore?.call(translate.equipes),
          itemBuilder: (equipe) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: buildTeamLogo(
              context,
              equipe.logoPath,
              equipeId: equipe.id,
            ),
            title: Text(
              equipe.nom,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamDetailsPage(teamId: equipe.id),
                ),
              );
            },
          ),
        ),
        ResultatsSection<MatchModel>(
          title: translate.matchs,
          items: resultats.matchs,
          itemBuilder: (match) => _MatchSearchTile(match: match),
          hasMore: pageState?.hasMoreMatchs ?? false,
          isLoadingMore: loadingSection == translate.matchs,
          onLoadMore: () => onLoadMore?.call(translate.matchs),
        ),
        ResultatsSection<Competition>(
          title: translate.competitions,
          items: resultats.competitions,
          hasMore: pageState?.hasMoreCompetitions ?? false,
          isLoadingMore: loadingSection == translate.competitions,
          onLoadMore: () => onLoadMore?.call(translate.competitions),
          itemBuilder: (competition) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: competition.logoUrl != null
                ? Container(
                    width: 32,
                    height: 32,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorPalette.logoBackground(context),
                      shape: BoxShape.circle,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: competition.logoUrl!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Icon(Icons.emoji_events_outlined),
            title: Text(
              competition.nom,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
            ),
            onTap: () {},
          ),
        ),
        ResultatsSection<Joueur>(
          title: translate.joueurs,
          items: resultats.joueurs,
          hasMore: pageState?.hasMoreJoueurs ?? false,
          isLoadingMore: loadingSection == translate.joueurs,
          onLoadMore: () => onLoadMore?.call(translate.joueurs),
          itemBuilder: (joueur) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SizedBox(
              width: 32,
              height: 32,
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(joueur.picture),
              ),
            ),
            title: Text(
              joueur.fullName,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerDetailsPage(playerId: joueur.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MatchSearchTile extends StatefulWidget {
  final MatchModel match;

  const _MatchSearchTile({required this.match});

  @override
  State<_MatchSearchTile> createState() => _MatchSearchTileState();
}

class _MatchSearchTileState extends State<_MatchSearchTile>
    with SingleTickerProviderStateMixin {
  String? _mvpName;
  late final AnimationController _shimmerController;

  bool _mvpLoading = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _loadMvp();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadMvp() async {
    if (!widget.match.isFinished || widget.match.mvpVotes.isEmpty) return;

    setState(() => _mvpLoading = true);
    try {
      Joueur? mvp = widget.match.getMvp();
      if (mounted) {
        setState(() {
          _mvpName = mvp?.fullName;
          _mvpLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _mvpLoading = false);
    }
  }

  Widget _buildNoteBadge(BuildContext context, double note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ColorPalette.buttonSecondary(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 12, color: ColorPalette.accent(context)),
          const SizedBox(width: 4),
          Text(
            '${note.toStringAsFixed(1)}/10',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMvpBadge(BuildContext context) {
    if (_mvpLoading) {
      return FadeTransition(
        opacity: Tween(begin: 0.3, end: 0.8).animate(_shimmerController),
        child: Container(
          width: 80,
          height: 24,
          decoration: BoxDecoration(
            color: ColorPalette.buttonSecondary(context),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (_mvpName == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ColorPalette.buttonSecondary(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.how_to_vote,
            size: 12,
            color: ColorPalette.accent(context),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
            child: Text(
              _mvpName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final user = RepositoryProvider.userRepository.currentUser;
    double? avgRating = match.getNoteMoyenne();
    if (avgRating == -1) avgRating = null;

    final hasBadges = avgRating != null || _mvpLoading || (_mvpName != null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MatchDetailsPage(match: match)),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorPalette.border(context),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: ColorPalette.logoBackground(context),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CachedNetworkImage(
                        imageUrl: match.competition.logoUrl ??
                            'https://media.api-sports.io/football/leagues/1.png',
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: ColorPalette.accent(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: buildAdaptiveTeamName(
                                    context,
                                    nomComplet: match.equipeDomicile.nom,
                                    nomCourt: match.equipeDomicile.nomCourt,
                                    isWinner: match.domicileWinner,
                                    isLive: match.isLive,
                                    align: TextAlign.end,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                buildTeamLogo(
                                  context,
                                  match.equipeDomicile.logoPath,
                                  equipeId: match.equipeDomicile.id,
                                  size: 24,
                                  clickable: false,
                                  user: user,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 44,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      Text(
                                        displayScoreOrMatchDate(match),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color:
                                              ColorPalette.textPrimary(context),
                                        ),
                                      ),
                                      ...displayProlongationsPenaltys(
                                        match: match,
                                        context: context,
                                        fontSize: 12,
                                      ),
                                      if (match.isScheduled)
                                        Text(
                                          DateFormat('d MMMM', getDateFormat())
                                              .format(match.date),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: ColorPalette.textPrimary(
                                                context),
                                          ),
                                        ),
                                    ],
                                  ),
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
                                  size: 24,
                                  clickable: false,
                                  user: user,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: buildAdaptiveTeamName(
                                    context,
                                    nomComplet: match.equipeExterieur.nom,
                                    nomCourt: match.equipeExterieur.nomCourt,
                                    isWinner: match.exterieurWinner,
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
                  ],
                ),
                if (hasBadges) ...[
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: Row(
                      children: [
                        if (avgRating != null)
                          _buildNoteBadge(context, avgRating),
                        if (avgRating != null &&
                            (_mvpLoading || _mvpName != null))
                          const SizedBox(width: 6),
                        if (_mvpLoading || _mvpName != null)
                          _buildMvpBadge(context),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
