import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class _RecapData {
  final int matchCount;
  final double? avgRating;
  final int totalGoals;
  final String? userPhoto;
  final String userName;
  final List<MatchModel>? bestMatches;
  final int? bestMatchRating;
  final List<String>? bestMatchesMvpName;
  final List<String>? bestMatchesMvpPhoto;
  final List<VisionnageMatch>? bestMatchesVisionnage;
  final String? topCompetitionName;
  final String? topCompetitionLogo;
  final int? topCompetitionCount;
  final int prevWeekMatchCount;
  final int prevWeekGoalCount;
  final double? prevWeekAvgRating;
  final int streak;
  final List<String> funStats;
  final List<String>? weekMvpNames;
  final List<String>? weekMvpPhotos;
  final List<int>? weekMvpVoteCounts;
  final int totalNbMatches;
  final int totalNbGoalsAllTime;

  _RecapData({
    required this.matchCount,
    this.avgRating,
    required this.totalGoals,
    this.userPhoto,
    required this.userName,
    this.bestMatches,
    this.bestMatchRating,
    this.bestMatchesMvpName,
    this.bestMatchesMvpPhoto,
    this.bestMatchesVisionnage,
    this.topCompetitionName,
    this.topCompetitionLogo,
    this.topCompetitionCount,
    required this.prevWeekMatchCount,
    required this.prevWeekGoalCount,
    this.prevWeekAvgRating,
    required this.streak,
    required this.funStats,
    this.weekMvpNames,
    this.weekMvpPhotos,
    this.weekMvpVoteCounts,
    required this.totalNbMatches,
    required this.totalNbGoalsAllTime,
  });
}

class RecapWeekView extends StatefulWidget {
  const RecapWeekView({super.key});

  @override
  State<RecapWeekView> createState() => _RecapWeekViewState();
}

class _RecapWeekViewState extends State<RecapWeekView> {
  bool _loading = true;
  String? _error;
  _RecapData? _data;
  int _funStatIndex = 0;
  int _bestMatchIndex = 0;
  int _MVPIndex = 0;

  final GlobalKey _shareKey = GlobalKey();

  bool _isSharing = false;
  String _loadingLabel = 'Chargement…';

  late final DateTime _lastMonday;
  late final DateTime _lastSunday;
  late final DateTime _prevMonday;
  late final DateTime _prevSunday;

  @override
  void initState() {
    super.initState();
    _initDates();
    _loadData();
  }

  void _initDates() {
    final now = DateTime.now();
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    _lastMonday = thisMonday.subtract(const Duration(days: 7));
    _lastSunday = thisMonday.subtract(const Duration(seconds: 1));
    _prevMonday = _lastMonday.subtract(const Duration(days: 7));
    _prevSunday = _lastMonday.subtract(const Duration(seconds: 1));
  }

  String _weekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    try {
      final uid = RepositoryProvider.userRepository.currentUser?.uid;
      if (uid == null) throw Exception('Utilisateur non connecté');

      setState(() => _loadingLabel = 'Récupération des matchs…');
      final results = await Future.wait([
        RepositoryProvider.userRepository.fetchUserAllMatchUserData(
          userId: uid,
          dateRange: DateTimeRange(start: _lastMonday, end: _lastSunday),
        ),
        RepositoryProvider.userRepository.fetchUserAllMatchUserData(
          userId: uid,
          dateRange: DateTimeRange(start: _prevMonday, end: _prevSunday),
        ),
        RepositoryProvider.userRepository
            .fetchUserAllMatchUserData(userId: uid),
      ]);

      final thisWeek = results[0];
      final prevWeek = results[1];
      final allMuds = results[2];

      setState(() => _loadingLabel = 'Chargement des détails des matchs…');
      final matchDetails = await Future.wait(
        thisWeek.map((m) =>
            RepositoryProvider.matchRepository.fetchMatchById(m.matchId)),
      );

      final matchMap = <String, MatchModel>{};
      for (int i = 0; i < thisWeek.length; i++) {
        if (matchDetails[i] != null)
          matchMap[thisWeek[i].matchId] = matchDetails[i]!;
      }

      final matchLastWeekDetails = await Future.wait(
        prevWeek.map((m) =>
            RepositoryProvider.matchRepository.fetchMatchById(m.matchId)),
      );
      for (int i = 0; i < prevWeek.length; i++) {
        if (matchLastWeekDetails[i] != null)
          matchMap[prevWeek[i].matchId] = matchLastWeekDetails[i]!;
      }

      setState(() => _loadingLabel = 'Calcul des statistiques…');
      final totalNbGoalsAllTime =
          await RepositoryProvider.userRepository.getUserNbButs(uid, true);

      setState(() {
        _data = _compute(
            thisWeek,
            prevWeek,
            allMuds,
            matchMap,
            totalNbGoalsAllTime,
            RepositoryProvider.userRepository.currentUser!);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  _RecapData _compute(
    List<MatchUserData> thisWeek,
    List<MatchUserData> prevWeek,
    List<MatchUserData> allMuds,
    Map<String, MatchModel> matchMap,
    int totalNbGoalsAllTime,
    AppUser user,
  ) {
    final rated = thisWeek.where((m) => m.note != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.map((m) => m.note!).reduce((a, b) => a + b) / rated.length;

    final lastWeekRated = prevWeek.where((m) => m.note != null).toList();
    final lastWeekAvgRating = lastWeekRated.isEmpty
        ? null
        : lastWeekRated.map((m) => m.note!).reduce((a, b) => a + b) /
            lastWeekRated.length;

    // Find all matches with the best rating
    int? maxRating = null;
    if (rated.isNotEmpty) {
      maxRating = rated.map((m) => m.note!).reduce((a, b) => a > b ? a : b);
    }

    final bestMuds = maxRating != null
        ? rated.where((m) => m.note == maxRating).toList()
        : [];

    int goals = 0;
    for (final mud in thisWeek) {
      final match = matchMap[mud.matchId];
      if (match != null) {
        goals += match.scoreEquipeDomicile + match.scoreEquipeExterieur;
      }
    }

    int lastWeekGoals = 0;
    for (final mud in prevWeek) {
      final match = matchMap[mud.matchId];
      if (match != null) {
        lastWeekGoals += match.scoreEquipeDomicile + match.scoreEquipeExterieur;
      }
    }

    final compCount = <String, int>{};
    final compName = <String, String>{};
    final compLogo = <String, String?>{};
    for (final mud in thisWeek) {
      final match = matchMap[mud.matchId];
      if (match == null) continue;
      compCount[match.competition.id] =
          (compCount[match.competition.id] ?? 0) + 1;
      compName[match.competition.id] = match.competition.nom;
      compLogo[match.competition.id] = match.competition.logoUrl;
    }
    String? topName, topLogo;
    int? topCount;
    if (compCount.isNotEmpty) {
      final topId =
          compCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      topName = compName[topId];
      topLogo = compLogo[topId];
      topCount = compCount[topId];
    }

    final bestMatchesMvpNames = <String>[];
    final bestMatchesMvpPhotos = <String>[];
    final bestMatchModels = <MatchModel>[];
    final bestMatchesVisionnage = <VisionnageMatch>[];

    for (final bestMud in bestMuds) {
      final bestMatch = matchMap[bestMud.matchId];
      if (bestMatch != null) {
        bestMatchModels.add(bestMatch);
        if (bestMud.visionnageMatch != null) {
          bestMatchesVisionnage.add(bestMud.visionnageMatch!);
        }

        if (bestMud.mvpVoteId != null) {
          final player = _findPlayer(
            bestMud.mvpVoteId!,
            [
              ...bestMatch.joueursEquipeDomicile,
              ...bestMatch.joueursEquipeExterieur
            ],
          );
          bestMatchesMvpNames.add(player?.joueur?.fullName ?? '');
          bestMatchesMvpPhotos.add(player?.joueur?.picture ?? '');
        } else {
          bestMatchesMvpNames.add('');
          bestMatchesMvpPhotos.add('');
        }
      }
    }

    final mvpVotes = <String, int>{};
    final mvpBestRating = <String, int>{};

    for (final mud in thisWeek) {
      if (mud.mvpVoteId != null) {
        mvpVotes[mud.mvpVoteId!] = (mvpVotes[mud.mvpVoteId!] ?? 0) + 1;

        // Track the best rating this player was voted MVP for
        final rating = mud.note ?? 0;
        if (!mvpBestRating.containsKey(mud.mvpVoteId!)) {
          mvpBestRating[mud.mvpVoteId!] = rating.toInt();
        } else {
          mvpBestRating[mud.mvpVoteId!] =
              mvpBestRating[mud.mvpVoteId!]! > rating.toInt()
                  ? mvpBestRating[mud.mvpVoteId!]!
                  : rating.toInt();
        }
      }
    }

    // Sort by vote count (desc), then by best rating (desc)
    final sortedMvpIds = mvpVotes.keys.toList()
      ..sort((a, b) {
        final voteDiff = mvpVotes[b]! - mvpVotes[a]!;
        if (voteDiff != 0) return voteDiff;
        return (mvpBestRating[b] ?? 0) - (mvpBestRating[a] ?? 0);
      });

    final weekMvpNames = <String>[];
    final weekMvpPhotos = <String>[];
    final weekMvpVoteCounts = <int>[];

    for (final mvpId in sortedMvpIds) {
      final voteCount = mvpVotes[mvpId]!;

      // Find the player's name and photo from any match
      for (final match in matchMap.values) {
        final player = _findPlayer(
          mvpId,
          [...match.joueursEquipeDomicile, ...match.joueursEquipeExterieur],
        );
        if (player != null) {
          weekMvpNames.add(player.joueur?.fullName ?? '');
          weekMvpPhotos.add(player.joueur?.picture ?? '');
          weekMvpVoteCounts.add(voteCount);
          break;
        }
      }
    }

    return _RecapData(
      matchCount: thisWeek.length,
      avgRating: avgRating,
      totalGoals: goals,
      userPhoto: user.photoUrl,
      userName: user.displayName,
      bestMatches: bestMatchModels.isNotEmpty ? bestMatchModels : null,
      bestMatchRating: maxRating?.toInt(),
      bestMatchesMvpName:
          bestMatchesMvpNames.isNotEmpty ? bestMatchesMvpNames : null,
      bestMatchesMvpPhoto:
          bestMatchesMvpPhotos.isNotEmpty ? bestMatchesMvpPhotos : null,
      bestMatchesVisionnage:
          bestMatchesVisionnage.isNotEmpty ? bestMatchesVisionnage : null,
      topCompetitionName: topName,
      topCompetitionLogo: topLogo,
      topCompetitionCount: topCount,
      prevWeekMatchCount: prevWeek.length,
      prevWeekGoalCount: lastWeekGoals,
      prevWeekAvgRating: lastWeekAvgRating,
      streak: _computeStreak(allMuds),
      funStats:
          _buildFunStats(thisWeek, matchMap, avgRating, topName, topCount),
      weekMvpNames: weekMvpNames.isNotEmpty ? weekMvpNames : null,
      weekMvpPhotos: weekMvpPhotos.isNotEmpty ? weekMvpPhotos : null,
      weekMvpVoteCounts:
          weekMvpVoteCounts.isNotEmpty ? weekMvpVoteCounts : null,
      totalNbMatches: allMuds.length,
      totalNbGoalsAllTime: totalNbGoalsAllTime,
    );
  }

  MatchJoueur? _findPlayer(String id, List<MatchJoueur> players) {
    try {
      return players.firstWhere((p) => p.joueur?.id == id);
    } catch (_) {
      return null;
    }
  }

  int _computeStreak(List<MatchUserData> allMuds) {
    final weeksWithMatches = <String>{};
    for (final mud in allMuds) {
      final date = mud.matchDate ?? mud.watchedAt;
      if (date != null) weeksWithMatches.add(_weekKey(date));
    }
    int streak = 0;
    var weekStart = _lastMonday;
    while (weeksWithMatches.contains(_weekKey(weekStart))) {
      streak++;
      weekStart = weekStart.subtract(const Duration(days: 7));
    }
    return streak;
  }

  List<String> _buildFunStats(
    List<MatchUserData> week,
    Map<String, MatchModel> matchMap,
    double? avg,
    String? topCompetitionName,
    int? topCompetitionCount,
  ) {
    final stats = <String>[];

    final matches =
        week.map((m) => matchMap[m.matchId]).whereType<MatchModel>().toList();

    final n = matches.length;

    if (n == 0) {
      return ['👀 Petite semaine football'];
    }

    final totalGoals = matches.fold<int>(
      0,
      (sum, m) => sum + m.scoreEquipeDomicile + m.scoreEquipeExterieur,
    );

    final avgGoals = totalGoals / n;

    final highScoring = matches.where((m) {
      final goals = m.scoreEquipeDomicile + m.scoreEquipeExterieur;
      return goals >= 3;
    }).length;

    final veryHighScoring = matches.where((m) {
      final goals = m.scoreEquipeDomicile + m.scoreEquipeExterieur;
      return goals >= 5;
    }).length;

    final zeroZero = matches.where((m) {
      return m.scoreEquipeDomicile == 0 && m.scoreEquipeExterieur == 0;
    }).length;

    final noTwoGoalGames = matches.where((m) {
      final goals = m.scoreEquipeDomicile + m.scoreEquipeExterieur;
      return goals < 2;
    }).length;

    final cleanSheets = matches.where((m) {
      return m.scoreEquipeDomicile == 0 || m.scoreEquipeExterieur == 0;
    }).length;

    final closeGames = matches.where((m) {
      return (m.scoreEquipeDomicile - m.scoreEquipeExterieur).abs() == 1;
    }).length;

    final draws = matches.where((m) {
      return m.scoreEquipeDomicile == m.scoreEquipeExterieur;
    }).length;

    final greatMatches = week.where((m) {
      return (m.note ?? 0) >= 8;
    }).length;

    final badMatches = week.where((m) {
      return (m.note ?? 10) <= 4;
    }).length;

    final noBadMatches = week.where((m) {
      return (m.note ?? 0) >= 7;
    }).length;

    // =========================
    // POSITIVE
    // =========================

    if (highScoring >= n * 0.8 && n >= 3) {
      stats.add(
        '🍿 Football spectacle • ${(highScoring / n * 100).round()}% avec 3+ buts',
      );
    }

    if (avgGoals >= 4 && n >= 3) {
      stats.add(
        '💥 Défenses absentes • ${avgGoals.toStringAsFixed(1)} buts/match',
      );
    }

    if (veryHighScoring >= 2) {
      stats.add(
        '🔥 Semaine chaotique • $veryHighScoring matchs avec 5+ buts',
      );
    }

    if (zeroZero == 0 && n >= 3) {
      stats.add(
        '🎯 Aucun 0-0 au programme',
      );
    }

    if (noTwoGoalGames == 0 && n >= 3) {
      stats.add(
        '🤐 Défenses en carton • Aucun match à moins de 2 buts',
      );
    }

    if (closeGames >= n * 0.7 && n >= 3) {
      stats.add(
        "⚡ Suspense total • $closeGames matchs à un but d'écart",
      );
    }

    // =========================
    // NEGATIVE / FUN
    // =========================

    if (avgGoals <= 2 && n >= 3) {
      stats.add(
        '😴 Attaquants en vacances • ${avgGoals.toStringAsFixed(1)} buts/match',
      );
    }

    if (cleanSheets >= n * 0.7 && n >= 3) {
      stats.add(
        '🧤 Gardiens en feu • $cleanSheets clean sheets',
      );
    }

    if (draws >= n * 0.6 && n >= 3) {
      stats.add(
        '🤝 Impossible de se départager • $draws matchs nuls',
      );
    }

    if (avg != null && avg <= 5.0 && n >= 3) {
      stats.add(
        '📉 Semaine décevante • ${avg.toStringAsFixed(1)}/10 de moyenne',
      );
    }

    if (badMatches >= 2) {
      stats.add(
        '💀 Quelques purges au programme • $badMatches matchs sous 5/10',
      );
    }

    // =========================
    // POSITIVE RATINGS
    // =========================

    if (greatMatches >= 3) {
      stats.add(
        '🔥 Semaine mémorable • $greatMatches matchs notés 8 ou plus',
      );
    }

    if (avg != null && avg >= 7.5 && n >= 3) {
      stats.add(
        '🌟 Semaine validée • ${avg.toStringAsFixed(1)}/10 de moyenne',
      );
    }

    if (noBadMatches == n && n >= 3) {
      stats.add(
        '🎬 Aucun flop au programme • Tous les matchs notés 7 ou plus',
      );
    }

    // =========================
    // COMPETITIONS
    // =========================

    if (topCompetitionName != null &&
        topCompetitionCount != null &&
        topCompetitionCount >= n * 0.8 &&
        n >= 3) {
      stats.add(
        '🏆 Mode $topCompetitionName activé',
      );
    }

    // =========================
    // FALLBACKS
    // =========================

    if (stats.isEmpty) {
      if (n >= 6) {
        stats.add(
          '📺 Marathon football • $n matchs au programme',
        );
      } else if (totalGoals >= 20) {
        stats.add(
          '⚽ Festival offensif • $totalGoals buts cette semaine',
        );
      } else {
        stats.add(
          '👀 Semaine football validée • $n matchs regardés',
        );
      }
    }

    stats.shuffle();

    return stats;
  }

  String get _weekLabel {
    final fmt = DateFormat('d MMM', 'fr_FR');
    return '${fmt.format(_lastMonday)} - ${fmt.format(_lastSunday)}';
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
              'Récap de la semaine',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: ColorPalette.textPrimary(
            context,
          ),
        ),
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
              color: ColorPalette.accent(context),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Récap de la semaine',
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
                color: ColorPalette.textSecondary(context),
                fontSize: 14,
              ),
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
          Text(
            'Impossible de charger le récap',
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _loading = true);
              _loadData();
            },
            child: Text(
              'Réessayer',
              style: TextStyle(
                color: ColorPalette.accent(context),
              ),
            ),
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
            'Aucun match cette semaine',
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute les matchs que tu regardes\npour voir tes stats ici !',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    return Padding(
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
                        if (d.bestMatches?[_bestMatchIndex] != null) ...[
                          _buildBestMatch(d),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            if (d.topCompetitionName != null) ...[
                              Expanded(
                                child: _buildTopComp(
                                  d,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: _buildStreak(
                                d,
                              ),
                            ),
                          ],
                        ),
                        if (d.weekMvpNames?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          _buildWeekMvp(d),
                        ],
                        const SizedBox(height: 8),
                        Center(child: _buildFunStat(d)),
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
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'Partager mon récap',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_RecapData d) {
    final diff = d.matchCount - d.prevWeekMatchCount;
    final diffColor =
        diff > 0 ? ColorPalette.successLight : ColorPalette.errorLight;
    final diffGoals = d.totalGoals - d.prevWeekGoalCount;
    final diffGoalsColor =
        diffGoals > 0 ? ColorPalette.successLight : ColorPalette.errorLight;
    double? diffRating;
    Color? diffRatingColor;
    if (d.avgRating != null && d.prevWeekAvgRating != null) {
      diffRating = d.avgRating! - d.prevWeekAvgRating!;
      diffRatingColor =
          diffRating > 0 ? ColorPalette.successLight : ColorPalette.errorLight;
    }

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
          // ── Ligne 1 : logo app + dates ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: ColorPalette.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: AppLogos.logoAccent(context, size: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                'ScoreScope',
                style: TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Récap de la semaine : $_weekLabel',
                  style: TextStyle(
                    color: ColorPalette.textPrimaryDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerAvatar(d.userPhoto, d.userName, 28),
              const SizedBox(width: 8),
              Text(
                '@${d.userName}',
                style: const TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${d.totalNbMatches} matchs | ${d.totalNbGoalsAllTime} buts',
                style: TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: ColorPalette.textPrimaryDark.withValues(alpha: 0.2),
              height: 1,
            ),
          ),

          // ── Ligne 3 : stats de la semaine ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildHeaderStat(
                  value: '${d.matchCount}',
                  label:
                      'match${d.matchCount > 1 ? 's' : ''} regardé${d.matchCount > 1 ? 's' : ''}',
                  badge: diff != 0
                      ? _DiffBadge(diff: diff.toDouble(), color: diffColor)
                      : null,
                ),
              ),
              if (d.totalGoals > 0)
                Expanded(
                  child: _buildHeaderStat(
                    value: '${d.totalGoals}',
                    label: 'but${d.totalGoals > 1 ? 's' : ''} vus',
                    badge: diffGoals != 0
                        ? _DiffBadge(
                            diff: diffGoals.toDouble(), color: diffGoalsColor)
                        : null,
                  ),
                ),
              if (d.avgRating != null)
                Expanded(
                  child: _buildHeaderStat(
                    value: roundSmart(d.avgRating!, decimals: 1),
                    label: 'note moyenne',
                    badge: diffRating != null &&
                            diffRatingColor != null &&
                            diffRating != 0
                        ? _DiffBadge(diff: diffRating, color: diffRatingColor)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String value,
    required String label,
    Widget? badge,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: ColorPalette.textPrimaryDark,
              fontSize: 44,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          if (badge != null) ...[const SizedBox(width: 6), badge],
        ],
      ),
      Text(
        label,
        style: TextStyle(
          color: ColorPalette.textPrimaryDark,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    ]);
  }

  Widget _buildBestMatch(_RecapData d) {
    final match = d.bestMatches![_bestMatchIndex];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.border(
            context,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🏆 Meilleur match',
                style: TextStyle(
                  color: ColorPalette.textAccent(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              if (d.bestMatches != null && d.bestMatches!.length > 1)
                Opacity(
                  opacity: _isSharing ? 0 : 1,
                  child: GestureDetector(
                    onTap: () => setState(() => _bestMatchIndex =
                        (_bestMatchIndex + 1) % d.bestMatches!.length),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: ColorPalette.textSecondary(context),
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTeamColumn(
                match.equipeDomicile.logoPath,
                match.equipeDomicile.code ??
                    match.equipeDomicile.nomCourt ??
                    match.equipeDomicile.nom,
                match.scoreEquipeDomicile > match.scoreEquipeExterieur,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${match.scoreEquipeDomicile} – ${match.scoreEquipeExterieur}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorPalette.accentLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ColorPalette.accentLight.withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: Text(
                        '${d.bestMatchRating}/10',
                        style: TextStyle(
                          color: ColorPalette.accent(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTeamColumn(
                match.equipeExterieur.logoPath,
                match.equipeExterieur.code ??
                    match.equipeExterieur.nomCourt ??
                    match.equipeExterieur.nom,
                match.scoreEquipeExterieur > match.scoreEquipeDomicile,
                rightAlign: true,
              ),
            ],
          ),
          if (d.bestMatchesMvpName != null &&
              d.bestMatchesMvpName?[_bestMatchIndex] != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                if (d.bestMatchesMvpPhoto?[_bestMatchIndex] != null ||
                    d.bestMatchesMvpName![_bestMatchIndex].isNotEmpty) ...[
                  _buildPlayerAvatar(d.bestMatchesMvpPhoto?[_bestMatchIndex],
                      d.bestMatchesMvpName![_bestMatchIndex], 28),
                  const SizedBox(width: 8),
                  Text(
                    'MVP : ',
                    style: TextStyle(
                      color: ColorPalette.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    d.bestMatchesMvpName![_bestMatchIndex],
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                Spacer(),
                Text(
                  d.bestMatchesVisionnage?[_bestMatchIndex].emoji ?? '',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamColumn(String? logoPath, String code, bool isWinner,
      {bool rightAlign = false}) {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          logoPath != null
              ? CachedNetworkImage(
                  imageUrl: logoPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Icon(Icons.shield,
                      color: ColorPalette.textSecondary(context), size: 36),
                )
              : Icon(Icons.shield,
                  color: ColorPalette.textSecondary(context), size: 36),
          const SizedBox(height: 4),
          Text(
            code,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isWinner
                  ? ColorPalette.accent(context)
                  : ColorPalette.textSecondary(context),
              fontSize: 11,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekMvp(_RecapData d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.border(
            context,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildPlayerAvatar(
              d.weekMvpPhotos?[_MVPIndex], d.weekMvpNames![_MVPIndex], 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MVP de la semaine',
                  style: TextStyle(
                    color: ColorPalette.textAccent(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.weekMvpNames![_MVPIndex],
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (d.weekMvpNames != null && d.weekMvpNames!.length > 1) ...[
            Opacity(
              opacity: _isSharing ? 0 : 1,
              child: GestureDetector(
                onTap: () => setState(
                    () => _MVPIndex = (_MVPIndex + 1) % d.weekMvpNames!.length),
                child: Icon(
                  Icons.refresh_rounded,
                  color: ColorPalette.textSecondary(context),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ColorPalette.accentLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorPalette.accentLight.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Text(
              '${d.weekMvpVoteCounts![_MVPIndex]}x',
              style: TextStyle(
                  color: ColorPalette.accent(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopComp(_RecapData d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.border(
            context,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏅 Compétition préférée',
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (d.topCompetitionLogo != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorPalette.logoBackground(context),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: CachedNetworkImage(
                    imageUrl: d.topCompetitionLogo!,
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(Icons.emoji_events,
                        color: ColorPalette.accent(context), size: 26),
                  ),
                )
              else
                Icon(Icons.emoji_events,
                    color: ColorPalette.accent(context), size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.topCompetitionName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${d.topCompetitionCount} match${(d.topCompetitionCount ?? 0) > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: ColorPalette.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreak(_RecapData d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.border(
            context,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 Série',
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${d.streak}',
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'semaines\nconsécutives',
                  style: TextStyle(
                    color: ColorPalette.textSecondary(context),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunStat(_RecapData d) {
    final stats = d.funStats;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stats[_funStatIndex],
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontSize: 13,
              ),
            ),
          ),
        ),
        if (stats.length > 1 && !_isSharing) ...[
          SizedBox(width: 8),
          Opacity(
            opacity: _isSharing ? 0 : 1,
            child: GestureDetector(
              onTap: () => setState(
                  () => _funStatIndex = (_funStatIndex + 1) % stats.length),
              child: Icon(
                Icons.refresh_rounded,
                color: ColorPalette.textSecondary(context),
                size: 18,
              ),
            ),
          ),
        ],
      ],
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
            width: 1,
          ),
        ),
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
            children: logos.map((logo) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  logo['asset']!,
                  width: 14,
                  height: 14,
                  fit: BoxFit.contain,
                ),
              );
            }).toList(),
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
    if (name.isEmpty) {
      return SizedBox.shrink();
    }
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorPalette.accentLight.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorPalette.accentLight.withValues(
            alpha: 0.4,
          ),
        ),
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
        final file = File('${tempDir.path}/scorescope_recap.png');
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: '''
Voici mon récap foot de la semaine !⚽📊

Découvrez le votre, téléchargez @ScoreScopeApp !
''',
        );
      } catch (e) {
        debugPrint('Erreur partage recap : $e');
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    });
  }
}

class _DiffBadge extends StatelessWidget {
  final double diff;
  final Color color;

  const _DiffBadge({required this.diff, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        '${diff > 0 ? '+' : ''}${roundSmart(diff, decimals: 1)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
