import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/date/get_date_format.dart';
import 'package:scorescope/utils/sort/sort_matchs_competition.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/views/all_matches/recap_cdm_view.dart';
import 'package:scorescope/views/all_matches/recap_week_view.dart';
import 'package:scorescope/views/all_matches/recap_season_view.dart';
import 'package:scorescope/views/all_matches/recherche_view.dart';
import 'package:scorescope/widgets/all_matches/recap_banner.dart';
import 'package:scorescope/widgets/util/competitions_bottom_sheet.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';
import '../../services/repositories/i_match_repository.dart';
import '../../models/match.dart';

class AllMatchesView extends StatefulWidget {
  final IMatchRepository matchRepository = RepositoryProvider.matchRepository;
  AllMatchesView({super.key});

  @override
  State<AllMatchesView> createState() => _AllMatchesViewState();
}

class _AllMatchesViewState extends State<AllMatchesView> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _availableDates;
  late ScrollController _dateScrollController;

  final double _dateCardWidth = 70.0;

  List<MatchModel>? _matches;
  AppUser? _currentUser;
  String? _errorMessage;

  bool _isInitialLoading = true;
  bool _isBackgroundRefreshing = false;

  bool _showRecapBanner = false;
  bool _recapChecked = false;
  bool _cdmPopupShownThisSession = false;
  bool _seasonPopupShownThisSession = false;

  static final DateTime _cdmRecapStart = DateTime(2026, 7, 19, 23, 0);
  static final DateTime _cdmRecapEnd = DateTime(2026, 8, 15);

  bool get _isCdmRecapAvailable {
    final now = DateTime.now();
    return now.isAfter(_cdmRecapStart) && now.isBefore(_cdmRecapEnd);
  }

  bool get _isSeasonRecapAvailable => DateTime.now().month == 8;

  String get _seasonRecapLabel {
    final now = DateTime.now();
    final currentSaison = now.month >= 7 ? now.year : now.year - 1;
    final saisonAnnee = currentSaison - 1;
    return '$saisonAnnee/${saisonAnnee + 1}';
  }

  @override
  void initState() {
    super.initState();
    _availableDates = _generateDatesAround(DateTime.now(), range: 7);

    _dateScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCenter());

    _loadData();
  }

  Future<void> _refresh() async {
    await _loadData(isRefresh: true);
  }

  void _scrollToCenter({bool animated = false}) {
    if (!_dateScrollController.hasClients) return;

    int todayIndex = _availableDates.indexWhere(
      (d) =>
          d.day == _selectedDate.day &&
          d.month == _selectedDate.month &&
          d.year == _selectedDate.year,
    );

    if (todayIndex != -1) {
      double screenWidth = MediaQuery.of(context).size.width;
      double offset = (todayIndex * (_dateCardWidth + 8)) -
          (screenWidth / 2) +
          (_dateCardWidth / 2) +
          16;

      if (animated) {
        _dateScrollController.animateTo(
          offset.clamp(
            0.0,
            _dateScrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _dateScrollController.jumpTo(
          offset.clamp(
            0.0,
            _dateScrollController.position.maxScrollExtent,
          ),
        );
      }
    }
  }

  List<DateTime> _generateDatesAround(DateTime pivot, {int range = 7}) {
    final List<DateTime> newDates = [];
    final cleanPivot = DateTime(
      pivot.year,
      pivot.month,
      pivot.day,
      5,
    ); //5h du matin pour éviter les bugs au changement d'heure
    for (int i = -range; i <= range; i++) {
      newDates.add(cleanPivot.add(Duration(days: i)));
    }
    return newDates;
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isBackgroundRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isInitialLoading = true;
        _matches = null;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        widget.matchRepository.fetchMatchesByDate(_selectedDate),
        _fetchCurrentUser(),
      ]);

      if (mounted) {
        setState(() {
          _matches = results[0] as List<MatchModel>;
          _currentUser = results[1] as AppUser?;
          _isInitialLoading = false;
          _isBackgroundRefreshing = false;

          if (!_recapChecked && _currentUser != null) {
            _recapChecked = true;
            final lastSeen = _currentUser!.lastRecapSeenWeek;
            _showRecapBanner = lastSeen != _recapWeekId;
          }
          if (_isCdmRecapAvailable &&
              !_cdmPopupShownThisSession &&
              _currentUser != null &&
              !(_currentUser!.cdmRecapSeen)) {
            _cdmPopupShownThisSession = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showCdmRecapPopup(
                  onClosed: _maybeShowSeasonRecapPopup,
                );
              }
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _maybeShowSeasonRecapPopup();
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInitialLoading = false;
          _isBackgroundRefreshing = false;
        });
      }
    }
  }

  Future<AppUser?> _fetchCurrentUser() async {
    AppUser? currentUser =
        await RepositoryProvider.userRepository.getCurrentUser();
    return currentUser;
  }

  bool get _isAwayFromToday {
    final today = DateTime.now();
    final diff = _selectedDate
        .difference(DateTime(today.year, today.month, today.day))
        .inDays
        .abs();
    return diff >= 7;
  }

  void _goToPreviousDay() {
    final previous = _selectedDate.subtract(const Duration(days: 1));
    _onDateSelected(previous);
  }

  void _goToNextDay() {
    final next = _selectedDate.add(const Duration(days: 1));
    _onDateSelected(next);
  }

  void _goToToday() {
    _onDateSelected(DateTime.now());
  }

  void _onDateSelected(DateTime date) {
    if (DateUtils.isSameDay(_selectedDate, date)) return;
    setState(() {
      _selectedDate = date;
      _loadData(isRefresh: false);
      _availableDates = _generateDatesAround(_selectedDate);
      _scrollToCenter(animated: true);
    });
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return translate.aujourdHui;
    if (DateUtils.isSameDay(
      date,
      now.subtract(
        const Duration(days: 1),
      ),
    )) {
      return translate.hier;
    }
    if (DateUtils.isSameDay(
      date,
      now.add(
        const Duration(days: 1),
      ),
    )) {
      return translate.demain;
    }
    return DateFormat('EEE', getDateFormat())
        .format(date)
        .toUpperCase()
        .replaceAll('.', '');
  }

  String get _recapWeekId {
    final now = DateTime.now();
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    return '${lastMonday.year}-${lastMonday.month.toString().padLeft(2, '0')}-${lastMonday.day.toString().padLeft(2, '0')}';
  }

  String get _recapDateLabel {
    final now = DateTime.now();
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    final lastSunday = lastMonday.add(const Duration(days: 6));
    final fmt = DateFormat('d MMM', getDateFormat());
    return translate.duXAuX(fmt.format(lastMonday), fmt.format(lastSunday));
  }

  Future<void> _markRecapAsSeen() async {
    AppUser? currentUser =
        await RepositoryProvider.userRepository.getCurrentUser();
    if (currentUser == null) return;
    await RepositoryProvider.userRepository
        .markRecapAsSeen(currentUser.uid, _recapWeekId);
    setState(() => _showRecapBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ColorPalette.background(context),
        title: Row(
          children: [
            AppLogos.logoAccent(context, size: 32),
            const SizedBox(width: 8),
            Text(
              "ScoreScope",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(),
                icon: Icon(Icons.insights_rounded,
                    color: ColorPalette.textPrimary(context)),
                onPressed: () {
                  _markRecapAsSeen();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecapWeekView(),
                    ),
                  );
                },
              ),
              if (_showRecapBanner)
                Positioned(
                  top: 8,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ColorPalette.accent(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.emoji_events_outlined,
              color: ColorPalette.textPrimary(context),
            ),
            onPressed: () => _showCompetitionsSelector(
                context, () => _loadData(isRefresh: true)),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: ColorPalette.textPrimary(context),
            ),
            onPressed: () => _openSearch(context),
          ),
          IconButton(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: ColorPalette.textPrimary(context),
              ),
              onPressed: () async {
                final datePicked =
                    await _openDatePicker(context, _selectedDate);
                if (datePicked != null) {
                  _onDateSelected(datePicked);
                }
              }),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _isAwayFromToday
            ? FloatingActionButton.extended(
                key: const ValueKey('today_fab'),
                onPressed: _goToToday,
                backgroundColor: ColorPalette.accent(context),
                foregroundColor: ColorPalette.opposite(context),
                icon: const Icon(Icons.today_rounded, size: 20),
                label: Text(
                  translate.aujourdHui,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            : const SizedBox.shrink(key: ValueKey('no_fab')),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          const velocityThreshold = 300.0;
          final vx = details.primaryVelocity ?? 0;
          if (vx > velocityThreshold) {
            _goToPreviousDay();
          } else if (vx < -velocityThreshold) {
            _goToNextDay();
          }
        },
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isInitialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_errorMessage != null && _matches == null) {
                    return Center(
                        child: Text(translate.erreur + ': $_errorMessage'));
                  }

                  final allMatches = _matches ?? [];
                  final currentUser = _currentUser;

                  final favoriteTeamsIds =
                      currentUser?.equipesPrefereesId ?? [];
                  final favoriteCompetitionsIds =
                      currentUser?.competitionsPrefereesId ?? [];

                  if (allMatches.isEmpty) {
                    return Center(
                      child: Text(
                        translate.aucunMatchCeJourLa,
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                    );
                  }

                  List<MatchModel> followedMatches = allMatches
                      .where((m) =>
                          favoriteTeamsIds.contains(m.equipeDomicile.id) ||
                          favoriteTeamsIds.contains(m.equipeExterieur.id) ||
                          favoriteCompetitionsIds.contains(m.competition.id))
                      .toList();

                  List<MatchModel> otherMatches = allMatches
                      .where((m) => !followedMatches.contains(m))
                      .toList();

                  followedMatches = sortMatchsCompetition(
                    matchs: followedMatches,
                    triDate: true,
                  );
                  otherMatches = sortMatchsCompetition(
                    matchs: otherMatches,
                    triDate: false,
                  );

                  return RefreshIndicator(
                    color: ColorPalette.accent(context),
                    backgroundColor: ColorPalette.background(context),
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        if (_isCdmRecapAvailable &&
                            _isSeasonRecapAvailable) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _CdmRecapBanner(
                                      compact: true,
                                      onTap: () {
                                        if (_currentUser != null &&
                                            !_currentUser!.cdmRecapSeen) {
                                          RepositoryProvider.userRepository
                                              .markCdmRecapAsSeen(
                                                  _currentUser!.uid);
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => RecapCdmView()),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SeasonRecapBanner(
                                      compact: true,
                                      seasonLabel: _seasonRecapLabel,
                                      onTap: () {
                                        _markSeasonRecapAsSeen();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  RecapSeasonView()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ] else ...[
                          if (_isCdmRecapAvailable) ...[
                            _CdmRecapBanner(
                              onTap: () {
                                if (_currentUser != null &&
                                    !_currentUser!.cdmRecapSeen) {
                                  RepositoryProvider.userRepository
                                      .markCdmRecapAsSeen(_currentUser!.uid);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RecapCdmView()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (_isSeasonRecapAvailable) ...[
                            _SeasonRecapBanner(
                              seasonLabel: _seasonRecapLabel,
                              onTap: () {
                                _markSeasonRecapAsSeen();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RecapSeasonView()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                        if (_showRecapBanner) ...[
                          RecapBanner(
                            onTap: () {
                              _markRecapAsSeen();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecapWeekView(),
                                ),
                              );
                            },
                            onDismiss: _markRecapAsSeen,
                            recapDateLabel: _recapDateLabel,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (followedMatches.isNotEmpty)
                          MatchList(
                            matches: followedMatches,
                            header: _buildSectionHeader(
                              translate.favoris,
                              Icons.star_rounded,
                            ),
                            user: currentUser,
                            displayUserData: false,
                            onRefresh: () => _loadData(isRefresh: true),
                          ),
                        if (otherMatches.isNotEmpty)
                          MatchList(
                            matches: otherMatches,
                            header: _buildSectionHeader(
                              followedMatches.isEmpty
                                  ? translate.matchsDuJour
                                  : translate.autresMatchs,
                              Icons.sports_soccer,
                            ),
                            user: currentUser,
                            displayUserData: false,
                            onRefresh: () => _loadData(isRefresh: true),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // if (RepositoryProvider.userRepository.currentUser?.uid == "jSHnJN1cVWTsDirfm1sEaA358jJ3" ||
            //     RepositoryProvider.userRepository.currentUser?.uid ==
            //         "UwigeExwFMfDrCk4x8AbODha3il1" ||
            //     RepositoryProvider.userRepository.currentUser?.uid ==
            //         "Elv7ujUkfRYKfrIJsDySorXRYuh1")
            //   ElevatedButton(
            //     onPressed: () async {
            //       await FillDatabase.updateEquipesDeTousLesJoueurs();
            //     },
            //     child: Text("test pour développeur"),
            //   ),
          ],
        ),
      ),
    );
  }

  void _showCdmRecapPopup({VoidCallback? onClosed}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => _CdmRecapDialog(
        onOpen: () {
          Navigator.of(context).pop();
          if (_currentUser != null && !_currentUser!.cdmRecapSeen) {
            RepositoryProvider.userRepository
                .markCdmRecapAsSeen(_currentUser!.uid);
            setState(() {
              _currentUser = RepositoryProvider.userRepository.currentUser;
            });
          }
          onClosed?.call();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecapCdmView()),
          );
        },
        onDismiss: () {
          Navigator.of(context).pop();
          if (_currentUser != null && !_currentUser!.cdmRecapSeen) {
            RepositoryProvider.userRepository
                .markCdmRecapAsSeen(_currentUser!.uid);
            setState(() {
              _currentUser = RepositoryProvider.userRepository.currentUser;
            });
          }
          onClosed?.call();
        },
      ),
    );
  }

  void _maybeShowSeasonRecapPopup() {
    if (!mounted) return;
    if (!_isSeasonRecapAvailable) return;
    if (_seasonPopupShownThisSession) return;
    if (_currentUser == null) return;
    if (_currentUser!.lastSeasonRecapSeen == _seasonRecapLabel) return;

    _seasonPopupShownThisSession = true;
    _showSeasonRecapPopup();
  }

  void _showSeasonRecapPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => _SeasonRecapDialog(
        seasonLabel: _seasonRecapLabel,
        onOpen: () {
          Navigator.of(context).pop();
          _markSeasonRecapAsSeen();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecapSeasonView()),
          );
        },
        onDismiss: () {
          Navigator.of(context).pop();
          _markSeasonRecapAsSeen();
        },
      ),
    );
  }

  Future<void> _markSeasonRecapAsSeen() async {
    if (_currentUser == null) return;
    if (_currentUser!.lastSeasonRecapSeen == _seasonRecapLabel) return;
    await RepositoryProvider.userRepository
        .markSeasonRecapAsSeen(_currentUser!.uid, _seasonRecapLabel);
    if (mounted) {
      setState(() {
        _currentUser = RepositoryProvider.userRepository.currentUser;
      });
    }
  }

  Widget _buildDateSelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _availableDates.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final date = _availableDates[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: _dateCardWidth,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorPalette.accent(context)
                    : ColorPalette.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDateLabel(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? ColorPalette.textPrimary(context)
                          : ColorPalette.textSecondary(context),
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? ColorPalette.textPrimary(context)
                          : ColorPalette.textPrimary(context),
                    ),
                  ),
                  Text(
                    DateFormat('MMM', getDateFormat())
                        .format(date)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? ColorPalette.textPrimary(context)
                              .withValues(alpha: 0.8)
                          : ColorPalette.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ColorPalette.accent(context),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (_isBackgroundRefreshing) ...[
          const Spacer(),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorPalette.accent(context),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _CdmRecapBanner extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;
  const _CdmRecapBanner({required this.onTap, this.compact = false});

  static const _logoUrl =
      'https://firebasestorage.googleapis.com/v0/b/scorescope-5a12b.firebasestorage.app/o/competitions%2F2026_FIFA_World_Cup.png?alt=media&token=c76f3094-2aa0-4e09-8e17-0ecbe89ab027';

  static const _gold = Color(0xFFFFD700);
  static const _yellow = Color(0xFFE8FF00);
  static const _bg1 = Color(0xFF060A14);
  static const _bg2 = Color(0xFF0D1628);
  static const _text = Color(0xFFF8F4FF);
  static const _textDim = Color(0x99F8F4FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12),
        height: compact ? 92 : 82,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_bg1, _bg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(
            top: -28,
            right: -20,
            child: IgnorePointer(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withValues(alpha: 0.09)),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 60,
            child: IgnorePointer(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _yellow.withValues(alpha: 0.06)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: _logoUrl,
                  width: compact ? 34 : 52,
                  height: compact ? 34 : 52,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) =>
                      Text('🏆', style: TextStyle(fontSize: compact ? 24 : 36)),
                ),
                SizedBox(width: compact ? 8 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: compact
                        ? [
                            ShaderMask(
                              shaderCallback: (b) =>
                                  const LinearGradient(colors: [_gold, _yellow])
                                      .createShader(b),
                              child: Text(
                                translate.coupeDuMonde,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              translate.voirMonRecapEmoji,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2),
                            ),
                          ]
                        : [
                            ShaderMask(
                              shaderCallback: (b) =>
                                  const LinearGradient(colors: [_gold, _yellow])
                                      .createShader(b),
                              child: Text(
                                translate.coupeDuMonde2026Maj,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              translate.tonRecapEstDisponible,
                              style: TextStyle(
                                  color: _text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              translate.decouvrirMonRecapEmoji,
                              style: TextStyle(
                                  color: _gold.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLogos.logoAccent(context, size: 30),
                      const SizedBox(height: 4),
                      Text(
                        'scorescope',
                        style: TextStyle(
                            color: _textDim.withValues(alpha: 0.5),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SeasonRecapBanner extends StatelessWidget {
  final VoidCallback onTap;
  final String seasonLabel;
  final bool compact;
  const _SeasonRecapBanner({
    required this.onTap,
    required this.seasonLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12),
        height: compact ? 92 : 82,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ColorPalette.accentLight, ColorPalette.accentVariantLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(
            top: -28,
            right: -20,
            child: IgnorePointer(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 34 : 52,
                  height: compact ? 34 : 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        AppLogos.logoAccent(context, size: compact ? 20 : 30),
                  ),
                ),
                SizedBox(width: compact ? 8 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: compact
                        ? [
                            Text(
                              translate.saisonX(seasonLabel),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: ColorPalette.textPrimaryDark,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              translate.voirMonRecapEmoji,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: ColorPalette.textPrimaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2),
                            ),
                          ]
                        : [
                            Text(
                              translate.recapDeSaisonX(seasonLabel),
                              style: const TextStyle(
                                  color: ColorPalette.textPrimaryDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              translate.tonRecapEstDisponible,
                              style: TextStyle(
                                  color: ColorPalette.textPrimaryDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              translate.decouvrirMonRecapEmoji,
                              style: TextStyle(
                                  color: ColorPalette.textPrimaryDark
                                      .withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _CdmRecapDialog extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onDismiss;
  const _CdmRecapDialog({required this.onOpen, required this.onDismiss});

  static const _logoUrl =
      'https://firebasestorage.googleapis.com/v0/b/scorescope-5a12b.firebasestorage.app/o/competitions%2F2026_FIFA_World_Cup.png?alt=media&token=c76f3094-2aa0-4e09-8e17-0ecbe89ab027';

  static const _gold = Color(0xFFFFD700);
  static const _yellow = Color(0xFFE8FF00);
  static const _teal = Color(0xFF00CC88);
  static const _bg1 = Color(0xFF060A14);
  static const _bg2 = Color(0xFF0D1628);
  static const _text = Color(0xFFF8F4FF);
  static const _textDim = Color(0x99F8F4FF);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 52),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_bg1, _bg2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(
            top: -60,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withValues(alpha: 0.08)),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _yellow.withValues(alpha: 0.06)),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 20,
            child: IgnorePointer(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _teal.withValues(alpha: 0.05)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CachedNetworkImage(
                    imageUrl: _logoUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        const Text('🏆', style: TextStyle(fontSize: 48)),
                  ),
                  Container(
                    width: 1.5,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: _text.withValues(alpha: 0.15),
                  ),
                  AppLogos.logoAccent(context, size: 64),
                ]),
                const SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (b) =>
                      const LinearGradient(colors: [_gold, _yellow])
                          .createShader(b),
                  child: Text(
                    translate.laCoupeDuMondeEstTerminee,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Colors.transparent,
                      _gold,
                      Colors.transparent
                    ]),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  translate.descriptionRecapCdm,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textDim,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      translate.voirMonRecap,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    translate.plusTard,
                    style: TextStyle(
                        color: _text.withValues(alpha: 0.3), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SeasonRecapDialog extends StatelessWidget {
  final String seasonLabel;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;
  const _SeasonRecapDialog({
    required this.seasonLabel,
    required this.onOpen,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 52),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ColorPalette.accentLight, ColorPalette.accentVariantLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(
            top: -60,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppLogos.logoAccent(context, size: 44),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  translate.laSaisonXEstTerminee(seasonLabel),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: ColorPalette.textPrimaryDark,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.6),
                      Colors.transparent,
                    ]),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  translate.descriptionRecapSaison,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorPalette.textPrimaryDark,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorPalette.accent(context),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      translate.voirMonRecap,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    translate.plusTard,
                    style: TextStyle(
                        color:
                            ColorPalette.textPrimaryDark.withValues(alpha: 0.6),
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

void _showCompetitionsSelector(
    BuildContext context, Function onSelected) async {
  AppUser? currentUser =
      await RepositoryProvider.userRepository.getCurrentUser();
  if (currentUser != null) {
    List<String>? competitionsSelected = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPalette.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CompetitionsBottomSheet(
        competitionsPreferees: currentUser.competitionsPrefereesId,
      ),
    );
    if (competitionsSelected != null) {
      await RepositoryProvider.competitionRepository.updateFavoriteCompetitions(
        userId: currentUser.uid,
        competitionIds: competitionsSelected,
      );
    }

    onSelected();
  }
}

void _openSearch(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: ColorPalette.background(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const RechercheView(),
  );
}

Future<DateTime?> _openDatePicker(
  BuildContext context,
  DateTime selectedDate,
) async {
  Locale locale;

  AppUser? currentUser = RepositoryProvider.userRepository.currentUser;

  if (currentUser == null || currentUser.options.language == null)
    locale = Locale('fr', 'FR');
  else {
    locale = currentUser.options.language == LanguageOptions.english
        ? Locale('en')
        : Locale('fr', 'FR');
  }

  final pickedDate = await showDatePicker(
    locale: locale,
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    helpText: translate.selectionnerUneDate,
    cancelText: translate.annuler,
    confirmText: translate.appliquer,
    builder: (context, child) {
      final baseTheme = Theme.of(context);
      return Theme(
        data: baseTheme.copyWith(
          scaffoldBackgroundColor: ColorPalette.background(context),
          dialogTheme: DialogThemeData(
            backgroundColor: ColorPalette.surface(context),
          ),
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: ColorPalette.accent(context),
            onPrimary: ColorPalette.opposite(context),
            surface: ColorPalette.surface(context),
            onSurface: ColorPalette.textPrimary(context),
            outline: ColorPalette.border(context),
          ),
          dividerColor: ColorPalette.divider(context),
          textTheme: baseTheme.textTheme.apply(
            bodyColor: ColorPalette.textPrimary(context),
            displayColor: ColorPalette.textPrimary(context),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: ColorPalette.accentVariant(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: ColorPalette.tileBackground(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ColorPalette.border(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ColorPalette.accent(context),
                width: 2,
              ),
            ),
          ),
        ),
        child:
            ClipRRect(borderRadius: BorderRadius.circular(20), child: child!),
      );
    },
  );

  return pickedDate;
}
