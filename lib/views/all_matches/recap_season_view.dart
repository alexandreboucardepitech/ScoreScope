import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scorescope/models/watch_together/watch_together_season_summary.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/widgets/rich_match_card.dart';
import 'package:scorescope/widgets/statistiques/graphs/pie_stat_graph.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/stats/graph/stat_value.dart';
import 'package:scorescope/models/stats/graph/time_stat_value.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/stats/stats_data_loader.dart';
import 'package:scorescope/utils/stats/stats_loading_state.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/statistiques/graphs/time_line_chart.dart';

class _CompetitionStat {
  final String name;
  final String? logo;
  final int count;
  const _CompetitionStat(this.name, this.logo, this.count);
}

class _TeamStat {
  final String id;
  final String name;
  final String? logo;
  final int count;
  const _TeamStat(this.id, this.name, this.logo, this.count);
}

class _MvpStat {
  final String name;
  final String? photo;
  final int votes;
  const _MvpStat(this.name, this.photo, this.votes);
}

class _SeasonRecapData {
  final int matchCount;
  final double? avgRating;
  final int totalGoals;
  final String? userPhoto;
  final String userName;

  final List<MatchModel> bestMatches;
  final int? bestMatchRating;
  final List<bool> bestMatchesFavourite;
  final List<Joueur?> bestMatchesMvpJoueur;
  final List<Joueur?> bestMatchesCommunityMvpJoueur;
  final List<double?> bestMatchesCommunityNote;

  final List<_CompetitionStat> topCompetitions;
  final List<_TeamStat> topTeams;
  final List<_MvpStat> topMvps;

  final List<TimeStatValue> monthlySeries;

  final int teleCount;
  final int stadeCount;
  final int barCount;

  final WatchTogetherSeasonSummary friends;

  final String saisonLabel;

  _SeasonRecapData({
    required this.matchCount,
    this.avgRating,
    required this.totalGoals,
    this.userPhoto,
    required this.userName,
    required this.bestMatches,
    this.bestMatchRating,
    required this.bestMatchesFavourite,
    required this.bestMatchesMvpJoueur,
    required this.bestMatchesCommunityMvpJoueur,
    required this.bestMatchesCommunityNote,
    required this.topCompetitions,
    required this.topTeams,
    required this.topMvps,
    required this.monthlySeries,
    required this.teleCount,
    required this.stadeCount,
    required this.barCount,
    required this.friends,
    required this.saisonLabel,
  });
}

class RecapSeasonView extends StatefulWidget {
  const RecapSeasonView({super.key});

  @override
  State<RecapSeasonView> createState() => _RecapSeasonViewState();
}

class _RecapSeasonViewState extends State<RecapSeasonView> {
  bool _loading = true;
  String? _error;
  _SeasonRecapData? _data;
  int _bestMatchIndex = 0;

  final GlobalKey _shareKey = GlobalKey();

  bool _isSharing = false;
  String _loadingLabel = translate.chargement;

  StatsLoadingState? _loaderState;

  late final int _saisonAnnee;
  late final DateTime _debutSaison;
  late final DateTime _finSaison;

  @override
  void initState() {
    super.initState();
    _initSeasonBounds();
    _loadData();
  }

  void _initSeasonBounds() {
    final currentSaison = 2026;
    _saisonAnnee = currentSaison - 1;
    _debutSaison = DateTime(_saisonAnnee, 8, 1);
    _finSaison = DateTime(_saisonAnnee + 1, 7, 31, 23, 59, 59);
  }

  String get _saisonLabel => '$_saisonAnnee/${_saisonAnnee + 1}';

  Future<void> _loadData() async {
    try {
      final uid = RepositoryProvider.userRepository.currentUser?.uid;
      if (uid == null) throw Exception(translate.utilisateurNonConnecte);

      final dateRange = DateTimeRange(start: _debutSaison, end: _finSaison);
      final matchIdsCompleter = Completer<List<String>>();

      final loader = StatsDataLoader(
        userId: uid,
        onlyPublic: false,
        dateRange: dateRange,
        onStateChanged: (state) =>
            _onLoaderStateChanged(state, matchIdsCompleter),
      );

      final results = await Future.wait<dynamic>([
        loader.load(),
        matchIdsCompleter.future.then(
          (matchIds) => RepositoryProvider.watchTogetherRepository
              .fetchUserWatchTogetherSummary(userId: uid, matchIds: matchIds),
        ),
      ]);

      final friendsSummary = results[1] as WatchTogetherSeasonSummary;

      if (!mounted) return;

      final state = _loaderState;
      if (state == null || state.phase == StatsLoadingPhase.error) {
        throw Exception(
            state?.errorMessage ?? translate.impossibleDeChargerLeRecap);
      }
      if (state.phase != StatsLoadingPhase.ready) {
        throw Exception(translate.impossibleDeChargerLeRecap);
      }

      setState(() => _loadingLabel = translate.calculDesStatistiques);

      final data = _compute(
        state,
        friendsSummary,
        RepositoryProvider.userRepository.currentUser!,
      );

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onLoaderStateChanged(
      StatsLoadingState state, Completer<List<String>> matchIdsCompleter) {
    _loaderState = state;

    if (!matchIdsCompleter.isCompleted) {
      if (state.matchIds.isNotEmpty) {
        matchIdsCompleter.complete(state.matchIds);
      } else if (state.phase == StatsLoadingPhase.ready ||
          state.phase == StatsLoadingPhase.error) {
        matchIdsCompleter.complete(<String>[]);
      }
    }

    if (!mounted) return;
    setState(() => _loadingLabel = _labelForPhase(state.phase));
  }

  String _labelForPhase(StatsLoadingPhase phase) {
    switch (phase) {
      case StatsLoadingPhase.fetchingMatchIds:
        return translate.recuperationDesMatchsDeLaSaison;
      case StatsLoadingPhase.fetchingMatchData:
        return translate.chargementDesDetailsDesMatchs;
      case StatsLoadingPhase.fetchingEntities:
        return translate.chargementDesEquipesEtCompetitions;
      case StatsLoadingPhase.assemblingModels:
      case StatsLoadingPhase.ready:
      case StatsLoadingPhase.idle:
        return translate.calculDesStatistiques;
      case StatsLoadingPhase.error:
        return translate.impossibleDeChargerLeRecap;
    }
  }

  _SeasonRecapData _compute(
    StatsLoadingState state,
    WatchTogetherSeasonSummary friends,
    AppUser user,
  ) {
    final muds = state.matchUserData;
    final matchMap = <String, MatchModel>{
      for (final m in state.matchModels) m.id: m,
    };

    final rated = muds.where((m) => m.note != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.map((m) => m.note!).reduce((a, b) => a + b) / rated.length;

    int? maxRating;
    if (rated.isNotEmpty) {
      maxRating = rated.map((m) => m.note!).reduce((a, b) => a > b ? a : b);
    }
    final bestMuds = maxRating != null
        ? rated.where((m) => m.note == maxRating).toList()
        : <MatchUserData>[];

    int goals = 0;
    int teleCount = 0, stadeCount = 0, barCount = 0;
    final monthCount = <String, int>{};

    for (final mud in muds) {
      final match = matchMap[mud.matchId];
      if (match != null) {
        goals += match.scoreEquipeDomicile + match.scoreEquipeExterieur;
      }

      switch (mud.visionnageMatch) {
        case VisionnageMatch.tele:
          teleCount++;
          break;
        case VisionnageMatch.stade:
          stadeCount++;
          break;
        case VisionnageMatch.bar:
          barCount++;
          break;
      }

      final date = mud.matchDate ?? mud.watchedAt;
      if (date != null) {
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthCount[key] = (monthCount[key] ?? 0) + 1;
      }
    }

    final monthlySeries = <TimeStatValue>[];
    for (int i = 0; i < 12; i++) {
      final period = DateTime(_saisonAnnee, 8 + i);
      final key = '${period.year}-${period.month.toString().padLeft(2, '0')}';
      monthlySeries.add(TimeStatValue(
        period: period,
        value: monthCount[key] ?? 0,
      ));
    }

    final compCount = <String, int>{};
    final compName = <String, String>{};
    final compLogo = <String, String?>{};
    final teamCount = <String, int>{};
    final teamName = <String, String>{};
    final teamLogo = <String, String?>{};

    for (final mud in muds) {
      final match = matchMap[mud.matchId];
      if (match == null) continue;

      compCount[match.competition.id] =
          (compCount[match.competition.id] ?? 0) + 1;
      compName[match.competition.id] = match.competition.nom;
      compLogo[match.competition.id] = match.competition.logoUrl;

      for (final eq in [match.equipeDomicile, match.equipeExterieur]) {
        teamCount[eq.id] = (teamCount[eq.id] ?? 0) + 1;
        teamName[eq.id] = eq.nom;
        teamLogo[eq.id] = eq.logoPath;
      }
    }

    final topCompetitions = (compCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map(
            (e) => _CompetitionStat(compName[e.key]!, compLogo[e.key], e.value))
        .toList();

    final topTeams = (teamCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map(
            (e) => _TeamStat(e.key, teamName[e.key]!, teamLogo[e.key], e.value))
        .toList();

    final bestMatches = <MatchModel>[];
    final bestMatchesFavourite = <bool>[];
    final bestMatchesMvpJoueur = <Joueur?>[];
    final bestMatchesCommunityMvpJoueur = <Joueur?>[];
    final bestMatchesCommunityNote = <double?>[];

    for (final mud in bestMuds) {
      final match = matchMap[mud.matchId];
      if (match == null) continue;
      bestMatches.add(match);
      bestMatchesFavourite.add(mud.favourite);

      Joueur? mvpVoted;
      if (mud.mvpVoteId != null) {
        final player = _findPlayer(mud.mvpVoteId!, [
          ...match.joueursEquipeDomicile,
          ...match.joueursEquipeExterieur,
        ]);
        mvpVoted = player?.joueur;
      }
      bestMatchesMvpJoueur.add(mvpVoted);

      final Joueur? communityMvp = match.getMvp();
      bestMatchesCommunityMvpJoueur.add(communityMvp);
      bestMatchesCommunityNote.add(match.getNoteMoyenne());
    }

    final mvpVotes = <String, int>{};
    final mvpBestRating = <String, int>{};
    for (final mud in muds) {
      if (mud.mvpVoteId != null) {
        mvpVotes[mud.mvpVoteId!] = (mvpVotes[mud.mvpVoteId!] ?? 0) + 1;
        final rating = mud.note ?? 0;
        mvpBestRating[mud.mvpVoteId!] =
            (mvpBestRating[mud.mvpVoteId!] ?? 0) > rating
                ? mvpBestRating[mud.mvpVoteId!]!
                : rating;
      }
    }
    final sortedMvpIds = mvpVotes.keys.toList()
      ..sort((a, b) {
        final voteDiff = mvpVotes[b]! - mvpVotes[a]!;
        if (voteDiff != 0) return voteDiff;
        return (mvpBestRating[b] ?? 0) - (mvpBestRating[a] ?? 0);
      });

    final topMvps = <_MvpStat>[];
    for (final mvpId in sortedMvpIds.take(3)) {
      for (final match in matchMap.values) {
        final player = _findPlayer(mvpId,
            [...match.joueursEquipeDomicile, ...match.joueursEquipeExterieur]);
        if (player != null) {
          topMvps.add(_MvpStat(player.joueur?.fullName ?? '',
              player.joueur?.picture, mvpVotes[mvpId]!));
          break;
        }
      }
    }

    return _SeasonRecapData(
      matchCount: muds.length,
      avgRating: avgRating,
      totalGoals: goals,
      userPhoto: user.photoUrl,
      userName: user.displayName,
      bestMatches: bestMatches,
      bestMatchRating: maxRating,
      bestMatchesFavourite: bestMatchesFavourite,
      bestMatchesMvpJoueur: bestMatchesMvpJoueur,
      bestMatchesCommunityMvpJoueur: bestMatchesCommunityMvpJoueur,
      bestMatchesCommunityNote: bestMatchesCommunityNote,
      topCompetitions: topCompetitions,
      topTeams: topTeams,
      topMvps: topMvps,
      monthlySeries: monthlySeries,
      teleCount: teleCount,
      stadeCount: stadeCount,
      barCount: barCount,
      friends: friends,
      saisonLabel: _saisonLabel,
    );
  }

  MatchJoueur? _findPlayer(String id, List<MatchJoueur> players) {
    for (final player in players) {
      if (player.joueur?.id == id) return player;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            AppLogos.logoPrimary(context, size: 32),
            const SizedBox(width: 8),
            Text(
              translate.recapDeLaSaison,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _data!.matchCount == 0
                  ? _buildEmpty()
                  : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
                color: ColorPalette.accent(context), strokeWidth: 3),
            const SizedBox(height: 24),
            Text(
              translate.recapDeLaSaisonX(_saisonLabel),
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadingLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ColorPalette.textSecondary(context), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              color: ColorPalette.error(context), size: 48),
          const SizedBox(height: 12),
          Text(translate.impossibleDeChargerLeRecap,
              style: TextStyle(color: ColorPalette.textPrimary(context))),
          TextButton(
            onPressed: () {
              setState(() => _loading = true);
              _loadData();
            },
            child: Text(translate.reessayer,
                style: TextStyle(color: ColorPalette.accent(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer,
              color: ColorPalette.textSecondary(context), size: 64),
          const SizedBox(height: 16),
          Text(
            translate.aucunMatchCetteSaisonX(_saisonLabel),
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate.ajouteLesMatchsQueTuRegardes,
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorPalette.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _shareKey,
            child: Container(
              decoration: BoxDecoration(
                color: ColorPalette.surface(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ColorPalette.accentLight.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(d),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (d.bestMatches.isNotEmpty) ...[
                          _buildBestMatch(d),
                          const SizedBox(height: 6),
                        ],
                        if (d.topCompetitions.isNotEmpty ||
                            d.topTeams.isNotEmpty) ...[
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (d.topCompetitions.isNotEmpty) ...[
                                  Expanded(
                                      child: _buildTopCompetitions(
                                          d.topCompetitions)),
                                  const SizedBox(width: 8),
                                ],
                                if (d.topTeams.isNotEmpty)
                                  Expanded(child: _buildTopTeams(d.topTeams)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (d.topMvps.isNotEmpty) ...[
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 2, child: _buildMvpPodium(d)),
                                const SizedBox(width: 6),
                                Expanded(child: _buildFriends(d)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _buildVisionnageCompact(d)),
                              const SizedBox(width: 6),
                              Expanded(flex: 2, child: _buildMonthlyChart(d)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSocialLine(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareRecap,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.accent(context),
                foregroundColor: ColorPalette.textPrimary(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.share_rounded),
              label: Text(
                translate.partagerMonRecap,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_SeasonRecapData d) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorPalette.accentLight, ColorPalette.accentVariantLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPlayerAvatar(d.userPhoto, d.userName, 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '@${d.userName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColorPalette.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translate.recapDeLaSaisonX(d.saisonLabel),
                    style: TextStyle(
                        color: ColorPalette.textPrimaryDark, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: ColorPalette.backgroundLight,
                      shape: BoxShape.circle,
                    ),
                    child: AppLogos.logoAccent(context, size: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildHeaderStat(
                  value: '${d.matchCount}',
                  label: translate.matchXRegardeX(d.matchCount > 1 ? 's' : ''),
                ),
              ),
              if (d.totalGoals > 0)
                Expanded(
                  child: _buildHeaderStat(
                    value: '${d.totalGoals}',
                    label: translate.butXVus(d.totalGoals > 1 ? 's' : ''),
                  ),
                ),
              if (d.avgRating != null)
                Expanded(
                  child: _buildHeaderStat(
                    value: roundSmart(d.avgRating!, decimals: 1),
                    label: translate.noteMoyenne,
                    complement: "/10",
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(
      {required String value, required String label, String? complement}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: ColorPalette.textPrimaryDark,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            if (complement != null) ...[
              const SizedBox(width: 4),
              Text(
                complement,
                style: const TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
        Text(
          label,
          style: const TextStyle(
              color: ColorPalette.textPrimaryDark, fontSize: 12, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildBestMatch(_SeasonRecapData d) {
    final match = d.bestMatches[_bestMatchIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              translate.meilleurMatchDeLaSaison,
              style: TextStyle(
                color: ColorPalette.textAccent(context),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (d.bestMatches.length > 1)
              Opacity(
                opacity: _isSharing ? 0 : 1,
                child: GestureDetector(
                  onTap: () => setState(() => _bestMatchIndex =
                      (_bestMatchIndex + 1) % d.bestMatches.length),
                  child: Icon(Icons.refresh_rounded,
                      color: ColorPalette.textSecondary(context), size: 18),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        RichMatchCard(
          match: match,
          rating: d.bestMatchRating,
          mvpVoted: d.bestMatchesMvpJoueur[_bestMatchIndex],
          globalMvp: d.bestMatchesCommunityMvpJoueur[_bestMatchIndex],
          globalRating: d.bestMatchesCommunityNote[_bestMatchIndex],
          favourite: d.bestMatchesFavourite[_bestMatchIndex],
          accent: ColorPalette.accent(context),
          goldColor: const Color(0xFFFFD700),
          textColor: ColorPalette.textPrimary(context),
          textDimColor: ColorPalette.textSecondary(context),
        ),
      ],
    );
  }

  Widget _buildTopCompetitions(List<_CompetitionStat> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.competitionsSuivies,
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${i + 1}.',
                  style: TextStyle(
                    color: ColorPalette.textSecondary(context),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: ColorPalette.logoBackground(context),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: items[i].logo != null
                      ? CachedNetworkImage(
                          imageUrl: items[i].logo!,
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Icon(Icons.emoji_events,
                              color: ColorPalette.accent(context), size: 14),
                        )
                      : Icon(Icons.emoji_events,
                          color: ColorPalette.accent(context), size: 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${items[i].count}',
                  style: TextStyle(
                      color: ColorPalette.textSecondary(context), fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopTeams(List<_TeamStat> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.equipesSuivies,
            style: TextStyle(
                color: ColorPalette.textAccent(context),
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            Row(
              children: [
                Text('${i + 1}.',
                    style: TextStyle(
                        color: ColorPalette.textSecondary(context),
                        fontSize: 10)),
                const SizedBox(width: 6),
                buildTeamLogo(
                  context,
                  items[i].logo,
                  equipeId: items[i].id,
                  size: 20,
                  clickable: false,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${items[i].count}',
                  style: TextStyle(
                      color: ColorPalette.textSecondary(context), fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMvpPodium(_SeasonRecapData d) {
    final order = d.topMvps.length >= 3
        ? [1, 0, 2]
        : List.generate(d.topMvps.length, (i) => i);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.top3MvpDeLaSaison,
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final i in order) ...[
                if (i != order.first) const SizedBox(width: 8),
                _buildPodiumEntry(d.topMvps[i], position: i),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumEntry(_MvpStat mvp, {required int position}) {
    final isFirst = position == 0;
    final size = isFirst ? 36.0 : 28.0;
    Color borderColor;
    switch (position) {
      case 0:
        borderColor = const Color(0xFFFFD700);
        break;
      case 1:
        borderColor = const Color(0xFFC0C0C0);
        break;
      case 2:
        borderColor = const Color(0xFFCD7F32);
        break;
      default:
        borderColor =
            ColorPalette.textSecondary(context).withValues(alpha: 0.5);
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2)),
          padding: const EdgeInsets.all(1),
          child: _buildPlayerAvatar(mvp.photo, mvp.name, size),
        ),
        const SizedBox(height: 4),
        Text(
          mvp.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
            fontSize: isFirst ? 11 : 10,
          ),
        ),
        Text(
          '${mvp.votes}x',
          style: TextStyle(
            color: isFirst
                ? const Color(0xFFFFD700)
                : ColorPalette.textSecondary(context),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(_SeasonRecapData d) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translate.matchsVusParMois,
              style: TextStyle(
                  color: ColorPalette.textAccent(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          TimeLineChart(
            values: d.monthlySeries,
            showHeader: false,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFriends(_SeasonRecapData d) {
    final f = d.friends;
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translate.entreAmis,
              style: TextStyle(
                  color: ColorPalette.textAccent(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(height: 6),
          if (f.totalMatchesWithFriends == 0)
            Text(
              translate.inviteTesAmisPourPartagerTesMatchs,
              style: TextStyle(
                  color: ColorPalette.textSecondary(context), fontSize: 11),
            )
          else ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                translate.xMatchsAvecXAmis(f.totalMatchesWithFriends.toString(),
                    f.distinctFriendsCount.toString()),
                style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            for (final friend in f.topFriends) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildPlayerAvatar(friend.friendPhoto, friend.friendName, 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      friend.friendName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontSize: 12),
                    ),
                  ),
                  Text(
                    friend.matchesTogether.toString(),
                    style: TextStyle(
                      color: ColorPalette.textSecondary(context),
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildVisionnageCompact(_SeasonRecapData d) {
    final total = d.teleCount + d.stadeCount + d.barCount;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            translate.visionnage,
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          if (total == 0)
            Text('-',
                style: TextStyle(color: ColorPalette.textSecondary(context)))
          else
            Center(
              child: PieStatGraph(
                compact: true,
                values: [
                  if (d.teleCount > 0)
                    StatValue(
                        label: VisionnageMatch.tele.label,
                        value: d.teleCount.toDouble()),
                  if (d.stadeCount > 0)
                    StatValue(
                        label: VisionnageMatch.stade.label,
                        value: d.stadeCount.toDouble()),
                  if (d.barCount > 0)
                    StatValue(
                        label: VisionnageMatch.bar.label,
                        value: d.barCount.toDouble()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialLine() {
    final logos = [
      {'name': 'Instagram', 'asset': 'assets/logos/other/Instagram.png'},
      {'name': 'X', 'asset': 'assets/logos/other/X.png'},
      {'name': 'App Store', 'asset': 'assets/logos/other/AppleStore.png'},
      {'name': 'Play Store', 'asset': 'assets/logos/other/PlayStore.png'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.accentLight.withValues(alpha: 0.08),
        border: Border(
            top: BorderSide(
                color: ColorPalette.accentLight.withValues(alpha: 0.2),
                width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'ScoreScope',
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: logos
                .map((logo) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Image.asset(logo['asset']!,
                          width: 14, height: 14, fit: BoxFit.contain),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(String? photoUrl, String name, double size) {
    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _avatarFallback(name, size),
        ),
      );
    }
    return _avatarFallback(name, size);
  }

  Widget _avatarFallback(String name, double size) {
    if (name.isEmpty) return SizedBox.shrink();
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorPalette.accentLight.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border:
            Border.all(color: ColorPalette.accentLight.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: ColorPalette.accent(context),
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  Future<void> _shareRecap() async {
    setState(() => _isSharing = true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final boundary = _shareKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;

        final pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/scorescope_recap_saison.png');
        await file.writeAsBytes(pngBytes);

        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin =
            box != null ? box.localToGlobal(Offset.zero) & box.size : null;

        await Share.shareXFiles(
          [XFile(file.path)],
          text: '''
Voici mon récap foot de la saison ${_saisonLabel} !⚽📊

Découvrez le votre, téléchargez @ScoreScopeApp !
''',
          sharePositionOrigin: sharePositionOrigin,
        );
      } catch (e) {
        debugPrint('Erreur partage recap saison : $e');
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    });
  }
}
