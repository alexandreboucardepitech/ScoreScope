import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/utils/search/search_page_state.dart';
import 'package:scorescope/utils/search/search_query.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/recherche/barre_recherche.dart';
import 'package:scorescope/widgets/recherche/filtres_recherche.dart';
import 'package:scorescope/widgets/recherche/resultats_recherche.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class RechercheView extends StatefulWidget {
  const RechercheView({super.key});

  @override
  State<RechercheView> createState() => _RechercheViewState();
}

class _RechercheViewState extends State<RechercheView> {
  String _query = '';
  String _filter = translate.tous;
  final TextEditingController _searchController = TextEditingController();

  ResultatsRechercheModel? _cacheResults;
  ResultatsRechercheModel? _results;
  SearchPageState _pageState = SearchPageState.empty;

  bool _isSearching = false;
  String? _loadingSection;

  Timer? _debounceTimer;
  static const int _minQueryLength = 3;
  static const Duration _debounceDuration = Duration(milliseconds: 350);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    _debounceTimer?.cancel();

    if (_query.length < _minQueryLength) {
      setState(() {
        _cacheResults = null;
        _results = null;
        _pageState = SearchPageState.empty;
        _isSearching = false;
      });
      return;
    }

    final cache = searchCacheOnlyQuery(_query, filter: _filter);
    setState(() {
      _cacheResults = cache;
      _isSearching = true;
      _results = null;
      _pageState = SearchPageState.empty;
    });

    _debounceTimer = Timer(_debounceDuration, _runFullSearch);
  }

  Future<void> _runFullSearch() async {
    if (!mounted) return;
    final currentQuery = _query;
    final currentFilter = _filter;

    final (results, pageState) = await searchQuery(
      currentQuery,
      filter: currentFilter,
    );

    if (!mounted || _query != currentQuery || _filter != currentFilter) return;

    setState(() {
      _results = results;
      _pageState = pageState;
      _isSearching = false;
    });
  }

  Future<void> _loadMore(String section) async {
    if (_loadingSection != null) return;
    if (!_pageState.hasMoreForSection(section)) return;

    setState(() => _loadingSection = section);

    final currentQuery = _query;
    final currentFilter = _filter;

    final (more, newPageState) = await searchQueryLoadMore(
      query: currentQuery,
      section: section,
      currentState: _pageState,
    );

    if (!mounted || _query != currentQuery || _filter != currentFilter) return;

    setState(() {
      _results = _mergeResults(_results, more, section);
      _pageState = newPageState;
      _loadingSection = null;
    });
  }

  ResultatsRechercheModel _mergeResults(
    ResultatsRechercheModel? existing,
    ResultatsRechercheModel more,
    String section,
  ) {
    if (existing == null) return more;

    Set<String> ids(List items) =>
        items.map((e) => (e as dynamic).id as String).toSet();

    return ResultatsRechercheModel(
      user: existing.user,
      matchs: section == 'Matchs'
          ? [
              ...existing.matchs,
              ...more.matchs.where((m) => !ids(existing.matchs).contains(m.id)),
            ]
          : existing.matchs,
      equipes: section == 'Équipes'
          ? [
              ...existing.equipes,
              ...more.equipes
                  .where((e) => !ids(existing.equipes).contains(e.id)),
            ]
          : existing.equipes,
      competitions: section == 'Compétitions'
          ? [
              ...existing.competitions,
              ...more.competitions
                  .where((c) => !ids(existing.competitions).contains(c.id)),
            ]
          : existing.competitions,
      joueurs: section == 'Joueurs'
          ? [
              ...existing.joueurs,
              ...more.joueurs
                  .where((j) => !ids(existing.joueurs).contains(j.id)),
            ]
          : existing.joueurs,
    );
  }

  void _onSearchChanged(String value) {
    _query = value.trim();
    _triggerSearch();
  }

  void _onFilterChanged(String filter) {
    _filter = filter;
    _triggerSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        BarreRecherche(
          onChanged: _onSearchChanged,
          controller: _searchController,
        ),
        const SizedBox(height: 12),
        FiltresRecherche(
          selectedFilter: _filter,
          onChanged: _onFilterChanged,
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildResults()),
      ],
    );
  }

  Widget _buildResults() {
    if (_query.length < _minQueryLength) {
      return Center(
        child: Text(
          _query.isEmpty
              ? translate.commenceATaperPourRechercher
              : translate.encoreXCaractereX((_minQueryLength - _query.length).toString(), _minQueryLength - _query.length == 1 ? '' : 's'),
          style: TextStyle(color: ColorPalette.textSecondary(context)),
        ),
      );
    }

    final displayData = (_results != null && !_results!.isEmpty)
        ? _results
        : (_cacheResults != null && !_cacheResults!.isEmpty)
            ? _cacheResults
            : null;

    if (_isSearching && displayData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isSearching && displayData == null) {
      return Center(
        child: Text(
          translate.aucunResultat,
          style: TextStyle(color: ColorPalette.textPrimary(context)),
        ),
      );
    }

    final showPagination = _results != null && !_results!.isEmpty;

    return Stack(
      children: [
        if (displayData != null)
          ResultatsRecherche(
            resultats: displayData,
            pageState: showPagination ? _pageState : null,
            loadingSection: _loadingSection,
            onLoadMore: _loadMore,
          ),
        if (_isSearching)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: ColorPalette.accent(context),
            ),
          ),
      ],
    );
  }
}
