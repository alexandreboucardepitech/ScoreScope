import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/app_cache.dart';
import 'package:scorescope/utils/string/string_helper.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/amis/comments_page.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';
import 'package:scorescope/widgets/profile/history_filters_sheet.dart';
import 'package:scorescope/utils/ui/app_logos.dart';

class HistoryEntry {
  final MatchModel match;
  final MatchUserData userData;

  const HistoryEntry({required this.match, required this.userData});
}

class AllMatchesHistoryView extends StatefulWidget {
  final AppUser user;

  const AllMatchesHistoryView({super.key, required this.user});

  @override
  State<AllMatchesHistoryView> createState() => _AllMatchesHistoryViewState();
}

class _AllMatchesHistoryViewState extends State<AllMatchesHistoryView> {
  bool _loading = true;
  bool _loadingMore = false;
  int _totalToLoad = 0;
  String? _error;

  List<HistoryEntry> _allEntries = [];
  List<HistoryEntry> _filteredEntries = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _selectedCompetitionId;
  String? _selectedEquipeId;
  bool _favorisOnly = false;

  bool get _isOwnProfile =>
      widget.user.uid == RepositoryProvider.userRepository.currentUser?.uid;

  bool get _hasActiveFilters =>
      _selectedCompetitionId != null ||
      _selectedEquipeId != null ||
      _favorisOnly;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      _allEntries = [];
      _filteredEntries = [];
    });

    try {
      List<MatchUserData> allUserData = await RepositoryProvider.userRepository
          .fetchUserAllMatchUserData(userId: widget.user.uid);
      if (!_isOwnProfile) {
        allUserData = allUserData.where((d) => !d.private).toList();
      }

      allUserData.sort((a, b) {
        final dateA = a.watchedAt ?? a.matchDate ?? DateTime(1970);
        final dateB = b.watchedAt ?? b.matchDate ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        _totalToLoad = allUserData.length;
      });

      const batchSize = 20;
      final matchRepo = RepositoryProvider.matchRepository;

      for (int start = 0; start < allUserData.length; start += batchSize) {
        final batch = allUserData.sublist(
          start,
          (start + batchSize > allUserData.length)
              ? allUserData.length
              : start + batchSize,
        );

        final batchResults = List<HistoryEntry?>.filled(batch.length, null);

        await Future.wait(batch.asMap().entries.map((entry) async {
          final index = entry.key;
          final data = entry.value;
          try {
            final match = await matchRepo.fetchMatchById(data.matchId);
            if (match != null) {
              batchResults[index] = HistoryEntry(match: match, userData: data);
            }
          } catch (_) {}
        }));

        if (!mounted) return;
        final hasMoreBatches = start + batchSize < allUserData.length;
        setState(() {
          _allEntries = [
            ..._allEntries,
            ...batchResults.whereType<HistoryEntry>(),
          ];
          _loadingMore = hasMoreBatches;
          _loading = _allEntries.isEmpty && hasMoreBatches;
        });
        _applyFilters();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _applyFilters() {
    Iterable<HistoryEntry> result = _allEntries;

    if (_favorisOnly) {
      result = result.where((e) => e.userData.favourite);
    }
    if (_selectedCompetitionId != null) {
      result =
          result.where((e) => e.match.competition.id == _selectedCompetitionId);
    }
    if (_selectedEquipeId != null) {
      result = result.where((e) =>
          e.match.equipeDomicile.id == _selectedEquipeId ||
          e.match.equipeExterieur.id == _selectedEquipeId);
    }

    final q = normalize(_searchQuery.trim().toLowerCase());
    if (q.length >= 2) {
      result = result.where((e) => _matchesSearch(e.match, q));
    }

    setState(() {
      _filteredEntries = result.toList();
    });
  }

  bool _matchesSearch(MatchModel match, String q) {
    final domicileNom = normalize(match.equipeDomicile.nom.toLowerCase());
    final domicileCourt =
        normalize((match.equipeDomicile.nomCourt ?? '').toLowerCase());
    final exterieurNom = normalize(match.equipeExterieur.nom.toLowerCase());
    final exterieurCourt =
        normalize((match.equipeExterieur.nomCourt ?? '').toLowerCase());
    final competitionNom = normalize(match.competition.nom.toLowerCase());

    if (domicileNom.contains(q) ||
        domicileCourt.contains(q) ||
        exterieurNom.contains(q) ||
        exterieurCourt.contains(q) ||
        competitionNom.contains(q)) {
      return true;
    }

    final words = q.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length < 2) return false;

    for (int i = 1; i < words.length; i++) {
      final left = words.sublist(0, i).join(' ');
      final right = words.sublist(i).join(' ');
      if (left.length < 2 || right.length < 2) continue;

      final leftIsDomicile =
          domicileNom.contains(left) || domicileCourt.contains(left);
      final rightIsExterieur =
          exterieurNom.contains(right) || exterieurCourt.contains(right);
      final leftIsExterieur =
          exterieurNom.contains(left) || exterieurCourt.contains(left);
      final rightIsDomicile =
          domicileNom.contains(right) || domicileCourt.contains(right);

      if ((leftIsDomicile && rightIsExterieur) ||
          (leftIsExterieur && rightIsDomicile)) {
        return true;
      }
    }
    return false;
  }

  List<Competition> get _availableCompetitions {
    final seen = <String, Competition>{};
    for (final e in _allEntries) {
      seen[e.match.competition.id] = e.match.competition;
    }
    final list = seen.values.toList();
    list.sort((a, b) => a.nom.compareTo(b.nom));
    return list;
  }

  List<Equipe> get _availableEquipes {
    final seen = <String, Equipe>{};
    for (final e in _allEntries) {
      seen[e.match.equipeDomicile.id] = e.match.equipeDomicile;
      seen[e.match.equipeExterieur.id] = e.match.equipeExterieur;
    }
    final list = seen.values.toList();
    list.sort((a, b) => a.nom.compareTo(b.nom));
    return list;
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<HistoryFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryFiltersSheet(
        availableCompetitions: _availableCompetitions,
        availableEquipes: _availableEquipes,
        initialCompetitionId: _selectedCompetitionId,
        initialEquipeId: _selectedEquipeId,
        initialFavorisOnly: _favorisOnly,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCompetitionId = result.competitionId;
        _selectedEquipeId = result.equipeId;
        _favorisOnly = result.favorisOnly;
      });
      _applyFilters();
    }
  }

  Future<String?> _resolveMvpName(String? mvpId) async {
    if (mvpId == null) return null;
    String? mvpName = AppCache.getJoueurName(mvpId);
    if (mvpName != null) return mvpName;
    try {
      final joueur =
          await RepositoryProvider.joueurRepository.fetchJoueurById(mvpId);
      mvpName = joueur?.fullName;
      if (mvpName != null) AppCache.setJoueurName(mvpId, mvpName);
    } catch (_) {}
    return mvpName;
  }

  Future<void> _openComments(HistoryEntry entry) async {
    final mvpName = await _resolveMvpName(entry.userData.mvpVoteId);
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommentsPage(
          entry: MatchRegardeAmi(
            friend: widget.user,
            matchData: entry.userData,
            match: entry.match,
            mvpName: mvpName,
          ),
          userCache: {widget.user.uid: widget.user},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarOpacity: 1.0,
        titleSpacing: 0,
        title: Row(
          children: [
            AppLogos.logoTransparent(context, size: 32),
            const SizedBox(width: 8),
            Text(
              _isOwnProfile
                  ? translate.mesMatchs
                  : translate.matchsDeXX(widget.user.displayName),
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list),
                if (_hasActiveFilters)
                  Positioned(
                    right: -1,
                    top: -1,
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
            onPressed:
                _availableEquipes.isEmpty && _availableCompetitions.isEmpty
                    ? null
                    : _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: translate.rechercherUnMatchUneEquipeUnJoueur,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: ColorPalette.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          '${translate.erreur}: $_error',
          style: TextStyle(color: ColorPalette.error(context)),
        ),
      );
    }

    if (_allEntries.isEmpty && !_loadingMore) {
      return Center(
        child: Text(
          translate.aucunMatchEnregistre,
          style: TextStyle(color: ColorPalette.textSecondary(context)),
        ),
      );
    }

    if (_filteredEntries.isEmpty) {
      return Center(
        child: Text(
          translate.aucunResultat,
          style: TextStyle(color: ColorPalette.textSecondary(context)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: MatchList(
        lazy: true,
        matches: _filteredEntries.map((e) => e.match).toList(),
        user: widget.user,
        displayUserData: true,
        userDataByMatchId: {
          for (final e in _filteredEntries) e.match.id: e.userData,
        },
        onMatchTap: (match) {
          final entry = _filteredEntries.firstWhere(
            (e) => e.match.id == match.id,
          );
          _openComments(entry);
        },
        footer: _loadingMore ? _buildLoadingMoreFooter(context) : null,
      ),
    );
  }

  Widget _buildLoadingMoreFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ColorPalette.accent(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_allEntries.length}/$_totalToLoad',
            style: TextStyle(
              fontSize: 12,
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
