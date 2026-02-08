import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/statistiques/loader/stats_loader_widget.dart';

class StatsView extends StatefulWidget {
  final AppUser user;

  const StatsView({super.key, required this.user});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool _showCards = true;
  bool _onlyPublicMatches = false;
  DateTimeRange? _dateRange;
  int? _saison; // exemple : 2025 pour la saison 2025/2026
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (mounted) setState(() => _currentUser = user);
    } catch (e) {
      // Si échec, laisse _currentUser null — on n'interrompt pas l'UI.
      if (mounted) setState(() => _currentUser = null);
    }
  }

  void _toggleView() {
    setState(() {
      _showCards = !_showCards;
    });
  }

  bool isCurrentUser() {
    if (_currentUser == null) {
      _loadCurrentUser();
      return true;
    } else if (widget.user.uid != _currentUser!.uid) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> _pickPeriodOrSeason() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Filtrer par période'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'range'),
              child: const Text('Période personnalisée'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'season'),
              child: const Text('Saison'),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    if (choice == 'range') {
      final pickedDateRange = await showDateRangePicker(
        initialDateRange: _dateRange,
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: 'Sélectionner une période',
        cancelText: 'Annuler',
        confirmText: 'Appliquer',
        saveText: 'Appliquer',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20), child: child!),
          );
        },
      );

      if (pickedDateRange != null) {
        setState(() {
          _dateRange = pickedDateRange;
          _saison = null;
        });
      }
    }

    if (choice == 'season') {
      List<int> saisons = [];
      List<MatchUserData> userMatches =
          await RepositoryProvider.userRepository.fetchUserAllMatchUserData(
        userId: widget.user.uid,
        onlyPublic: isCurrentUser() ? _onlyPublicMatches : true,
      );

      for (MatchUserData match in userMatches) {
        final matchDate = match.matchDate;
        if (matchDate != null) {
          final saison =
              matchDate.month >= 8 ? matchDate.year : matchDate.year - 1;
          if (!saisons.contains(saison)) {
            saisons.add(saison);
          }
        }
      }
      final pickedYear = await showDialog<int>(
        context: context,
        builder: (context) {
          int? selectedYear;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                constraints: const BoxConstraints(maxHeight: 400),
                alignment: Alignment.center,
                title: Text(
                  'Sélectionner la saison',
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
                content: SizedBox(
                  height: saisons.length > 4 ? 300 : null,
                  width: double.maxFinite,
                  child: saisons.length > 4
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              for (final saison in saisons)
                                RadioListTile<int>(
                                  value: saison,
                                  groupValue: selectedYear,
                                  activeColor: ColorPalette.accent(context),
                                  title: Text("Saison $saison/${saison + 1}"),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedYear = value;
                                    });
                                  },
                                ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final saison in saisons)
                              RadioListTile<int>(
                                value: saison,
                                groupValue: selectedYear,
                                activeColor: ColorPalette.accent(context),
                                title: Text("Saison $saison/${saison + 1}"),
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedYear = value;
                                  });
                                },
                              ),
                          ],
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedYear == null
                          ? ColorPalette.buttonDisabled(context)
                          : ColorPalette.buttonPrimary(context),
                    ),
                    onPressed: selectedYear == null
                        ? null
                        : () => Navigator.pop(context, selectedYear),
                    child: Text(
                      'Appliquer',
                      style: TextStyle(
                        color: selectedYear == null
                            ? ColorPalette.textSecondary(context)
                                .withValues(alpha: 0.8)
                            : ColorPalette.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (pickedYear != null) {
        setState(() {
          _saison = pickedYear;
          _dateRange = DateTimeRange(
            start: DateTime(pickedYear, 8, 1),
            end: DateTime(pickedYear + 1, 8, 1),
          );
        });
      }
    }
  }

  void _resetPeriod() {
    setState(() {
      _dateRange = null;
      _saison = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: ColorPalette.background(context),
        appBar: AppBar(
          backgroundColor: ColorPalette.tileBackground(context),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isCurrentUser()
                  ? 'Mes statistiques'
                  : 'Statistiques de ${widget.user.displayName}',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
          actions: [
            IconButton(
              tooltip: 'Filtrer par date',
              splashRadius: 22,
              icon: Icon(
                Icons.calendar_today_outlined,
                color: ColorPalette.textPrimary(context),
              ),
              onPressed: _pickPeriodOrSeason,
            ),
            IconButton(
              icon: Icon(_showCards ? Icons.view_module : Icons.view_list),
              onPressed: _toggleView,
              tooltip: _showCards ? 'Afficher en liste' : 'Afficher en cards',
            ),
            if (isCurrentUser())
              PopupMenuButton(
                icon: Icon(Icons.more_vert,
                    color: ColorPalette.opposite(context)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, setStateMenu) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Matchs publics uniquement',
                            style: TextStyle(
                                color: ColorPalette.textPrimary(context)),
                          ),
                          value: _onlyPublicMatches,
                          onChanged: (value) {
                            setState(() {
                              _onlyPublicMatches = value ?? false;
                            });
                            setStateMenu(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            if (_dateRange != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorPalette.surfaceSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _saison != null
                              ? 'Saison : $_saison / ${_saison! + 1}'
                              : 'Période : ${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} → '
                                  '${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _resetPeriod,
                        child: Icon(Icons.close,
                            color: ColorPalette.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
              ),
            // les onglets
            TabBar(
              isScrollable: true,
              indicatorColor: ColorPalette.accent(context),
              indicatorWeight: 3,
              labelColor: ColorPalette.accent(context),
              unselectedLabelColor: ColorPalette.textPrimary(context),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Global'),
                Tab(text: 'Matchs'),
                Tab(text: 'Équipes'),
                Tab(text: 'Joueurs'),
                Tab(text: 'Compétitions'),
                Tab(text: 'Habitudes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StatsLoaderWidget(
                    showCards: _showCards,
                    onlyPublicMatches:
                        isCurrentUser() ? _onlyPublicMatches : true,
                    dateRange: _dateRange,
                    onglet: StatsOnglet.generales,
                    user: widget.user,
                  ),
                  StatsLoaderWidget(
                    showCards: _showCards,
                    onlyPublicMatches:
                        isCurrentUser() ? _onlyPublicMatches : true,
                    dateRange: _dateRange,
                    onglet: StatsOnglet.matchs,
                    user: widget.user,
                  ),
                  StatsLoaderWidget(
                    showCards: _showCards,
                    onlyPublicMatches:
                        isCurrentUser() ? _onlyPublicMatches : true,
                    dateRange: _dateRange,
                    onglet: StatsOnglet.equipes,
                    user: widget.user,
                  ),
                  StatsLoaderWidget(
                    showCards: _showCards,
                    onlyPublicMatches:
                        isCurrentUser() ? _onlyPublicMatches : true,
                    dateRange: _dateRange,
                    onglet: StatsOnglet.joueurs,
                    user: widget.user,
                  ),
                  StatsLoaderWidget(
                    showCards: _showCards,
                    onlyPublicMatches:
                        isCurrentUser() ? _onlyPublicMatches : true,
                    dateRange: _dateRange,
                    onglet: StatsOnglet.competitions,
                    user: widget.user,
                  ),
                  StatsLoaderWidget(
                    showCards: _showCards,
                    onlyPublicMatches:
                        isCurrentUser() ? _onlyPublicMatches : true,
                    dateRange: _dateRange,
                    onglet: StatsOnglet.habitudes,
                    user: widget.user,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
