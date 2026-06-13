import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/cloud_fonctions/fill_database.dart';
import 'package:scorescope/utils/sort/sort_matchs_competition.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/views/all_matches/recap_week_view.dart';
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

  late Future<List<MatchModel>> _futureMatches;
  late Future<AppUser?> _futureCurrentUser;

  bool _showRecapBanner = false;
  bool _recapChecked = false;

  @override
  void initState() {
    super.initState();
    _availableDates = _generateDatesAround(DateTime.now(), range: 7);

    _dateScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCenter());

    _loadData();
  }

  Future<void> _refresh() async {
    _loadData();
    setState(() {});
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
    final cleanPivot = DateTime(pivot.year, pivot.month, pivot.day,
        5); //5h du matin pour éviter les bugs au changement d'heure
    for (int i = -range; i <= range; i++) {
      newDates.add(cleanPivot.add(Duration(days: i)));
    }
    return newDates;
  }

  void _loadData() {
    setState(() {
      _futureMatches = widget.matchRepository.fetchMatchesByDate(_selectedDate);
      _futureCurrentUser = _fetchCurrentUser();
    });
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
      _loadData();
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
    String dateLanguage = 'fr_FR';
    AppUser? currentUser = RepositoryProvider.userRepository.currentUser;
    if (currentUser != null &&
        currentUser.options.language == LanguageOptions.english)
      dateLanguage = 'en_US';
    return DateFormat('EEE', dateLanguage)
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
    final fmt = DateFormat('d MMM', 'fr_FR');
    return 'Du ${fmt.format(lastMonday)} au ${fmt.format(lastSunday)}';
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
            onPressed: () => _showCompetitionsSelector(context, _loadData),
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
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  _futureMatches,
                  _futureCurrentUser,
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else {
                    final allMatches = snapshot.data![0] as List<MatchModel>;
                    final currentUser = snapshot.data![1] as AppUser?;

                    if (!_recapChecked && currentUser != null) {
                      _recapChecked = true;
                      final lastSeen = currentUser.lastRecapSeenWeek;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted)
                          setState(
                            () => _showRecapBanner = lastSeen != _recapWeekId,
                          );
                      });
                    }

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
                            SizedBox(height: 12),
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
                            ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            if (RepositoryProvider.userRepository.currentUser?.uid == "jSHnJN1cVWTsDirfm1sEaA358jJ3" ||
                RepositoryProvider.userRepository.currentUser?.uid ==
                    "UwigeExwFMfDrCk4x8AbODha3il1" ||
                RepositoryProvider.userRepository.currentUser?.uid ==
                    "Elv7ujUkfRYKfrIJsDySorXRYuh1")
              ElevatedButton(
                onPressed: () async {
                  // List<MatchModelId> allMatches = await RepositoryProvider
                  //     .matchRepository
                  //     .fetchAllMatchesId(loadVotesAndNotes: false);
                  // List<String> competitionsIdACheck = [
                  //   "10",
                  //   "137",
                  //   "143",
                  //   "2",
                  //   "3",
                  //   "45",
                  //   "48",
                  //   "526",
                  //   "528",
                  //   "529",
                  //   "547",
                  //   "556",
                  //   "66",
                  //   "81",
                  //   "848",
                  // ];
                  // int count = 0;
                  // for (MatchModelId match in allMatches) {
                  //   print("match $count / ${allMatches.length}");
                  //   if (competitionsIdACheck.contains(match.competitionId) && count >= 4750) {
                  //     print("mise à jour du match ${match.id}");
                  //     await FillDatabase.createMatchFromFixtureId(match.id,
                  //         seulementUpdateCompos: true);
                  //   }
                  //   count++;
                  // }
                  FillDatabase.manualUpdateMatchInfo(
                    "1489373",
                    stadiumName: "San Francisco Bay Area Stadium",
                    refereeName: "Héctor Saíd Martínez Sorto",
                  );
                },
                child: Text("test pour développeur"),
              ),
          ],
        ),
      ),
    );
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
                    DateFormat('MMM', 'fr_FR').format(date).toUpperCase(),
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
      ],
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
