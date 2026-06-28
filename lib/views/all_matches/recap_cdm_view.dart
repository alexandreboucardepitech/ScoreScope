import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/utils/date/get_date_format.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:collection/collection.dart';

List<String> equipesCoupeDuMonde2026 = [
  "16",
  "1531",
  "17",
  "770",
  "5529",
  "1113",
  "1569",
  "15",
  "6",
  "31",
  "2386",
  "1108",
  "2384",
  "2380",
  "20",
  "777",
  "25",
  "5530",
  "1501",
  "2382",
  "1118",
  "12",
  "5",
  "28",
  "1",
  "32",
  "22",
  "4673",
  "9",
  "1533",
  "23",
  "7",
  "2",
  "13",
  "1567",
  "1090",
  "26",
  "1532",
  "775",
  "1548",
  "27",
  "1508",
  "1568",
  "8",
  "10",
  "3",
  "1504",
  "11",
];

dynamic noirEtBlanc = ColorFilter.matrix(
  <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],
);

class _WorldCupColorPalette {
  static const Color purple = Color(0xFF8B2FFF);
  static const Color lavender = Color(0xFFB57FEE);
  static const Color skyBlue = Color(0xFF29A8E0);
  static const Color cyan = Color(0xFF4DFFD2);
  static const Color green = Color(0xFF00D563);
  static const Color lime = Color(0xFFC8E600);
  static const Color teal = Color(0xFF00CC88);
  static const Color pink = Color(0xFFE91E8C);
  static const Color hotPink = Color(0xFFFF1A90);
  static const Color gold = Color(0xFFFFD700);
  static const Color yellow = Color(0xFFE8FF00);
  static const Color crimson = Color(0xFFFF2244);

  static const Color text = Color(0xFFF8F4FF);
  static const Color textDim = Color(0x99F8F4FF);
}

class _CardTheme {
  final Color bg1, bg2, accent, accent2;
  const _CardTheme(this.bg1, this.bg2, this.accent, this.accent2);
}

List<_CardTheme> _themes = [
  _CardTheme(Color(0xFF060A14), Color(0xFF0D1628), _WorldCupColorPalette.gold,
      _WorldCupColorPalette.yellow),
  _CardTheme(Color(0xFF0D0025), Color(0xFF200055), _WorldCupColorPalette.purple,
      _WorldCupColorPalette.lavender),
  _CardTheme(Color(0xFF001A0E), Color(0xFF003020), _WorldCupColorPalette.teal,
      _WorldCupColorPalette.cyan),
  _CardTheme(Color(0xFF001028), Color(0xFF002A60),
      _WorldCupColorPalette.skyBlue, _WorldCupColorPalette.cyan),
  _CardTheme(Color(0xFF001A12), Color(0xFF003A28), _WorldCupColorPalette.green,
      _WorldCupColorPalette.lime),
  _CardTheme(Color(0xFF1A0020), Color(0xFF400040), _WorldCupColorPalette.pink,
      _WorldCupColorPalette.hotPink),
  _CardTheme(Color(0xFF050508), Color(0xFF0A0A22), _WorldCupColorPalette.gold,
      _WorldCupColorPalette.yellow),
  _CardTheme(
    Color(0xFF0E0A12),
    Color(0xFF1D1129),
    Color(0xFFBB74E7),
    Color(0xFFE1C2F4),
  ),
];

class _MvpStat {
  final String name;
  final String? photo;
  final int votes;
  const _MvpStat(this.name, this.photo, this.votes);
}

class _TeamStat {
  final String name;
  final String? logoUrl;
  final int count;
  const _TeamStat(this.name, this.logoUrl, this.count);
}

class _TeamMatch {
  final MatchModel match;
  final int? note;
  final AppUser? watchedWith;
  final Joueur? mvpVoted;
  const _TeamMatch(this.match, this.note, {this.watchedWith, this.mvpVoted});
}

class _JourneyMatch {
  final MatchModel match;
  final int? note;
  final bool favourite;
  final bool isKnockout;
  const _JourneyMatch(this.match, this.note,
      {required this.favourite, required this.isKnockout});
}

class _PathMatch {
  final MatchModel match;
  final bool seen;
  final int? userNote;
  final Joueur? userMvpVoted;

  const _PathMatch(this.match,
      {required this.seen, this.userNote, this.userMvpVoted});

  double? get globalAvgRating {
    final n = match.notes;
    if (n.isEmpty) return null;
    return n.values.reduce((a, b) => a + b) / n.length;
  }

  String? get noteDisplay => userNote != null
      ? '$userNote'
      : globalAvgRating != null
          ? globalAvgRating!.toStringAsFixed(1)
          : null;
}

class _FanBadge {
  final String emoji;
  final String name;
  final String description;
  const _FanBadge(this.emoji, this.name, this.description);
}

class _CdmData {
  final int matchCount;
  final int totalGoals;
  final double? avgRating;
  final String userName;
  final String? userPhoto;
  // Card 2
  final List<_TeamStat> topTeams;
  final List<_MvpStat> top3Mvp;
  final int percentWatched;
  // Card 3 — Parcours
  final List<_JourneyMatch> journeyMatches;
  final List<_PathMatch> pathMatches;
  // Card 4 — Équipe
  final String? heartTeamName;
  final String? heartTeamLogo;
  final List<_TeamMatch> heartTeamMatches;
  // Card 5 — Matchs
  final MatchModel? bestMatch;
  final int? bestMatchRating;
  final Joueur? bestMatchMvpVoted;
  final Joueur? bestMatchGlobalMvp;
  final double? bestMatchGlobalRating;
  final bool bestMatchFavourite;
  final MatchModel? worstMatch;
  final int? worstMatchRating;
  final Joueur? worstMatchMvpVoted;
  final Joueur? worstMatchGlobalMvp;
  final double? worstMatchGlobalRating;
  final bool worstMatchFavourite;
  final double? avgGoalsPerMatch;
  final int groupStageCount;
  final int knockoutCount;
  final Map<int, int> ratingDistribution;
  // Card 6 — Fun
  final int nationsCount;
  final int nightMatchCount;
  final int percentKnockoutWatched;
  final List<({DateTime day, int count})> matchesPerDay;
  // Card finale
  final List<MatchModel> bestMatches;
  final List<int> bestMatchRatings;
  final List<Joueur?> bestMatchesMvpVoted;
  final List<Joueur?> bestMatchesGlobalMvp;
  final List<double?> bestMatchesGlobalRating;
  final List<bool> bestMatchesFavourite;
  final List<Equipe> equipesVues;
  final List<_MvpStat> topMvpList;
  final int streakDays;
  final int rituelPercent;

  const _CdmData({
    required this.matchCount,
    required this.totalGoals,
    this.avgRating,
    required this.userName,
    this.userPhoto,
    required this.topTeams,
    required this.top3Mvp,
    required this.percentWatched,
    required this.journeyMatches,
    required this.pathMatches,
    this.heartTeamName,
    this.heartTeamLogo,
    required this.heartTeamMatches,
    this.bestMatch,
    this.bestMatchRating,
    this.bestMatchMvpVoted,
    this.bestMatchGlobalMvp,
    this.bestMatchGlobalRating,
    this.bestMatchFavourite = false,
    this.worstMatch,
    this.worstMatchRating,
    this.worstMatchMvpVoted,
    this.worstMatchGlobalMvp,
    this.worstMatchGlobalRating,
    this.worstMatchFavourite = false,
    this.avgGoalsPerMatch,
    this.streakDays = 0,
    this.rituelPercent = 0,
    required this.groupStageCount,
    required this.knockoutCount,
    required this.ratingDistribution,
    required this.nationsCount,
    required this.nightMatchCount,
    required this.percentKnockoutWatched,
    required this.matchesPerDay,
    required this.bestMatches,
    required this.bestMatchRatings,
    required this.bestMatchesMvpVoted,
    required this.bestMatchesGlobalMvp,
    required this.bestMatchesGlobalRating,
    required this.bestMatchesFavourite,
    required this.equipesVues,
    required this.topMvpList,
  });
}

class _GlobalCdmStats {
  final int totalMatchesPlayed;
  final int totalGoals;
  final double? avgRating;
  final int totalRatings;
  final int totalMvpVotes;
  final int uniqueUsers;
  final MatchModel? bestMatch;
  final double? bestMatchAvgRating;
  final Joueur? bestMatchMvp;
  final List<_MvpStat> topMvpPodium;
  final List<({AppUser user, int matchCount})> topWatchers;

  const _GlobalCdmStats({
    required this.totalMatchesPlayed,
    required this.totalGoals,
    this.avgRating,
    required this.totalRatings,
    required this.totalMvpVotes,
    required this.uniqueUsers,
    this.bestMatch,
    this.bestMatchAvgRating,
    this.bestMatchMvp,
    required this.topMvpPodium,
    required this.topWatchers,
  });
}

class RecapCdmView extends StatefulWidget {
  const RecapCdmView({super.key});
  @override
  State<RecapCdmView> createState() => _RecapCdmViewState();
}

class _RecapCdmViewState extends State<RecapCdmView>
    with TickerProviderStateMixin {
  static final DateTime _cdmStart = DateTime(2026, 6, 11);
  static final DateTime _cdmEnd = DateTime(2026, 7, 20);
  static final DateTime _knockoutStart = DateTime(2026, 6, 28, 12);
  static const int _totalMatches = 104;
  static const int _totalKnockoutMatches = 32;
  static const int _totalPages = 8;
  _GlobalCdmStats? _globalStats;

  bool _loading = true;
  String? _error;
  _CdmData? _data;
  String _loadingStep = translate.chargement;
  List<Equipe> _toutesLesEquipes = [];

  final _pageController = PageController();
  int _currentPage = 0;

  late final List<AnimationController> _cardAnims;
  final List<GlobalKey> _shareKeys = List.generate(
    _totalPages,
    (_) => GlobalKey(),
  );
  bool _isSharing = false;
  int _finaleMatchIndex = 0;
  int _finaleMvpIndex = 0;

  @override
  void initState() {
    super.initState();
    _cardAnims = List.generate(
      _totalPages,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _cardAnims) c.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _cardAnims[page].reset();
    _cardAnims[page].forward();
  }

  Widget _logoCdm({double size = 48}) => CachedNetworkImage(
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/scorescope-5a12b.firebasestorage.app/o/competitions%2F2026_FIFA_World_Cup.png?alt=media&token=c76f3094-2aa0-4e09-8e17-0ecbe89ab027',
        width: size,
        height: size,
        errorWidget: (_, __, ___) => Text(
          '🏆',
          style: TextStyle(fontSize: size * 0.7),
        ),
      );

  Joueur? _findJoueurInMatch(String? id, MatchModel match) {
    if (id == null) return null;
    final all = [
      ...match.joueursEquipeDomicile,
      ...match.joueursEquipeExterieur
    ];
    return all.where((j) => j.joueur?.id == id).firstOrNull?.joueur;
  }

  double? _globalAvgRating(MatchModel match) {
    final notes = match.notes;
    if (notes.isEmpty) return null;
    return notes.values.reduce((a, b) => a + b) / notes.length;
  }

  Future<void> _loadData() async {
    try {
      // await _debugBadgeDistribution();
      final user = RepositoryProvider.userRepository.currentUser;
      if (user == null) throw Exception(translate.utilisateurNonConnecte);

      setState(() => _loadingStep = translate.recuperationDesMatchsCDM);
      final muds =
          await RepositoryProvider.userRepository.fetchUserAllMatchUserData(
        userId: user.uid,
        dateRange: DateTimeRange(start: _cdmStart, end: _cdmEnd),
      );

      setState(() => _loadingStep = translate.chargementDesDetails);
      final matchDetails = await Future.wait(
        muds.map(
          (m) => RepositoryProvider.matchRepository.fetchMatchById(m.matchId),
        ),
      );

      final pairs = <({MatchUserData mud, MatchModel match})>[];
      for (int i = 0; i < muds.length; i++) {
        final m = matchDetails[i];
        if (m != null && m.competition.id == '1') {
          pairs.add(
            (mud: muds[i], match: m),
          );
        }
      }

      if (pairs.isEmpty) {
        setState(() {
          _data = _CdmData(
            matchCount: 0,
            totalGoals: 0,
            userName: user.displayName,
            userPhoto: user.photoUrl,
            topTeams: [],
            top3Mvp: [],
            percentWatched: 0,
            journeyMatches: [],
            pathMatches: [],
            heartTeamMatches: [],
            groupStageCount: 0,
            knockoutCount: 0,
            ratingDistribution: {},
            nationsCount: 0,
            nightMatchCount: 0,
            percentKnockoutWatched: 0,
            matchesPerDay: [],
            bestMatches: [],
            bestMatchRatings: [],
            equipesVues: [],
            topMvpList: [],
            bestMatchesFavourite: [],
            bestMatchesGlobalMvp: [],
            bestMatchesGlobalRating: [],
            bestMatchesMvpVoted: [],
          );
          _loading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() => _loadingStep = translate.calculDesStatistiques);
      final partial = _compute(pairs, user);

      if (!mounted) return;
      setState(() => _loadingStep = translate.donneesSocialesEtMvp);
      final heartWithWT =
          await _enrichHeartTeamMatches(partial.heartTeamMatches, user.uid);

      Joueur? bestGlobalMvp, worstGlobalMvp;
      Joueur? bestMvpVoted, worstMvpVoted;
      double? bestGlobalRating, worstGlobalRating;
      bool bestFav = false, worstFav = false;

      final bestMatchesMvpVoted = <Joueur?>[];
      final bestMatchesGlobalMvp = <Joueur?>[];
      final bestMatchesGlobalRating = <double?>[];
      final bestMatchesFavourite = <bool>[];

      for (final match in partial.bestMatches) {
        final matchPair =
            pairs.where((p) => p.match.id == match.id).firstOrNull;
        if (matchPair != null) {
          bestMatchesFavourite.add(matchPair.mud.favourite);
          bestMatchesGlobalRating.add(
            _globalAvgRating(matchPair.match),
          );
          bestMatchesMvpVoted.add(
            _findJoueurInMatch(matchPair.mud.mvpVoteId, matchPair.match),
          );
          try {
            bestMatchesGlobalMvp.add(
              matchPair.match.getMvp(),
            );
          } catch (_) {
            bestMatchesGlobalMvp.add(null);
          }
        } else {
          bestMatchesFavourite.add(false);
          bestMatchesGlobalRating.add(null);
          bestMatchesMvpVoted.add(null);
          bestMatchesGlobalMvp.add(null);
        }
      }

      if (partial.bestMatch != null) {
        final bp =
            pairs.where((p) => p.match.id == partial.bestMatch!.id).firstOrNull;
        if (bp != null) {
          bestFav = bp.mud.favourite;
          bestGlobalRating = _globalAvgRating(bp.match);
          bestMvpVoted = _findJoueurInMatch(bp.mud.mvpVoteId, bp.match);
          try {
            bestGlobalMvp = bp.match.getMvp();
          } catch (_) {}
        }
      }
      if (partial.worstMatch != null &&
          partial.worstMatch!.id != partial.bestMatch?.id) {
        final wp = pairs
            .where((p) => p.match.id == partial.worstMatch!.id)
            .firstOrNull;
        if (wp != null) {
          worstFav = wp.mud.favourite;
          worstGlobalRating = _globalAvgRating(wp.match);
          worstMvpVoted = _findJoueurInMatch(wp.mud.mvpVoteId, wp.match);
          try {
            worstGlobalMvp = wp.match.getMvp();
          } catch (_) {}
        }
      }

      if (!mounted) return;
      setState(() => _loadingStep = translate.chargementDuParcoursComplet);
      List<_PathMatch> pathMatches = [];
      try {
        final allMatches =
            await RepositoryProvider.matchRepository.fetchMatchesByCompetition(
          '1',
          DateTimeRange(start: _cdmStart, end: _cdmEnd),
        );

        allMatches.sort(
          (a, b) => a.date.compareTo(b.date),
        );

        final seenMap = <String, ({int? note, Joueur? mvp})>{};
        for (final p in pairs) {
          seenMap[p.match.id] = (
            note: p.mud.note?.toInt(),
            mvp: _findJoueurInMatch(p.mud.mvpVoteId, p.match),
          );
        }

        final now = DateTime.now();
        pathMatches = allMatches.where((m) => !m.date.isAfter(now)).map((m) {
          final ud = seenMap[m.id];
          return _PathMatch(m,
              seen: ud != null, userNote: ud?.note, userMvpVoted: ud?.mvp);
        }).toList();

        setState(() => _loadingStep = translate.chargementDesStatsScoreScope);
        _globalStats = await _computeGlobalStats(allMatches);
      } catch (e) {
        debugPrint('Parcours complet erreur: $e');
        pathMatches = pairs
            .map((p) => _PathMatch(p.match,
                seen: true,
                userNote: p.mud.note?.toInt(),
                userMvpVoted: _findJoueurInMatch(p.mud.mvpVoteId, p.match)))
            .toList()
          ..sort(
            (a, b) => a.match.date.compareTo(b.match.date),
          );
      }

      final finalData = _CdmData(
        matchCount: partial.matchCount,
        totalGoals: partial.totalGoals,
        avgRating: partial.avgRating,
        userName: partial.userName,
        userPhoto: partial.userPhoto,
        topTeams: partial.topTeams,
        top3Mvp: partial.top3Mvp,
        percentWatched: partial.percentWatched,
        journeyMatches: partial.journeyMatches,
        pathMatches: pathMatches,
        heartTeamName: partial.heartTeamName,
        heartTeamLogo: partial.heartTeamLogo,
        heartTeamMatches: heartWithWT,
        bestMatch: partial.bestMatch,
        bestMatchRating: partial.bestMatchRating,
        bestMatchMvpVoted: bestMvpVoted,
        bestMatchGlobalMvp: bestGlobalMvp,
        bestMatchGlobalRating: bestGlobalRating,
        bestMatchFavourite: bestFav,
        worstMatch: partial.worstMatch,
        worstMatchRating: partial.worstMatchRating,
        worstMatchMvpVoted: worstMvpVoted,
        worstMatchGlobalMvp: worstGlobalMvp,
        worstMatchGlobalRating: worstGlobalRating,
        worstMatchFavourite: worstFav,
        avgGoalsPerMatch: partial.avgGoalsPerMatch,
        groupStageCount: partial.groupStageCount,
        knockoutCount: partial.knockoutCount,
        ratingDistribution: partial.ratingDistribution,
        nationsCount: partial.nationsCount,
        nightMatchCount: partial.nightMatchCount,
        percentKnockoutWatched: partial.percentKnockoutWatched,
        matchesPerDay: partial.matchesPerDay,
        bestMatches: partial.bestMatches,
        bestMatchRatings: partial.bestMatchRatings,
        bestMatchesMvpVoted: bestMatchesMvpVoted,
        bestMatchesGlobalMvp: bestMatchesGlobalMvp,
        bestMatchesGlobalRating: bestMatchesGlobalRating,
        bestMatchesFavourite: bestMatchesFavourite,
        equipesVues: partial.equipesVues,
        topMvpList: partial.topMvpList,
        streakDays: partial.streakDays,
        rituelPercent: partial.rituelPercent,
      );

      List<Equipe> toutesLesEquipesChargees = [];

      for (String equipeId in equipesCoupeDuMonde2026) {
        Equipe? equipeDejaCree = partial.equipesVues.firstWhereOrNull(
          (element) => element.id == equipeId,
        );
        if (equipeDejaCree != null)
          toutesLesEquipesChargees.add(equipeDejaCree);
        else {
          Equipe? equipe = await RepositoryProvider.equipeRepository
              .fetchEquipeById(equipeId);
          if (equipe != null) toutesLesEquipesChargees.add(equipe);
        }
      }

      if (!mounted) return;
      setState(() {
        _data = finalData;
        _toutesLesEquipes = toutesLesEquipesChargees;
        _loading = false;
      });
      _cardAnims[0].forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<List<_TeamMatch>> _enrichHeartTeamMatches(
      List<_TeamMatch> matches, String userId) async {
    final result = <_TeamMatch>[];
    await Future.wait(
      matches.map((tm) async {
        AppUser? watchedWith;
        try {
          final wts = await RepositoryProvider.watchTogetherRepository
              .getFriendsWatchedWith(userId, tm.match.id);
          final accepted = wts.where((w) => w.status == 'accepted').toList();
          if (accepted.isNotEmpty) {
            watchedWith = await RepositoryProvider.userRepository
                .fetchUserById(accepted.first.friendId);
          }
        } catch (_) {}
        result.add(
          _TeamMatch(tm.match, tm.note,
              watchedWith: watchedWith, mvpVoted: tm.mvpVoted),
        );
      }),
    );
    result.sort(
      (a, b) => a.match.date.compareTo(b.match.date),
    );
    return result;
  }

  Future<_GlobalCdmStats?> _computeGlobalStats(
      List<MatchModel> allMatches) async {
    if (allMatches.isEmpty) return null;

    int totalGoals = 0;
    int totalRatings = 0;
    double ratingSum = 0;
    int totalMvpVotes = 0;
    final globalMvpCount = <String, int>{};
    final userMatchCount = <String, int>{};

    final totalMatchesPlayed =
        allMatches.where((m) => (m.isScheduled == false)).length;

    for (final m in allMatches) {
      totalGoals += m.scoreEquipeDomicile + m.scoreEquipeExterieur;

      for (final entry in m.notes.entries) {
        totalRatings++;
        ratingSum += (entry.value as num).toDouble();
      }

      for (final entry in m.mvpVotes.entries) {
        totalMvpVotes++;
        globalMvpCount[entry.value] = (globalMvpCount[entry.value] ?? 0) + 1;
      }

      final engagedUsers = <String>{
        ...m.notes.keys,
        ...m.mvpVotes.keys,
      };
      for (final uid in engagedUsers) {
        userMatchCount[uid] = (userMatchCount[uid] ?? 0) + 1;
      }
    }

    final avgRating = totalRatings > 0 ? ratingSum / totalRatings : null;
    final uniqueUsers = userMatchCount.length;

    MatchModel? bestMatch;
    double? bestMatchAvgRating;
    for (final m in allMatches) {
      if (m.notes.length < 3) continue;
      final avg =
          m.notes.values.fold(0.0, (a, b) => a + (b as num).toDouble()) /
              m.notes.length;
      if (bestMatchAvgRating == null || avg > bestMatchAvgRating) {
        bestMatchAvgRating = avg;
        bestMatch = m;
      }
    }

    final sortedMvp = globalMvpCount.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );
    final topMvpList = <_MvpStat>[];
    for (final entry in sortedMvp.take(3)) {
      Joueur? joueur;
      outer:
      for (final m in allMatches) {
        final all = [...m.joueursEquipeDomicile, ...m.joueursEquipeExterieur];
        for (final mj in all) {
          if (mj.joueur?.id == entry.key) {
            joueur = mj.joueur;
            break outer;
          }
        }
      }
      topMvpList.add(
        _MvpStat(
          joueur?.fullName ?? translate.joueurInconnu,
          joueur?.picture,
          entry.value,
        ),
      );
    }

    final sortedUsers = userMatchCount.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );
    final topWatchers = <({AppUser user, int matchCount})>[];
    for (final entry in sortedUsers.take(3)) {
      try {
        final user =
            await RepositoryProvider.userRepository.fetchUserById(entry.key);
        if (user != null) {
          topWatchers.add(
            (user: user, matchCount: entry.value),
          );
        }
      } catch (_) {}
    }

    Joueur? bestMatchMvp;
    if (bestMatch != null) {
      try {
        bestMatchMvp = bestMatch.getMvp();
      } catch (_) {}
    }

    return _GlobalCdmStats(
      totalMatchesPlayed: totalMatchesPlayed,
      totalGoals: totalGoals,
      avgRating: avgRating,
      totalRatings: totalRatings,
      totalMvpVotes: totalMvpVotes,
      uniqueUsers: uniqueUsers,
      bestMatch: bestMatch,
      bestMatchAvgRating: bestMatchAvgRating,
      bestMatchMvp: bestMatchMvp,
      topMvpPodium: topMvpList,
      topWatchers: topWatchers,
    );
  }

  _FanBadge _computeBadge(_CdmData d) {
    final int maxMatchesInDay = d.matchesPerDay.isEmpty
        ? 0
        : d.matchesPerDay.map((e) => e.count).reduce(math.max);

    double? heartWinRate;
    if (d.heartTeamMatches.length >= 3 && d.heartTeamName != null) {
      int wins = 0;
      for (final tm in d.heartTeamMatches) {
        final isHome = tm.match.equipeDomicile.nom == d.heartTeamName;
        final ourScore = isHome
            ? tm.match.scoreEquipeDomicile
            : tm.match.scoreEquipeExterieur;
        final oppScore = isHome
            ? tm.match.scoreEquipeExterieur
            : tm.match.scoreEquipeDomicile;
        if (ourScore > oppScore) wins++;
      }
      heartWinRate = wins / d.heartTeamMatches.length;
    }

    // ── Bloc 1 : ultra-rares ─────────────────────────────────────────────────
    if (d.matchCount >= 90) {
      return _FanBadge('🏃', translate.leMarathonien,
          translate.xMatchsRegardesSurX('${d.matchCount}', '$_totalMatches'));
    }
    if (d.nightMatchCount >= 30) {
      return _FanBadge('🦉', translate.lInsomniaque,
          translate.xMatchsRegardesApresMinuit('${d.nightMatchCount}'));
    }
    if (maxMatchesInDay >= 4) {
      return _FanBadge('🤯', translate.jourDeFolie,
          translate.xMatchsVusEnUneSeuleJournee('$maxMatchesInDay'));
    }

    // ── Bloc 2 : personnalité ────────────────────────────────────────────────
    if ((d.avgGoalsPerMatch ?? 0) > 4) {
      return _FanBadge(
          '💥',
          translate.leFestin,
          translate.xButsEnMoyenneParMatch(
              '${d.avgGoalsPerMatch!.toStringAsFixed(1)}'));
    }
    if ((d.avgGoalsPerMatch ?? 10) < 2 && d.matchCount >= 5) {
      return _FanBadge(
          '🥱',
          translate.ennuyant,
          translate.xButsEnMoyenneParMatch(
              '${d.avgGoalsPerMatch!.toStringAsFixed(1)}'));
    }
    if (heartWinRate != null && heartWinRate >= 0.7) {
      final pct = (heartWinRate * 100).round();
      return _FanBadge(
          '🍀',
          translate.lePorteBonheur,
          translate.xGagneDansXPourcentDesMatchsQueTuRegardes(
              d.heartTeamName ?? translate.tonEquipe, '$pct'));
    }
    if (heartWinRate != null && heartWinRate <= 0.25) {
      final pct = (heartWinRate * 100).round();
      return _FanBadge(
          '🐦‍⬛',
          translate.leCorbeau,
          translate.xNeGagneQueDansXPourcentDesMatchsQueTuRegardes(
              d.heartTeamName ?? translate.tonEquipe, '$pct'));
    }
    if (d.avgRating != null && d.avgRating! < 5.5 && d.matchCount >= 5) {
      return _FanBadge('⚖️', translate.leJugeSevere,
          translate.noteMoyenneDeXSur10('${d.avgRating!.toStringAsFixed(1)}'));
    }
    if ((d.avgRating ?? 0) >= 7.5 && d.matchCount >= 5) {
      return _FanBadge('🌟', translate.lEnthousiaste,
          translate.noteMoyenneDeXSur10('${d.avgRating!.toStringAsFixed(1)}'));
    }
    if (d.rituelPercent >= 70 && d.matchCount >= 5) {
      return _FanBadge(
          '📅',
          translate.leRituel,
          translate
              .xPourcentDesTesMatchsRegardesALaMemeHeure('${d.rituelPercent}'));
    }

    // ── Bloc 3 : volume / diversité ──────────────────────────────────────────
    if (d.nationsCount >= 42) {
      return _FanBadge('🌍', translate.leCitoyenDuMonde,
          translate.xEquipesDifferentesSuiviesSur48('${d.nationsCount}'));
    }
    if (d.streakDays >= 14) {
      return _FanBadge('⚡', translate.lInarretable,
          translate.xJoursConsecutifsAvecAuMoinsUnMatch('${d.streakDays}'));
    }
    if (d.heartTeamMatches.length >= 5) {
      return _FanBadge(
          '❤️‍🔥',
          translate.lUltra,
          translate.xMatchsSuivisPourEquipe('${d.heartTeamMatches.length}',
              d.heartTeamName ?? translate.tonEquipe));
    }
    if (d.percentKnockoutWatched >= 70) {
      return _FanBadge(
          '💎',
          translate.lePuriste,
          translate.xPourcentDesMatchsEliminationDirecteSuivis(
              '${d.percentKnockoutWatched}'));
    }
    if (d.streakDays >= 7) {
      return _FanBadge('🔥', translate.leSansPause,
          translate.xJoursConsecutifsAvecAuMoinsUnMatch('${d.streakDays}'));
    }
    if (d.nationsCount >= 24) {
      return _FanBadge('🔭', translate.lExplorateur,
          translate.xEquipesDifferentesSuiviesSur48('${d.nationsCount}'));
    }
    if (d.matchCount >= 40) {
      return _FanBadge('📺', translate.leBoulimique,
          translate.xMatchsRegardesSurY('${d.matchCount}', '$_totalMatches'));
    }
    if (d.nightMatchCount >= 10) {
      return _FanBadge('🌙', translate.leCoucheTard,
          translate.xMatchsRegardesApresMinuit('${d.nightMatchCount}'));
    }
    if (d.matchCount >= 20) {
      return _FanBadge('📅', translate.lAssidu,
          translate.xMatchsRegardesSurY('${d.matchCount}', '$_totalMatches'));
    }
    if (d.topTeams.isNotEmpty && d.topTeams.first.count >= 3) {
      return _FanBadge(
          '🏴',
          translate.lePartisan,
          translate.xMatchsSuivisPourEquipe(
              '${d.topTeams.first.count}', d.topTeams.first.name));
    }

    // ── Bloc 4 : fallback ────────────────────────────────────────────────────
    return _FanBadge('⚽', translate.leSupporter,
        translate.lesSupporterDescription('${d.matchCount}', '$_totalMatches'));
  }

  // Future<void> _debugBadgeDistribution() async {
  //   debugPrint('═══════════════════════════════════════');
  //   debugPrint('🔍 BADGE DISTRIBUTION — DÉBUT');
  //   debugPrint('═══════════════════════════════════════');

  //   final users = await RepositoryProvider.userRepository.fetchAllUsers();
  //   debugPrint('👥 ${users.length} utilisateurs trouvés\n');

  //   final badgeCount = <String, int>{};
  //   int skipped = 0;

  //   for (final user in users) {
  //     try {
  //       final muds =
  //           await RepositoryProvider.userRepository.fetchUserAllMatchUserData(
  //         userId: user.uid,
  //         dateRange: DateTimeRange(start: _cdmStart, end: _cdmEnd),
  //       );

  //       final matchDetails = await Future.wait(
  //         muds.map(
  //           (m) => RepositoryProvider.matchRepository.fetchMatchById(m.matchId),
  //         ),
  //       );

  //       final pairs = <({MatchUserData mud, MatchModel match})>[];
  //       for (int i = 0; i < muds.length; i++) {
  //         final m = matchDetails[i];
  //         if (m != null && m.competition.id == '1') {
  //           pairs.add(
  //             (mud: muds[i], match: m),
  //           );
  //         }
  //       }

  //       if (pairs.isEmpty) {
  //         skipped++;
  //         debugPrint('⚪ ${user.displayName} — aucun match CdM');
  //         continue;
  //       }

  //       final data = _compute(pairs, user);
  //       final badge = _computeBadge(data);

  //       badgeCount[badge.name] = (badgeCount[badge.name] ?? 0) + 1;

  //       debugPrint('${badge.emoji} ${user.displayName} → ${badge.name} '
  //           '(${data.matchCount} matchs)');
  //     } catch (e) {
  //       skipped++;
  //       debugPrint('❌ ${user.displayName} — erreur : $e');
  //     }
  //   }

  //   // Résumé final
  //   final total = users.length - skipped;
  //   debugPrint('\n═══════════════════════════════════════');
  //   debugPrint('📊 RÉSUMÉ ($total users avec données CdM, $skipped ignorés)');
  //   debugPrint('═══════════════════════════════════════');

  //   final sorted = badgeCount.entries.toList()
  //     ..sort(
  //       (a, b) => b.value.compareTo(a.value),
  //     );

  //   for (final entry in sorted) {
  //     final pct =
  //         total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
  //     final bar = '█' * (entry.value * 20 ~/ (total > 0 ? total : 1));
  //     debugPrint('${entry.key.padRight(22)} $bar  ${entry.value} ($pct%)');
  //   }

  //   debugPrint('═══════════════════════════════════════\n');
  // }

  _CdmData _compute(
      List<({MatchUserData mud, MatchModel match})> pairs, AppUser user) {
    final matchCount = pairs.length;

    int totalGoals = 0;
    for (final p in pairs) {
      totalGoals += p.match.scoreEquipeDomicile + p.match.scoreEquipeExterieur;
    }

    final rated = pairs.where((p) => p.mud.note != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.map((p) => p.mud.note!).reduce((a, b) => a + b) / rated.length;

    final teamCount = <String, int>{};
    final teamName = <String, String>{};
    final teamLogo = <String, String?>{};
    List<Equipe> equipesVues = [];
    List<String> equipesIdVus = [];
    for (final p in pairs) {
      for (final eq in [p.match.equipeDomicile, p.match.equipeExterieur]) {
        teamCount[eq.id] = (teamCount[eq.id] ?? 0) + 1;
        teamName[eq.id] = eq.nom;
        teamLogo[eq.id] = eq.logoPath;
        if (equipesIdVus.contains(eq.id) == false) {
          equipesVues.add(eq);
          equipesIdVus.add(eq.id);
        }
      }
    }
    final sortedTeams = teamCount.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );
    final topTeams = sortedTeams
        .take(5)
        .map(
            (e) => _TeamStat(teamName[e.key]!, teamLogo[e.key], e.value.ceil()))
        .toList();

    final mvpVotes = <String, int>{};
    for (final p in pairs) {
      if (p.mud.mvpVoteId != null) {
        mvpVotes[p.mud.mvpVoteId!] = (mvpVotes[p.mud.mvpVoteId!] ?? 0) + 1;
      }
    }
    final topMvpList = <_MvpStat>[];
    final top3Mvp = <_MvpStat>[];
    if (mvpVotes.isNotEmpty) {
      final sorted = mvpVotes.entries.toList()
        ..sort(
          (a, b) => b.value.compareTo(a.value),
        );
      final maxVotes = sorted.first.value;
      int count = 0;
      for (final entry in sorted) {
        Joueur? joueur;
        for (final p in pairs) {
          final mj = [
            ...p.match.joueursEquipeDomicile,
            ...p.match.joueursEquipeExterieur
          ].where((j) => j.joueur?.id == entry.key).firstOrNull;
          if (mj != null) {
            joueur = mj.joueur;
            break;
          }
        }
        if (entry.value == maxVotes) {
          topMvpList.add(
            _MvpStat(joueur?.fullName ?? translate.joueurInconnu,
                joueur?.picture, entry.value),
          );
        }
        if (count < 3) {
          top3Mvp.add(
            _MvpStat(joueur?.fullName ?? translate.joueurInconnu,
                joueur?.picture, entry.value),
          );
        }
        count++;
      }
    }

    String? heartTeamId;
    final preferredIds = user.equipesPrefereesId.toSet();
    for (final entry in sortedTeams) {
      if (preferredIds.contains(entry.key)) {
        heartTeamId = entry.key;
        break;
      }
    }
    heartTeamId ??= sortedTeams.isNotEmpty ? sortedTeams.first.key : null;

    final heartTeamMatches = <_TeamMatch>[];
    String? heartTeamName, heartTeamLogo;
    if (heartTeamId != null) {
      heartTeamName = teamName[heartTeamId];
      heartTeamLogo = teamLogo[heartTeamId];
      for (final p in pairs) {
        if (p.match.equipeDomicile.id == heartTeamId ||
            p.match.equipeExterieur.id == heartTeamId) {
          final mvpVoted = _findJoueurInMatch(p.mud.mvpVoteId, p.match);
          heartTeamMatches.add(
            _TeamMatch(p.match, p.mud.note, mvpVoted: mvpVoted),
          );
        }
      }
      heartTeamMatches.sort(
        (a, b) => a.match.date.compareTo(b.match.date),
      );
    }

    MatchModel? bestMatch, worstMatch;
    int? bestMatchRating, worstMatchRating;
    final bestMatches = <MatchModel>[];
    final bestMatchRatings = <int>[];
    if (rated.isNotEmpty) {
      final sortedRated = [...rated]..sort(
          (a, b) => b.mud.note!.compareTo(a.mud.note!),
        );
      final maxNote = sortedRated.first.mud.note!;
      for (final p in sortedRated.where((p) => p.mud.note == maxNote)) {
        bestMatches.add(p.match);
        bestMatchRatings.add(p.mud.note!);
      }
      bestMatch = sortedRated.first.match;
      bestMatchRating = sortedRated.first.mud.note;
      if (sortedRated.length > 1 &&
          sortedRated.last.mud.matchId != sortedRated.first.mud.matchId) {
        worstMatch = sortedRated.last.match;
        worstMatchRating = sortedRated.last.mud.note;
      }
    }

    final journeyMatches = pairs
        .map((p) => _JourneyMatch(
              p.match,
              p.mud.note,
              favourite: p.mud.favourite,
              isKnockout: !p.match.date.isBefore(_knockoutStart),
            ))
        .toList()
      ..sort(
        (a, b) => a.match.date.compareTo(b.match.date),
      );

    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 10; i++) ratingDistribution[i] = 0;
    for (final jm in journeyMatches) {
      if (jm.note != null && jm.note! >= 1 && jm.note! <= 10) {
        ratingDistribution[jm.note!] = (ratingDistribution[jm.note!] ?? 0) + 1;
      }
    }

    int groupStageCount = 0, knockoutCount = 0;
    for (final p in pairs) {
      if (p.match.date.isBefore(_knockoutStart))
        groupStageCount++;
      else
        knockoutCount++;
    }

    final nations = <String>{};
    for (final p in pairs) {
      nations.add(p.match.equipeDomicile.nom);
      nations.add(p.match.equipeExterieur.nom);
    }

    int nightCount = 0;
    for (final p in pairs) {
      if (p.match.date.hour < 6) nightCount++;
    }

    final dayCount = <DateTime, int>{};
    for (final p in pairs) {
      final d =
          DateTime(p.match.date.year, p.match.date.month, p.match.date.day);
      dayCount[d] = (dayCount[d] ?? 0) + 1;
    }
    List<({int count, DateTime day})> matchesPerDay = [];

    DateTime date = DateTime(_cdmStart.year, _cdmStart.month, _cdmStart.day);

    while (date.compareTo(_cdmEnd) <= 0) {
      matchesPerDay.add(
        (day: date, count: dayCount[date] ?? 0),
      );
      date = date.add(
        Duration(days: 1),
      );
    }

    final watchedDays = pairs
        .map((p) {
          final d = p.match.date;
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList()
      ..sort();

    int streakDays = watchedDays.isEmpty ? 0 : 1;
    int currentStreak = 1;
    for (int i = 1; i < watchedDays.length; i++) {
      if (watchedDays[i]
              .difference(
                watchedDays[i - 1],
              )
              .inDays ==
          1) {
        currentStreak++;
        if (currentStreak > streakDays) streakDays = currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    int rituelPercent = 0;
    if (pairs.length >= 5) {
      final hourCount = <int, int>{};
      for (final p in pairs) {
        final h = p.match.date.hour;
        hourCount[h] = (hourCount[h] ?? 0) + 1;
      }
      final maxHourCount = hourCount.values.reduce(math.max);
      rituelPercent = (maxHourCount / pairs.length * 100).round();
    }

    return _CdmData(
      matchCount: matchCount,
      totalGoals: totalGoals,
      avgRating: avgRating,
      userName: user.displayName,
      userPhoto: user.photoUrl,
      topTeams: topTeams,
      top3Mvp: top3Mvp,
      percentWatched: (matchCount / _totalMatches * 100).round(),
      journeyMatches: journeyMatches,
      ratingDistribution: ratingDistribution,
      pathMatches: [],
      heartTeamName: heartTeamName,
      heartTeamLogo: heartTeamLogo,
      heartTeamMatches: heartTeamMatches,
      bestMatch: bestMatch,
      bestMatchRating: bestMatchRating,
      bestMatchMvpVoted: null,
      bestMatchGlobalMvp: null,
      bestMatchGlobalRating: null,
      bestMatchFavourite: false,
      worstMatch: worstMatch,
      worstMatchRating: worstMatchRating,
      worstMatchMvpVoted: null,
      worstMatchGlobalMvp: null,
      worstMatchGlobalRating: null,
      worstMatchFavourite: false,
      avgGoalsPerMatch: matchCount > 0 ? totalGoals / matchCount : null,
      groupStageCount: groupStageCount,
      knockoutCount: knockoutCount,
      nationsCount: nations.length,
      nightMatchCount: nightCount,
      percentKnockoutWatched: knockoutCount > 0
          ? (knockoutCount / _totalKnockoutMatches * 100).round()
          : 0,
      matchesPerDay: matchesPerDay,
      bestMatches: bestMatches,
      bestMatchRatings: bestMatchRatings,
      bestMatchesMvpVoted: [],
      bestMatchesGlobalMvp: [],
      bestMatchesGlobalRating: [],
      bestMatchesFavourite: [],
      equipesVues: equipesVues,
      topMvpList: topMvpList,
      streakDays: streakDays,
      rituelPercent: rituelPercent,
    );
  }

  Future<void> _shareCard(int pageIndex) async {
    setState(() => _isSharing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final boundary = _shareKeys[pageIndex]
            .currentContext
            ?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        final pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/scorescope_cdm_card$pageIndex.png');
        await file.writeAsBytes(pngBytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: translate.maCoupeDuMonde2026AvecScoreScope,
        );
      } catch (e) {
        debugPrint('Erreur partage : $e');
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _WorldCupColorPalette.text),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppLogos.logoAccent(context, size: 28))
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _data!.matchCount == 0
                  ? _buildEmpty()
                  : _buildWrapped(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
                valueColor:
                    const AlwaysStoppedAnimation(_WorldCupColorPalette.gold),
                strokeWidth: 3,
                backgroundColor:
                    _WorldCupColorPalette.gold.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 24),
          _logoCdm(size: 40),
          const SizedBox(height: 10),
          Text(_loadingStep,
              style: const TextStyle(
                  color: _WorldCupColorPalette.textDim, fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              color: _WorldCupColorPalette.crimson, size: 48),
          const SizedBox(height: 12),
          Text(
            translate.erreurDeChargement,
            style: TextStyle(color: _WorldCupColorPalette.text, fontSize: 16),
          ),
          TextButton(
            onPressed: () {
              setState(() => _loading = true);
              _loadData();
            },
            child: Text(translate.reessayer,
                style: TextStyle(color: _WorldCupColorPalette.gold)),
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
          _logoCdm(size: 72),
          const SizedBox(height: 20),
          Text(
            translate.aucunMatchCDMEnregistre,
            style: TextStyle(
                color: _WorldCupColorPalette.text,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            translate.ajouteLesMatchsQueTuRegardesPourVoirTonRecap,
            textAlign: TextAlign.center,
            style: TextStyle(color: _WorldCupColorPalette.textDim),
          ),
        ],
      ),
    );
  }

  Widget _buildWrapped() {
    return Column(
      children: [
        const SizedBox(height: 96),
        _buildPageIndicator(),
        const SizedBox(height: 6),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _buildPage(
                0,
                _buildCard1(_data!),
              ),
              _buildPage(
                1,
                _buildCard2(_data!),
              ),
              _buildPage(
                2,
                _buildCard3Parcours(_data!),
              ),
              _buildPage(
                3,
                _buildCard4Equipe(_data!),
              ),
              _buildPage(
                4,
                _buildCard5Matchs(_data!),
              ),
              _buildPage(
                5,
                _buildCard6Fun(_data!),
              ),
              _buildPage(6, _buildCardFinale(_data!, _toutesLesEquipes),
                  showWatermark: false),
              _buildPage(7, _buildCard8ScoreScope(_globalStats),
                  showWatermark: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage(int idx, Widget cardContent, {bool showWatermark = true}) {
    final theme = _themes[idx];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _shareKeys[idx],
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    cardContent,
                    if (showWatermark)
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: _watermark(theme),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _shareButton(idx, theme),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _watermark(_CardTheme theme) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogos.logoAccent(context, size: 13),
          const SizedBox(width: 4),
          Text(
            'scorescope',
            style: TextStyle(
                color: theme.accent.withValues(alpha: 0.55),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
        ],
      );

  Widget _shareButton(int idx, _CardTheme theme) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSharing ? null : () => _shareCard(idx),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accent,
            foregroundColor: Colors.black,
            disabledBackgroundColor: theme.accent.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: _isSharing
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black.withValues(alpha: 0.6)))
              : const Icon(Icons.share_rounded, size: 18),
          label: Text(
            _isSharing ? translate.preparation : translate.partager,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );

  Widget _buildPageIndicator() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (i) {
          final active = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
                color: active ? _themes[i].accent : Colors.white24,
                borderRadius: BorderRadius.circular(4)),
          );
        }),
      );

  Widget _buildCard1(_CdmData d) {
    final t = _themes[0];
    final anim =
        CurvedAnimation(parent: _cardAnims[0], curve: Curves.easeOutCubic);

    return _Shell(
      t,
      Stack(
        children: [
          _orb(200, t.accent, 0.08, top: -60, right: -40),
          _orb(120, t.accent2, 0.07, bottom: 60, left: -30),
          _orb(60, _WorldCupColorPalette.teal, 0.06, top: 180, left: 40),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _logoCdm(size: 56),
                      Container(
                        width: 1.5,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        color:
                            _WorldCupColorPalette.text.withValues(alpha: 0.15),
                      ),
                      AppLogos.logoAccent(context, size: 56),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    translate.taCoupeDuMonde,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            _WorldCupColorPalette.text.withValues(alpha: 0.7),
                        fontSize: 18,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [t.accent, t.accent2],
                    ).createShader(b),
                    child: Text(translate.avecScoreScope,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 52),
                  AnimatedBuilder(
                      animation: anim,
                      builder: (context, _) {
                        final mVal = (anim.value * d.matchCount).round();
                        final gProg = ((anim.value - 0.45) * 2).clamp(0.0, 1.0);
                        final gVal = (gProg * d.totalGoals).round();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _heroCounter(
                                value: '$mVal',
                                label: translate.matchsRegardes,
                                color: t.accent),
                            Container(
                              width: 1,
                              height: 80,
                              color: _WorldCupColorPalette.text
                                  .withValues(alpha: 0.12),
                            ),
                            _heroCounter(
                                value: '$gVal',
                                label: translate.butsVus,
                                color: t.accent2),
                          ],
                        );
                      }),
                  const SizedBox(height: 52),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_right_rounded,
                          color: _WorldCupColorPalette.text
                              .withValues(alpha: 0.25),
                          size: 14),
                      const SizedBox(width: 6),
                      Text(
                        translate.swipePourDecouvrir,
                        style: TextStyle(
                            color: _WorldCupColorPalette.text
                                .withValues(alpha: 0.25),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard2(_CdmData d) {
    final t = _themes[1];
    final anim =
        CurvedAnimation(parent: _cardAnims[1], curve: Curves.easeOutCubic);

    return _Shell(
      t,
      Stack(
        children: [
          _orb(180, t.accent, 0.10, top: -50, right: -50),
          _orb(100, t.accent2, 0.07, bottom: 60, left: -30),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(translate.taCoupeDuMonde2026, t.accent),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                          animation: anim,
                          builder: (context, _) {
                            final mVal = (anim.value * d.matchCount).round();
                            final gVal =
                                ((math.max(0.0, anim.value - 0.3) / 0.7) *
                                        d.totalGoals)
                                    .round();
                            return Row(
                              children: [
                                Expanded(
                                  child: _bigStat(
                                      '$mVal', translate.matchsVus, t.accent),
                                ),
                                Expanded(
                                  child: _bigStat(
                                      '$gVal', translate.butsVus, t.accent2),
                                ),
                                if (d.avgRating != null)
                                  Expanded(
                                    child: _bigStat(
                                        d.avgRating!.toStringAsFixed(1),
                                        translate.noteMoy,
                                        t.accent2),
                                  ),
                              ],
                            );
                          }),
                      const SizedBox(height: 14),
                      AnimatedBuilder(
                          animation: anim,
                          builder: (context, _) {
                            final fill =
                                (anim.value * d.matchCount / _totalMatches)
                                    .clamp(0.0, 1.0);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      d.percentWatched.toString(),
                                      style: TextStyle(
                                          color: t.accent,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          height: 1),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      translate.pourcentDesMatchsRegardes,
                                      style: const TextStyle(
                                          color: _WorldCupColorPalette.textDim,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: SizedBox(
                                    height: 14,
                                    child: Stack(
                                      children: [
                                        Container(color: Colors.white10),
                                        FractionallySizedBox(
                                          widthFactor: fill,
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  t.accent2
                                                      .withValues(alpha: 0.6),
                                                  t.accent,
                                                  _WorldCupColorPalette.crimson,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                      const SizedBox(height: 20),
                      _label(translate.equipesLesPlusSuivies, t.accent2),
                      const SizedBox(height: 10),
                      ...d.topTeams.asMap().entries.map((e) {
                        final team = e.value;
                        final isTop3 = e.key < 3;
                        final rankColor = [
                          t.accent,
                          t.accent2,
                          _WorldCupColorPalette.text.withValues(alpha: 0.8),
                          _WorldCupColorPalette.text.withValues(alpha: 0.6),
                          _WorldCupColorPalette.text.withValues(alpha: 0.45),
                        ][e.key];
                        final rankLabel = isTop3
                            ? ['🥇', '🥈', '🥉'][e.key]
                            : '${e.key + 1}.';
                        final barFill = d.topTeams.isEmpty
                            ? 0.0
                            : team.count / d.topTeams.first.count;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  rankLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: isTop3 ? 16 : 13,
                                      color: rankColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (team.logoUrl != null)
                                CachedNetworkImage(
                                    imageUrl: team.logoUrl!,
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) => const Icon(
                                        Icons.shield,
                                        color: Colors.white38,
                                        size: 26))
                              else
                                const Icon(Icons.shield,
                                    color: Colors.white38, size: 26),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team.name,
                                      style: TextStyle(
                                          color: rankColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedBuilder(
                                      animation: anim,
                                      builder: (context, _) => ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                              value: anim.value * barFill,
                                              backgroundColor: Colors.white12,
                                              color: rankColor,
                                              minHeight: 3)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${team.count}',
                                style: TextStyle(
                                    color: rankColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (d.top3Mvp.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _label(translate.mvpLesPlusVotes, t.accent),
                        const SizedBox(height: 12),
                        _mvpPodium(d.top3Mvp),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _mvpPodium(List<_MvpStat> mvps) {
    final colors = [
      _WorldCupColorPalette.gold,
      Colors.white70,
      const Color(0xFFCD7F32)
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: mvps.asMap().entries.map((e) {
        final isFirst = e.key == 0;
        final size = isFirst ? 56.0 : 44.0;
        final mvp = e.value;
        return SizedBox(
          width: 90,
          height: isFirst ? 130 : 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _avatar(mvp.photo, mvp.name, size),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors[e.key].withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: colors[e.key].withValues(alpha: 0.4)),
                ),
                child: Text('${mvp.votes}x',
                    style: TextStyle(
                        color: colors[e.key],
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Text(
                _shortName(mvp.name),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _WorldCupColorPalette.text,
                    fontSize: isFirst ? 12 : 10,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard3Parcours(_CdmData d) {
    final t = _themes[2];

    final effectiveMatches = d.pathMatches.isNotEmpty
        ? d.pathMatches
        : d.journeyMatches
            .map((jm) => _PathMatch(jm.match, seen: true, userNote: jm.note))
            .toList();

    if (effectiveMatches.isEmpty) {
      return _Shell(
        t,
        Center(
          child: Text(
            translate.aucunMatchAAfficher,
            style: TextStyle(color: _WorldCupColorPalette.textDim),
          ),
        ),
      );
    }

    return _Shell(
      t,
      Stack(
        children: [
          _orb(160, t.accent, 0.1, top: -40, right: -40),
          _orb(80, t.accent2, 0.08, bottom: 100, left: -20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _label(translate.tonParcours, t.accent),
                    const SizedBox(height: 2),
                    Text(
                      '${translate.xMatchsVus(d.matchCount.toString())} · '
                      '${translate.xMatchsDePoules(d.groupStageCount.toString())} · '
                      '${translate.xPhaseFinale(d.knockoutCount.toString())}',
                      style: TextStyle(
                          color: _WorldCupColorPalette.textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: t.accent.withValues(alpha: 0.25),
              ),
              Expanded(
                child: _PathGrid(
                  matches: effectiveMatches,
                  accent: t.accent,
                  accent2: t.accent2,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD 4 — Équipe de cœur
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCard4Equipe(_CdmData d) {
    final t = _themes[3];
    if (d.heartTeamName == null || d.heartTeamMatches.isEmpty) {
      return _Shell(
        t,
        Center(
            child: Text(translate.pasAssezDeDonneesPourLEquipeDeCoeur,
                textAlign: TextAlign.center,
                style: TextStyle(color: _WorldCupColorPalette.textDim))),
      );
    }
    return _Shell(
      t,
      Stack(
        children: [
          if (d.heartTeamLogo != null)
            Positioned(
              right: -40,
              top: 40,
              child: Opacity(
                  opacity: 0.06,
                  child: CachedNetworkImage(
                      imageUrl: d.heartTeamLogo!,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain)),
            ),
          _orb(120, t.accent, 0.1, top: -40, left: -40),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                child: Row(
                  children: [
                    if (d.heartTeamLogo != null)
                      CachedNetworkImage(
                          imageUrl: d.heartTeamLogo!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => const Icon(Icons.shield,
                              color: _WorldCupColorPalette.skyBlue, size: 52))
                    else
                      const Icon(Icons.shield,
                          color: _WorldCupColorPalette.skyBlue, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(translate.tonEquipeMaj, t.accent),
                          const SizedBox(height: 2),
                          ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                              colors: [t.accent, t.accent2],
                            ).createShader(b),
                            child: Text(d.heartTeamName!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text(
                            translate.xMatchsRegardes(
                                d.heartTeamMatches.length.toString()),
                            style: TextStyle(
                                color: _WorldCupColorPalette.textDim,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: t.accent.withValues(alpha: 0.25),
              ),
              Expanded(
                child: _HeartTeamMatchList(
                    matches: d.heartTeamMatches,
                    teamName: d.heartTeamName!,
                    accent: t.accent,
                    accent2: t.accent2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingBarsBlock(_CdmData d, Color accent, Animation<double> anim) {
    if (!d.ratingDistribution.values.any((v) => v > 0)) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.repartitionDesNotes,
            style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: anim,
            builder: (context, _) =>
                _ratingBars(d.ratingDistribution, accent, anim.value),
          ),
        ],
      ),
    );
  }

  Widget _ratingBars(Map<int, int> dist, Color accent, double progress) {
    const double maxBarH = 50.0;
    const double minBarH = 2.0;

    final maxVal = dist.values.reduce(math.max).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(10, (i) {
              final note = i + 1;
              final count = dist[note] ?? 0;
              final isBest = count > 0 && count == maxVal.toInt();
              final showLabel = count > 0 && progress > 0.8;

              final double h = count == 0
                  ? minBarH * progress
                  : (count / maxVal * maxBarH * progress)
                      .clamp(minBarH + 1, maxBarH);

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showLabel)
                      Text(
                        '${count}x',
                        style: TextStyle(
                          color:
                              isBest ? accent : accent.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      )
                    else
                      const SizedBox(height: 11),
                    const SizedBox(height: 2),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: h,
                      decoration: BoxDecoration(
                        color: count == 0
                            ? accent.withValues(alpha: 0.15)
                            : isBest
                                ? accent
                                : accent.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            10,
            (i) => Expanded(
              child: Text(
                '${i + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD 5 — Les matchs (enrichie)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCard5Matchs(_CdmData d) {
    final t = _themes[4];
    final anim =
        CurvedAnimation(parent: _cardAnims[4], curve: Curves.easeOutCubic);

    return _Shell(
      t,
      Stack(
        children: [
          _orb(160, t.accent, 0.10, bottom: -30, right: -30),
          _orb(80, t.accent2, 0.08, top: 40, left: -20),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label(translate.tesMatchs, t.accent),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                          animation: anim,
                          builder: (context, _) {
                            final g = (anim.value * d.groupStageCount).round();
                            final k = (anim.value * d.knockoutCount).round();
                            return Row(
                              children: [
                                Expanded(
                                  child: _tileStat(
                                      '$g',
                                      translate.matchsDePoules,
                                      t.accent,
                                      Icons.groups),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _tileStat('$k', translate.phaseFinale,
                                      t.accent2, Icons.emoji_events),
                                ),
                                if (d.avgGoalsPerMatch != null) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _tileStat(
                                        d.avgGoalsPerMatch!.toStringAsFixed(1),
                                        translate.butsParMatch,
                                        _WorldCupColorPalette.lime,
                                        Icons.sports_soccer),
                                  ),
                                ],
                              ],
                            );
                          }),
                      if (d.bestMatch != null) ...[
                        const SizedBox(height: 20),
                        _label(translate.tonMeilleurMatch, t.accent),
                        const SizedBox(height: 8),
                        _richMatchCard(
                            match: d.bestMatch!,
                            rating: d.bestMatchRating,
                            mvpVoted: d.bestMatchMvpVoted,
                            globalMvp: d.bestMatchGlobalMvp,
                            globalRating: d.bestMatchGlobalRating,
                            favourite: d.bestMatchFavourite,
                            accent: t.accent,
                            isBest: true),
                      ],
                      if (d.worstMatch != null) ...[
                        const SizedBox(height: 12),
                        _label(translate.tonPireMatch, Colors.white38),
                        const SizedBox(height: 8),
                        _richMatchCard(
                            match: d.worstMatch!,
                            rating: d.worstMatchRating,
                            mvpVoted: d.worstMatchMvpVoted,
                            globalMvp: d.worstMatchGlobalMvp,
                            globalRating: d.worstMatchGlobalRating,
                            favourite: d.worstMatchFavourite,
                            accent: Colors.white38,
                            isBest: false),
                      ],
                      const SizedBox(height: 10),
                      _ratingBarsBlock(d, t.accent, anim),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _richMatchCard({
    required MatchModel match,
    required int? rating,
    required Joueur? mvpVoted,
    required Joueur? globalMvp,
    required double? globalRating,
    required bool favourite,
    required Color accent,
    required bool isBest,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _teamCol(
                  match.equipeDomicile.logoPath,
                  match.equipeDomicile.code ?? match.equipeDomicile.nom,
                  match.scoreEquipeDomicile > match.scoreEquipeExterieur,
                  accent),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                      style: TextStyle(
                          color: _WorldCupColorPalette.text,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (rating != null) _ratingBadge('$rating/10', accent),
                        if (favourite) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _WorldCupColorPalette.gold
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(translate.favori,
                                style: TextStyle(
                                    color: _WorldCupColorPalette.gold,
                                    fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _teamCol(
                  match.equipeExterieur.logoPath,
                  match.equipeExterieur.code ?? match.equipeExterieur.nom,
                  match.scoreEquipeExterieur > match.scoreEquipeDomicile,
                  accent),
            ],
          ),
          if (mvpVoted != null || globalMvp != null) ...[
            const SizedBox(height: 10),
            Divider(color: accent.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                if (mvpVoted != null)
                  Expanded(
                    child: _mvpMiniLine(mvpVoted, translate.tonMvp, accent),
                  ),
                if (mvpVoted != null && globalMvp != null)
                  Container(
                    width: 1,
                    height: 36,
                    color: accent.withValues(alpha: 0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                if (globalMvp != null)
                  Expanded(
                    child: _mvpMiniLine(
                      globalMvp,
                      translate.mvpGlobal,
                      _WorldCupColorPalette.gold,
                    ),
                  ),
              ],
            ),
          ],
          if (globalRating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  translate.noteGlobale + ' : ',
                  style: TextStyle(
                      color: _WorldCupColorPalette.textDim, fontSize: 11),
                ),
                Text(
                  globalRating.toStringAsFixed(1),
                  style: TextStyle(
                      color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '/10',
                  style: TextStyle(
                      color: _WorldCupColorPalette.textDim, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _mvpMiniLine(Joueur joueur, String label, Color color) {
    return Row(
      children: [
        if (joueur.picture.isNotEmpty)
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                  imageUrl: joueur.picture,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      _initialsCircle(joueur.fullName, 24, color)))
        else
          _initialsCircle(joueur.fullName, 24, color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: _WorldCupColorPalette.textDim, fontSize: 10),
              ),
              Text(_shortName(joueur.fullName),
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ratingBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      );

  Widget _teamCol(String? logoPath, String code, bool wins, Color accent) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          _teamLogo(logoPath, 34),
          const SizedBox(height: 4),
          Text(
            code,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: wins ? accent : _WorldCupColorPalette.textDim,
                fontWeight: wins ? FontWeight.bold : FontWeight.normal,
                fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD 6 — Fun stats spectaculaires
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCard6Fun(_CdmData d) {
    final t = _themes[5];
    final anim =
        CurvedAnimation(parent: _cardAnims[5], curve: Curves.easeOutCubic);

    return _Shell(
      t,
      Stack(
        children: [
          _orb(200, t.accent, 0.10, top: -70, right: -60),
          _orb(100, t.accent2, 0.08, bottom: 20, left: -30),
          _orb(60, _WorldCupColorPalette.gold, 0.06, top: 200, right: 30),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label(translate.funStats, t.accent),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedBuilder(
                      animation: anim,
                      builder: (context, _) {
                        final nations = (anim.value * d.nationsCount).round();
                        final nights = (anim.value * d.nightMatchCount).round();
                        final cnt = (anim.value * d.matchCount).round();
                        return Column(
                          children: [
                            Expanded(
                              child: _spectacularStat(
                                  emoji: '🌍',
                                  value: '$nations',
                                  label: translate.nationsDifferentesSuivies,
                                  color: t.accent),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _spectacularStat(
                                  emoji: '🌙',
                                  value: '$nights',
                                  label: translate.matchsRegardesLaNuit,
                                  color: t.accent2),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _spectacularStat(
                                  emoji: '📊',
                                  value: '${d.percentWatched}%',
                                  label: translate
                                      .desMatchsRegardes('$cnt/$_totalMatches'),
                                  color: _WorldCupColorPalette.gold),
                            ),
                          ],
                        );
                      }),
                ),
                if (d.matchesPerDay.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _dayChartBlock(
                    d.matchesPerDay,
                    t.accent,
                    CurvedAnimation(
                        parent: _cardAnims[5], curve: Curves.easeOut),
                  ),
                ],
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _spectacularStat(
      {required String emoji,
      required String value,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
                color: color,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _WorldCupColorPalette.textDim,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _dayChartBlock(List<({DateTime day, int count})> data, Color accent,
      Animation<double> anim) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.matchsRegardesParJour,
            style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: anim,
            builder: (context, _) => _dayBars(data, accent, anim.value),
          ),
        ],
      ),
    );
  }

  Widget _dayBars(
      List<({DateTime day, int count})> data, Color accent, double progress) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal = data.map((d) => d.count).reduce(math.max).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              double h = maxVal > 0 ? (d.count / maxVal * 50 * progress) : 0.0;
              if (d.count == 0) h = 2;
              final isBest = d.count == maxVal.toInt();
              final showLabel = d.count >= 2 && progress > 0.8;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showLabel)
                      Text(
                        '${d.count}',
                        style: TextStyle(
                          color:
                              isBest ? accent : accent.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      )
                    else
                      const SizedBox(height: 11),
                    const SizedBox(height: 2),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      height: h,
                      decoration: BoxDecoration(
                        color: isBest ? accent : accent.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('d MMM', getDateFormat()).format(_cdmStart),
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
            Text(
              DateFormat('d MMM', getDateFormat()).format(_cdmEnd),
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildlogosNationsVues(_CdmData d, List<Equipe> toutesLesEquipes) {
    final theme = _themes[6];
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const int equipesParLigne = 16;
          const double spacing = 4;

          final double itemSize =
              (constraints.maxWidth - (spacing * (equipesParLigne - 1))) /
                  equipesParLigne;

          return Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    translate.tuAsSuiviXNationsSurX(
                        d.equipesVues.length.toString(),
                        toutesLesEquipes.length.toString()),
                    style: TextStyle(color: theme.accent, fontSize: 12),
                  ),
                ),
              ),
              for (int i = 0; i < toutesLesEquipes.length; i += equipesParLigne)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: spacing,
                  children: toutesLesEquipes.skip(i).take(equipesParLigne).map(
                    (equipe) {
                      final bool equipeVue = d.equipesVues.any(
                        (e) => e.id == equipe.id,
                      );

                      return SizedBox(
                        width: itemSize,
                        height: itemSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ColorFiltered(
                            colorFilter: equipeVue
                                ? const ColorFilter.mode(
                                    Colors.transparent, BlendMode.dst)
                                : noirEtBlanc,
                            child: CachedNetworkImage(
                              imageUrl: equipe.logoPath!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFinaleBadgeCard(_CdmData d, _CardTheme t) {
    final badge = _computeBadge(d);
    final progress = (d.matchCount / _totalMatches).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      decoration: BoxDecoration(
        color: t.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: t.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.tonProfil,
            style: TextStyle(
                color: t.accent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                badge.emoji,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        badge.name,
                        style: const TextStyle(
                            color: _WorldCupColorPalette.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      badge.description,
                      style: const TextStyle(
                          color: _WorldCupColorPalette.textDim,
                          fontSize: 10,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    color: t.accent,
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${d.matchCount}/$_totalMatches',
                style: TextStyle(
                    color: t.accent, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            translate.matchsRegardes,
            style: const TextStyle(
                color: _WorldCupColorPalette.textDim, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildFinaleStreakCard(_CdmData d, _CardTheme t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.accent2.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: t.accent2.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.serieMaj,
            style: TextStyle(
                color: t.accent2,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${d.streakDays}',
                style: TextStyle(
                    color: t.accent2,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  translate.joursConsecutifs,
                  style: const TextStyle(
                      color: _WorldCupColorPalette.textDim,
                      fontSize: 14,
                      height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            translate.avecAuMoinsUnMatchSuivi,
            style: const TextStyle(
                color: _WorldCupColorPalette.textDim,
                fontSize: 10,
                height: 1.4),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD 7 — Finale partageable
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCardFinale(_CdmData d, List<Equipe> toutesLesEquipes) {
    final t = _themes[6];
    final finAnim =
        CurvedAnimation(parent: _cardAnims[6], curve: Curves.easeOutCubic);

    return _Shell(
      t,
      Stack(
        children: [
          _orb(180, t.accent, 0.08, top: -50, right: -50),
          _orb(100, t.accent2, 0.06, bottom: 80, left: -30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    t.accent.withValues(alpha: 0.25),
                    Colors.transparent
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _avatar(d.userPhoto, d.userName, 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${d.userName}',
                                style: const TextStyle(
                                    color: _WorldCupColorPalette.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              Text(
                                translate.coupeDuMonde2026,
                                style: TextStyle(color: t.accent, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        AppLogos.logoAccent(context, size: 30),
                        Container(
                          width: 1.5,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: _WorldCupColorPalette.text
                              .withValues(alpha: 0.15),
                        ),
                        _logoCdm(size: 30),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                        animation: finAnim,
                        builder: (context, _) {
                          final mVal = (finAnim.value * d.matchCount).round();
                          final gVal = (finAnim.value * d.totalGoals).round();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _finStat('$mVal', translate.matchs2, t.accent),
                              const SizedBox(width: 18),
                              _finStat('$gVal', translate.buts2, t.accent2),
                              if (d.avgRating != null) ...[
                                const SizedBox(width: 18),
                                _finStat(
                                    d.avgRating!.toStringAsFixed(1),
                                    translate.noteMoy,
                                    _WorldCupColorPalette.gold),
                              ],
                            ],
                          );
                        }),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _WorldCupColorPalette.gold,
                    Colors.transparent
                  ],
                )),
              ),
              if (d.bestMatches.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            translate.meilleurMatchMaj,
                            style: TextStyle(
                                color: t.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1),
                          ),
                          const Spacer(),
                          if (!_isSharing && d.bestMatches.length > 1)
                            GestureDetector(
                              onTap: () => setState(() => _finaleMatchIndex =
                                  (_finaleMatchIndex + 1) %
                                      d.bestMatches.length),
                              child: Icon(Icons.refresh_rounded,
                                  color: t.accent, size: 18),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _richMatchCard(
                        match: d.bestMatches[_finaleMatchIndex],
                        rating: d.bestMatchRatings.isNotEmpty
                            ? d.bestMatchRatings[math.min(_finaleMatchIndex,
                                d.bestMatchRatings.length - 1)]
                            : null,
                        mvpVoted: d.bestMatchesMvpVoted.isNotEmpty
                            ? d.bestMatchesMvpVoted[math.min(_finaleMatchIndex,
                                d.bestMatchesMvpVoted.length - 1)]
                            : null,
                        globalMvp: d.bestMatchesGlobalMvp.isNotEmpty
                            ? d.bestMatchesGlobalMvp[math.min(_finaleMatchIndex,
                                d.bestMatchesGlobalMvp.length - 1)]
                            : null,
                        globalRating: d.bestMatchesGlobalRating.isNotEmpty
                            ? d.bestMatchesGlobalRating[math.min(
                                _finaleMatchIndex,
                                d.bestMatchesGlobalRating.length - 1)]
                            : null,
                        favourite: d.bestMatchesFavourite.isNotEmpty
                            ? d.bestMatchesFavourite[math.min(_finaleMatchIndex,
                                d.bestMatchesFavourite.length - 1)]
                            : false,
                        accent: t.accent,
                        isBest: true,
                      ),
                    ],
                  ),
                ),
              if (d.topMvpList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _WorldCupColorPalette.gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _WorldCupColorPalette.gold
                              .withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        _avatar(d.topMvpList[_finaleMvpIndex].photo,
                            d.topMvpList[_finaleMvpIndex].name, 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate.mvpDuTournoi,
                                style: TextStyle(
                                    color: _WorldCupColorPalette.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1),
                              ),
                              Text(
                                d.topMvpList[_finaleMvpIndex].name,
                                style: const TextStyle(
                                    color: _WorldCupColorPalette.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${d.topMvpList[_finaleMvpIndex].votes}x',
                          style: const TextStyle(
                              color: _WorldCupColorPalette.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        if (d.topMvpList.length > 1) ...[
                          const SizedBox(width: 10),
                          Opacity(
                            opacity: _isSharing ? 0 : 1,
                            child: GestureDetector(
                              onTap: () => setState(() => _finaleMvpIndex =
                                  (_finaleMvpIndex + 1) % d.topMvpList.length),
                              child: const Icon(Icons.refresh_rounded,
                                  color: _WorldCupColorPalette.gold, size: 18),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildFinaleBadgeCard(d, t),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFinaleStreakCard(d, t),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (toutesLesEquipes.isNotEmpty)
                _buildlogosNationsVues(d, toutesLesEquipes),
              Container(
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.06),
                  border: Border(
                      top: BorderSide(
                          color: t.accent.withValues(alpha: 0.2), width: 1)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                child: Row(
                  children: [
                    AppLogos.logoAccent(context, size: 13),
                    const SizedBox(width: 5),
                    const Text(
                      'scorescope',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    ...[
                      'assets/logos/other/Instagram.png',
                      'assets/logos/other/X.png',
                      'assets/logos/other/AppleStore.png',
                      'assets/logos/other/PlayStore.png'
                    ].map(
                      (a) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Image.asset(a, width: 13, height: 13)),
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

  // ─────────────────────────────────────────────────────────────────────────
  // CARD 8 — ScoreScope × CdM 2026 - Stats communauté
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCard8ScoreScope(_GlobalCdmStats? g) {
    final t = _themes[7];
    final anim =
        CurvedAnimation(parent: _cardAnims[7], curve: Curves.easeOutCubic);

    if (g == null) {
      return _Shell(
        t,
        Center(
            child: Text(translate.statsCommunauteIndisponibles,
                style: TextStyle(color: _WorldCupColorPalette.textDim))),
      );
    }

    return _Shell(
      t,
      Stack(
        children: [
          _orb(200, t.accent, 0.08, top: -60, right: -50),
          _orb(100, t.accent2, 0.06, bottom: 60, left: -30),
          _orb(60, _WorldCupColorPalette.gold, 0.05, top: 180, left: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    t.accent.withValues(alpha: 0.2),
                    Colors.transparent
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppLogos.logoAccent(context, size: 28),
                        Container(
                          width: 1.5,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: _WorldCupColorPalette.text
                              .withValues(alpha: 0.15),
                        ),
                        _logoCdm(size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate.scorescopeRecapDeLaCommunaute,
                                style: TextStyle(
                                    color: t.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2),
                              ),
                              Text(
                                translate.coupeDuMonde2026,
                                style: TextStyle(
                                    color: _WorldCupColorPalette.textDim,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                        animation: anim,
                        builder: (context, _) {
                          final matchs =
                              (anim.value * g.totalMatchesPlayed).round();
                          final buts = (anim.value * g.totalGoals).round();
                          final users = (anim.value * g.uniqueUsers).round();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _finStat('$matchs', translate.matchs2,
                                  ColorPalette.accentLight),
                              const SizedBox(width: 16),
                              _finStat('$buts', translate.buts2, t.accent),
                              const SizedBox(width: 16),
                              if (g.avgRating != null)
                                _finStat(g.avgRating!.toStringAsFixed(1),
                                    translate.noteMoyGlobale, t.accent2),
                              if (g.avgRating != null)
                                const SizedBox(width: 16),
                              _finStat(
                                  '$users', translate.fans, _WorldCupColorPalette.text),
                            ],
                          );
                        }),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.transparent, t.accent, Colors.transparent],
                )),
              ),
              if (g.bestMatch != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(translate.meilleurMatchMaj, t.accent),
                      const SizedBox(height: 8),
                      _globalCompactMatchCard(g.bestMatch!,
                          g.bestMatchAvgRating, g.bestMatchMvp, t.accent),
                    ],
                  ),
                ),
              if (g.topMvpPodium.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(translate.mvpDuTournoi, t.accent2),
                      const SizedBox(height: 8),
                      _globalMvpRow(g.topMvpPodium, t),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.accent.withValues(alpha: 0.2)),
                  ),
                  child: AnimatedBuilder(
                      animation: anim,
                      builder: (context, _) {
                        final notes = (anim.value * g.totalRatings).round();
                        final votes = (anim.value * g.totalMvpVotes).round();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _communauteStat(
                                '$notes', translate.notesDonnees, t.accent),
                            Container(
                              width: 1,
                              height: 36,
                              color: t.accent.withValues(alpha: 0.2),
                            ),
                            _communauteStat('$votes', translate.votesMvp, t.accent2),
                          ],
                        );
                      }),
                ),
              ),
              if (g.topWatchers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(translate.topSpectateurs, t.accent),
                      const SizedBox(height: 8),
                      ...g.topWatchers.asMap().entries.map((e) {
                        final medals = ['🥇', '🥈', '🥉'];
                        final w = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text(
                                medals[e.key],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              _avatar(w.user.photoUrl, w.user.displayName, 28),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(w.user.displayName,
                                    style: const TextStyle(
                                        color: _WorldCupColorPalette.text,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                translate.xMatchs(w.matchCount.toString()),
                                style: TextStyle(
                                    color: t.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.06),
                  border: Border(
                      top: BorderSide(
                          color: t.accent.withValues(alpha: 0.2), width: 1)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                child: Row(
                  children: [
                    AppLogos.logoAccent(context, size: 13),
                    const SizedBox(width: 5),
                    const Text(
                      'scorescope',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    ...[
                      'assets/logos/other/Instagram.png',
                      'assets/logos/other/X.png',
                      'assets/logos/other/AppleStore.png',
                      'assets/logos/other/PlayStore.png'
                    ].map(
                      (a) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Image.asset(a, width: 13, height: 13)),
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

  Widget _globalCompactMatchCard(
      MatchModel match, double? avgRating, Joueur? mvp, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _teamCol(
                  match.equipeDomicile.logoPath,
                  match.equipeDomicile.code ?? match.equipeDomicile.nom,
                  match.scoreEquipeDomicile > match.scoreEquipeExterieur,
                  accent),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                      style: const TextStyle(
                          color: _WorldCupColorPalette.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    if (avgRating != null) ...[
                      const SizedBox(height: 2),
                      _ratingBadge(
                          '★ ${avgRating.toStringAsFixed(1)}/10', accent),
                    ],
                  ],
                ),
              ),
              _teamCol(
                  match.equipeExterieur.logoPath,
                  match.equipeExterieur.code ?? match.equipeExterieur.nom,
                  match.scoreEquipeExterieur > match.scoreEquipeDomicile,
                  accent),
            ],
          ),
          if (mvp != null) ...[
            const SizedBox(height: 8),
            Divider(color: accent.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 6),
            _mvpMiniLine(mvp, translate.mvpDuMatch, _WorldCupColorPalette.gold),
          ],
        ],
      ),
    );
  }

  Widget _globalMvpRow(List<_MvpStat> mvps, _CardTheme t) {
    final medals = ['🥇', '🥈', '🥉'];
    final colors = [
      _WorldCupColorPalette.gold,
      Colors.white70,
      const Color(0xFFCD7F32)
    ];
    return Row(
      children: mvps.asMap().entries.map((e) {
        final mvp = e.value;
        final color = colors[e.key];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: e.key < mvps.length - 1 ? 6 : 0),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  medals[e.key],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                _avatar(mvp.photo, mvp.name, 32),
                const SizedBox(height: 4),
                Text(
                  _shortName(mvp.name),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _WorldCupColorPalette.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  translate.xVoteX(mvp.votes.toString(), mvp.votes > 1 ? 's' : ''),
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _communauteStat(String value, String label, Color color) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _WorldCupColorPalette.textDim,
                fontSize: 10,
                height: 1.3),
          ),
        ],
      );

  // Widget _simpleMatchCard(MatchModel match, int? rating, Color accent) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //         color: accent.withValues(alpha: 0.07),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: accent.withValues(alpha: 0.3)),),
  //     child: Row(children: [
  //       _teamCol(
  //           match.equipeDomicile.logoPath,
  //           match.equipeDomicile.code ?? match.equipeDomicile.nom,
  //           match.scoreEquipeDomicile > match.scoreEquipeExterieur,
  //           accent),
  //       Expanded(
  //           child: Column(children: [
  //         Text('${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
  //             style: TextStyle(
  //                 color: _WorldCupColorPalette.text,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold),),
  //         if (rating != null) ...[
  //           const SizedBox(height: 4),
  //           _ratingBadge('$rating/10', accent),
  //         ],
  //       ],),),
  //       _teamCol(
  //           match.equipeExterieur.logoPath,
  //           match.equipeExterieur.code ?? match.equipeExterieur.nom,
  //           match.scoreEquipeExterieur > match.scoreEquipeDomicile,
  //           accent),
  //     ],),
  //   );
  // }

  Widget _finStat(String value, String label, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
                color: color,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
          Text(
            label,
            style:
                TextStyle(color: _WorldCupColorPalette.textDim, fontSize: 11),
          ),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers visuels communs
  // ─────────────────────────────────────────────────────────────────────────

  Widget _Shell(_CardTheme t, Widget child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [t.bg1, t.bg2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: t.accent.withValues(alpha: 0.3), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );

  Widget _orb(double size, Color color, double opacity,
          {double? top, double? bottom, double? left, double? right}) =>
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: IgnorePointer(
            child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: opacity)))),
      );

  Widget _heroCounter(
          {required String value,
          required String label,
          required Color color}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: [color, color.withValues(alpha: 0.65)],
            ).createShader(b),
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 76,
                    fontWeight: FontWeight.bold,
                    height: 1)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _WorldCupColorPalette.text.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.3),
          ),
        ],
      );

  Widget _bigStat(String value, String label, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
            ).createShader(b),
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    height: 1)),
          ),
          Text(
            label,
            style:
                TextStyle(color: _WorldCupColorPalette.textDim, fontSize: 12),
          ),
        ],
      );

  Widget _tileStat(String value, String label, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  color: _WorldCupColorPalette.textDim,
                  fontSize: 10,
                  height: 1.3),
            ),
          ],
        ),
      );

  Widget _label(String text, Color color) => Text(
        text,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );

  Widget _avatar(String? photoUrl, String name, double size) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
            imageUrl: photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                _initialsCircle(name, size, _WorldCupColorPalette.purple)),
      );
    }
    return _initialsCircle(name, size, _WorldCupColorPalette.purple);
  }

  Widget _initialsCircle(String name, double size, Color color) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(
          child: Text(initials.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.35))),
    );
  }

  Widget _teamLogo(String? logoPath, double size) {
    if (logoPath != null) {
      return CachedNetworkImage(
        imageUrl: logoPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) =>
            Icon(Icons.shield, color: Colors.white38, size: size),
      );
    }
    return Icon(Icons.shield, color: Colors.white38, size: size);
  }

  String _shortName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.length <= 1
        ? fullName
        : '${parts.first[0]}. ${parts.skip(1).join(' ')}';
  }
}

class _PathGrid extends StatefulWidget {
  final List<_PathMatch> matches;
  final Color accent;
  final Color accent2;

  const _PathGrid({
    required this.matches,
    required this.accent,
    required this.accent2,
  });

  @override
  State<_PathGrid> createState() => _PathGridState();
}

class _PathGridState extends State<_PathGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  static const int _cols = 3;
  static const double _connW = 14.0;
  static const double _turnH = 24.0;

  @override
  void initState() {
    super.initState();
    final n = widget.matches.length;
    final ms = (n * 50).clamp(1500, 3000);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _segFill(double progress, int segIdx) =>
      (progress - segIdx).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final matches = widget.matches;
    if (matches.isEmpty) return const SizedBox.shrink();
    final numRows = (matches.length / _cols).ceil();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress =
            CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut).value *
                matches.length;

        final items = <Widget>[];
        for (int r = 0; r < numRows; r++) {
          final isReversed = r.isOdd;
          final startIdx = r * _cols;
          final endIdx = math.min(startIdx + _cols, matches.length);
          final count = endIdx - startIdx;

          items.add(
            _buildRow(
              startIdx: startIdx,
              count: count,
              isReversed: isReversed,
              matches: matches,
              progress: progress,
            ),
          );

          if (r < numRows - 1) {
            items.add(
              _buildTurn(
                isRight: !isReversed,
                fill: _segFill(progress, startIdx + count - 1),
              ),
            );
          }
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          children: items,
        );
      },
    );
  }

  Widget _buildRow({
    required int startIdx,
    required int count,
    required bool isReversed,
    required List<_PathMatch> matches,
    required double progress,
  }) {
    final rowItems = <Widget>[];
    for (int visualPos = 0; visualPos < count; visualPos++) {
      final physIdx = isReversed
          ? startIdx + (count - 1 - visualPos)
          : startIdx + visualPos;

      final m = matches[physIdx];
      final nodeProg = (progress - physIdx + 0.5).clamp(0.0, 1.0);

      rowItems.add(
        Expanded(child: _buildNode(m, nodeProg)),
      );

      if (visualPos < count - 1) {
        final segIdx = isReversed
            ? startIdx + (count - 2 - visualPos)
            : startIdx + visualPos;
        rowItems.add(
          SizedBox(
            width: _connW,
            child: _buildHConn(
              _segFill(progress, segIdx),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowItems,
      ),
    );
  }

  Widget _buildHConn(double fill) {
    return SizedBox(
      width: _connW,
      height: 2,
      child: Stack(
        children: [
          Container(
            width: _connW,
            height: 2,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Container(
            width: _connW * fill,
            height: 2,
            color: widget.accent.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildTurn({required bool isRight, required double fill}) {
    final line = SizedBox(
      width: 2,
      height: _turnH,
      child: Stack(
        children: [
          Container(
            width: 2,
            height: _turnH,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Container(
            width: 2,
            height: _turnH * fill,
            color: widget.accent.withValues(alpha: 0.7),
          ),
        ],
      ),
    );

    final children = <Widget>[];
    if (isRight) {
      for (int i = 0; i < _cols - 1; i++) {
        children.add(
          const Expanded(child: SizedBox.shrink()),
        );
        children.add(
          SizedBox(width: _connW),
        );
      }
      children.add(
        Expanded(child: Center(child: line)),
      );
    } else {
      children.add(
        Expanded(child: Center(child: line)),
      );
      for (int i = 0; i < _cols - 1; i++) {
        children.add(
          SizedBox(width: _connW),
        );
        children.add(
          const Expanded(child: SizedBox.shrink()),
        );
      }
    }

    return SizedBox(
      height: _turnH,
      child: Row(children: children),
    );
  }

  Widget _buildNode(_PathMatch m, double prog) {
    final activated = prog > 0.3;
    final opacity = prog.clamp(0.15, 1.0);
    final scale =
        Curves.elasticOut.transform(prog.clamp(0.0, 1.0)) * 0.25 + 0.75;

    final homeCode = m.match.equipeDomicile.code ??
        m.match.equipeDomicile.nom
            .substring(0, math.min(3, m.match.equipeDomicile.nom.length))
            .toUpperCase();
    final awayCode = m.match.equipeExterieur.code ??
        m.match.equipeExterieur.nom
            .substring(0, math.min(3, m.match.equipeExterieur.nom.length))
            .toUpperCase();

    final homeWins = m.match.scoreEquipeDomicile > m.match.scoreEquipeExterieur;
    final awayWins = m.match.scoreEquipeExterieur > m.match.scoreEquipeDomicile;

    final noteStr = m.noteDisplay;

    final Joueur? mvp = m.seen ? m.userMvpVoted : m.match.getMvp();

    final isSeen = m.seen && activated;
    final accentColor = isSeen ? widget.accent : Colors.white24;
    final textColor = isSeen ? _WorldCupColorPalette.text : Colors.white38;

    Widget logo(String? path, {bool grayscale = false}) {
      Widget img = path != null
          ? CachedNetworkImage(
              imageUrl: path,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) =>
                  Icon(Icons.shield, color: Colors.white38, size: 16))
          : Icon(Icons.shield, color: Colors.white38, size: 16);
      if (grayscale || !m.seen) {
        img = ColorFiltered(colorFilter: noirEtBlanc, child: img);
      }
      return img;
    }

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isSeen
                ? widget.accent.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSeen
                  ? widget.accent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
              width: isSeen ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      logo(m.match.equipeDomicile.logoPath),
                      const SizedBox(width: 2),
                      Text(
                        homeCode,
                        style: TextStyle(
                            color: homeWins ? textColor : Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            height: 1),
                      ),
                    ],
                  ),
                  Text(
                    '${m.match.scoreEquipeDomicile}-'
                    '${m.match.scoreEquipeExterieur}',
                    style: TextStyle(
                        color: isSeen
                            ? _WorldCupColorPalette.text
                            : Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      logo(m.match.equipeExterieur.logoPath),
                      const SizedBox(width: 2),
                      Text(
                        awayCode,
                        style: TextStyle(
                            color: awayWins ? textColor : Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            height: 1),
                      ),
                    ],
                  ),
                ],
              ),
              if (noteStr != null || mvp != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (noteStr != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSeen
                              ? widget.accent.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          m.seen ? '$noteStr/10' : noteStr,
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(width: 4),
                    if (mvp != null)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            mvp.picture.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: mvp.picture,
                                      width: 14,
                                      height: 14,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
                                          Icons.person,
                                          color: accentColor,
                                          size: 12),
                                    ),
                                  )
                                : Icon(Icons.person,
                                    color: accentColor, size: 12),
                            const SizedBox(width: 2),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  mvp.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          isSeen ? accentColor : Colors.white24,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      height: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartTeamMatchList extends StatefulWidget {
  final List<_TeamMatch> matches;
  final String teamName;
  final Color accent, accent2;
  const _HeartTeamMatchList(
      {required this.matches,
      required this.teamName,
      required this.accent,
      required this.accent2});
  @override
  State<_HeartTeamMatchList> createState() => _HeartTeamMatchListState();
}

class _HeartTeamMatchListState extends State<_HeartTeamMatchList> {
  final List<bool> _visible = [];
  @override
  void initState() {
    super.initState();
    _visible.addAll(
      List.filled(widget.matches.length, false),
    );
    _animateIn();
  }

  Future<void> _animateIn() async {
    for (int i = 0; i < widget.matches.length; i++) {
      await Future.delayed(
        const Duration(milliseconds: 110),
      );
      if (mounted) setState(() => _visible[i] = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bestNote = widget.matches.map((m) => m.note ?? 0).fold(0, math.max);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      itemCount: widget.matches.length,
      itemBuilder: (context, i) {
        final tm = widget.matches[i];
        final isHome = tm.match.equipeDomicile.nom == widget.teamName;
        final ourScore = isHome
            ? tm.match.scoreEquipeDomicile
            : tm.match.scoreEquipeExterieur;
        final oppoScore = isHome
            ? tm.match.scoreEquipeExterieur
            : tm.match.scoreEquipeDomicile;
        final opponent =
            isHome ? tm.match.equipeExterieur : tm.match.equipeDomicile;
        final won = ourScore > oppoScore;
        final draw = ourScore == oppoScore;
        final isBest = tm.note == bestNote && bestNote > 0;
        final resultColor = won
            ? _WorldCupColorPalette.green
            : draw
                ? Colors.white60
                : _WorldCupColorPalette.crimson;

        return AnimatedOpacity(
          opacity: _visible[i] ? 1 : 0,
          duration: const Duration(milliseconds: 280),
          child: AnimatedSlide(
            offset: _visible[i] ? Offset.zero : const Offset(0, -0.2),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBest
                    ? widget.accent.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isBest
                        ? widget.accent.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: resultColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                            child: Text(
                                won
                                    ? 'V'
                                    : draw
                                        ? 'N'
                                        : 'D',
                                style: TextStyle(
                                    color: resultColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                      ),
                      const SizedBox(width: 8),
                      if (opponent.logoPath != null)
                        CachedNetworkImage(
                            imageUrl: opponent.logoPath!,
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.shield,
                                color: Colors.white38,
                                size: 22))
                      else
                        const Icon(Icons.shield,
                            color: Colors.white38, size: 22),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(opponent.nom,
                            style: const TextStyle(
                                color: _WorldCupColorPalette.text,
                                fontWeight: FontWeight.w500,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        '$ourScore - $oppoScore',
                        style: TextStyle(
                            color: resultColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      if (tm.note != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${tm.note}/10',
                              style: TextStyle(
                                  color: widget.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      if (isBest) ...[
                        const SizedBox(width: 4),
                        const Text('⭐', style: TextStyle(fontSize: 11))
                      ],
                    ],
                  ),
                  if (tm.mvpVoted != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 34),
                        Text(
                          translate.mvpVote + ' : ',
                          style: TextStyle(
                              color: _WorldCupColorPalette.textDim,
                              fontSize: 11),
                        ),
                        if (tm.mvpVoted!.picture.isNotEmpty)
                          ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                  imageUrl: tm.mvpVoted!.picture,
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover))
                        else
                          const SizedBox.shrink(),
                        const SizedBox(width: 4),
                        Text(
                          _shortName(tm.mvpVoted!.fullName),
                          style: TextStyle(
                              color: widget.accent2,
                              fontWeight: FontWeight.w600,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                  if (tm.watchedWith != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 34),
                        _miniAvatar(tm.watchedWith!.photoUrl, 14),
                        const SizedBox(width: 4),
                        Text(
                          'Vu avec ${tm.watchedWith!.displayName}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _miniAvatar(String? photoUrl, double size) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
            imageUrl: photoUrl, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Icon(Icons.person, color: Colors.white38, size: size);
  }

  String _shortName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.length <= 1
        ? fullName
        : '${parts.first[0]}. ${parts.skip(1).join(' ')}';
  }
}
