import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/views/all_matches/recherche_view.dart';
import 'package:scorescope/widgets/all_matches/competitions_bottom_sheet.dart';
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

  @override
  void initState() {
    super.initState();
    _availableDates = _generateDatesAround(DateTime.now(), range: 7);

    _dateScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCenter());

    _loadData();
  }

  void _scrollToCenter() {
    if (!_dateScrollController.hasClients) return;

    final now = DateTime.now();
    int todayIndex = _availableDates.indexWhere(
        (d) => d.day == now.day && d.month == now.month && d.year == now.year);

    if (todayIndex != -1) {
      double screenWidth = MediaQuery.of(context).size.width;
      double offset = (todayIndex * (_dateCardWidth + 8)) -
          (screenWidth / 2) +
          (_dateCardWidth / 2) +
          16;
      _dateScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  List<DateTime> _generateDatesAround(DateTime pivot, {int range = 7}) {
    final List<DateTime> newDates = [];
    final cleanPivot = DateTime(pivot.year, pivot.month, pivot.day);
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

  void _onDateSelected(DateTime date) {
    if (DateUtils.isSameDay(_selectedDate, date)) return;
    setState(() {
      _selectedDate = date;
      _loadData();
    });
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return "Aujourd'hui";
    if (DateUtils.isSameDay(
      date,
      now.subtract(
        const Duration(days: 1),
      ),
    )) {
      return "Hier";
    }
    if (DateUtils.isSameDay(
      date,
      now.add(
        const Duration(days: 1),
      ),
    )) {
      return "Demain";
    }
    return DateFormat('EEE', 'fr_FR')
        .format(date)
        .toUpperCase()
        .replaceAll('.', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ColorPalette.background(context),
        title: Text(
          "ScoreScope",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
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

                  final favoriteTeamsIds =
                      currentUser?.equipesPrefereesId ?? [];
                  final favoriteCompetitionsIds =
                      currentUser?.competitionsPrefereesId ?? [];

                  if (allMatches.isEmpty) {
                    return Center(
                      child: Text(
                        "Aucun match ce jour-là",
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                    );
                  }

                  final followedMatches = allMatches
                      .where((m) =>
                          favoriteTeamsIds.contains(m.equipeDomicile.id) ||
                          favoriteTeamsIds.contains(m.equipeExterieur.id) ||
                          favoriteCompetitionsIds.contains(m.competition.id))
                      .toList();

                  final otherMatches = allMatches
                      .where((m) => !followedMatches.contains(m))
                      .toList();

                  followedMatches.sort((a, b) => a.date.compareTo(b.date));
                  otherMatches.sort((a, b) => a.date.compareTo(b.date));

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      if (followedMatches.isNotEmpty)
                        MatchList(
                          matches: followedMatches,
                          header: _buildSectionHeader(
                              "Favoris", Icons.star_rounded),
                          user: currentUser,
                          displayUserData: false,
                        ),
                      if (otherMatches.isNotEmpty)
                        MatchList(
                          matches: otherMatches,
                          header: _buildSectionHeader(
                            followedMatches.isEmpty
                                ? "Matchs du jour"
                                : "Autres matchs",
                            Icons.sports_soccer,
                          ),
                          user: currentUser,
                          displayUserData: false,
                        ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
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
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorPalette.surface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const CompetitionsBottomSheet(),
  );

  onSelected();
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

