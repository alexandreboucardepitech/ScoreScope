import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/stats/load_one_stat_for_one_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';
import 'package:scorescope/widgets/statistiques/details/friends_comparison_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class PodiumDetailsPopup<T extends PodiumDisplayable> extends StatefulWidget {
  final String title;
  final int watchedMatchesCount;
  final List<PodiumEntry<T>> entries;
  final AppUser user;

  const PodiumDetailsPopup({
    super.key,
    required this.title,
    required this.watchedMatchesCount,
    required this.entries,
    required this.user,
  });

  @override
  State<PodiumDetailsPopup<T>> createState() => _PodiumDetailsPopupState<T>();
}

class _PodiumDetailsPopupState<T extends PodiumDisplayable>
    extends State<PodiumDetailsPopup<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<PodiumEntry<T>> _filteredEntries;
  late List<PodiumEntry<T>> _filteredComparisonEntries;

  bool _comparisonMode = false;
  AppUser? _comparisonUser;
  late List<PodiumEntry<T>> _comparisonEntries = [];

  bool _isComparisonLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredEntries = widget.entries;
    _filteredComparisonEntries = _comparisonEntries;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = widget.entries.where((entry) {
        return entry.item.toString().toLowerCase().contains(query);
      }).toList();
      _filteredComparisonEntries = _comparisonEntries.where((entry) {
        return entry.item.toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.75,
        decoration: BoxDecoration(
          color: ColorPalette.background(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorPalette.border(context),
          ),
          boxShadow: [
            BoxShadow(
              color: ColorPalette.opposite(context).withOpacity(0.1),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearch(context),
            const SizedBox(height: 12),
            Expanded(child: _buildGroupedList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Basé sur ${widget.watchedMatchesCount} matchs regardés',
                  style: TextStyle(
                    color: ColorPalette.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Comparer',
            onPressed: () async {
              if (_comparisonMode) {
                setState(() {
                  _comparisonMode = false;
                  _comparisonUser = null;
                  _isComparisonLoading = false;
                });
                return;
              }

              final AppUser? currentUser =
                  await RepositoryProvider.userRepository.getCurrentUser();
              if (currentUser == null) return;

              AppUser? targetUser;

              if (widget.user.uid == currentUser.uid) {
                Map<AppUser, int> friendsMatchesCount = {};
                List<AppUser> friends = await RepositoryProvider
                    .amitieRepository
                    .fetchFriendsForUser(currentUser.uid);
                for (AppUser friend in friends) {
                  int nbMatchsRegardes = await RepositoryProvider.userRepository
                      .getUserNbMatchsRegardes(
                    friend.uid,
                    true,
                  );
                  friendsMatchesCount[friend] = nbMatchsRegardes;
                }
                targetUser = await showModalBottomSheet<AppUser>(
                  context: context,
                  builder: (_) => FriendsComparisonBottomSheet(
                      friendsMatchesCount: friendsMatchesCount),
                );

                if (targetUser == null) return;
              } else {
                targetUser = currentUser;
              }

              setState(() {
                _comparisonMode = true;
                _comparisonUser = targetUser;
                _isComparisonLoading = true;
              });

              final comparisonEntriesLoaded = await loadOneStatForOneUser<T>(
                targetUser.uid,
                widget.title,
              );

              if (!mounted) return;

              setState(() {
                _comparisonEntries = comparisonEntriesLoaded;
                _filteredComparisonEntries = comparisonEntriesLoaded;
                _isComparisonLoading = false;
              });
            },
            icon: Container(
              decoration: BoxDecoration(
                color: _comparisonMode
                    ? ColorPalette.accent(context)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.compare_arrows,
                color: _comparisonMode
                    ? ColorPalette.textPrimary(context)
                    : ColorPalette.buttonPrimary(context),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: ColorPalette.buttonPrimary(context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher…',
          hintStyle: TextStyle(
            color: ColorPalette.textSecondary(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: ColorPalette.textSecondary(context),
          ),
          filled: true,
          fillColor: ColorPalette.surfaceSecondary(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ColorPalette.divider(context),
          ),
        ),
        child: Column(
          children: [
            if (_comparisonMode && _comparisonUser != null)
              _buildComparisonHeader(context),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: max(
                    _filteredEntries.length, _filteredComparisonEntries.length),
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: ColorPalette.divider(context),
                ),
                itemBuilder: (context, index) {
                  PodiumEntry<T>? baseEntry;
                  int? baseRank;
                  if (_filteredEntries.length > index) {
                    baseEntry = _filteredEntries[index];
                    baseRank =
                        widget.entries.indexOf(_filteredEntries[index]) + 1;
                  }

                  int? comparisonRank;
                  PodiumEntry<T>? comparisonEntry;
                  if (_isComparisonLoading == false &&
                      _comparisonMode &&
                      _filteredComparisonEntries.length > index) {
                    comparisonEntry = _filteredComparisonEntries[index];
                    comparisonRank = _comparisonEntries
                            .indexOf(_filteredComparisonEntries[index]) +
                        1;
                  }

                  return _PodiumRow(
                    baseRank: baseRank,
                    comparisonRank: comparisonRank,
                    baseEntry: baseEntry,
                    comparisonEntry: comparisonEntry,
                    comparisonMode: _comparisonMode,
                    shimmer: _isComparisonLoading,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonHeader(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceSecondary(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          border: Border(
            bottom: BorderSide(
              color: ColorPalette.divider(context),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorPalette.border(context),
                  width: 2,
                ),
                shape: BoxShape.circle,
                color: ColorPalette.border(context),
                image: widget.user.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.user.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: widget.user.photoUrl == null
                  ? Text(
                      widget.user.displayName.characters.first.toUpperCase(),
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.user.displayName,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 1,
              color: ColorPalette.divider(context),
            ),
            SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorPalette.border(context),
                  width: 2,
                ),
                shape: BoxShape.circle,
                color: ColorPalette.border(context),
                image: _comparisonUser!.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_comparisonUser!.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: _comparisonUser!.photoUrl == null
                  ? Text(
                      _comparisonUser!.displayName.characters.first
                          .toUpperCase(),
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _comparisonUser!.displayName,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumRow<T extends PodiumDisplayable> extends StatelessWidget {
  final int? baseRank;
  final int? comparisonRank;
  final PodiumEntry<T>? baseEntry;
  final PodiumEntry<T>? comparisonEntry;
  final bool comparisonMode;
  final bool shimmer;

  const _PodiumRow({
    this.baseRank,
    this.comparisonRank,
    required this.baseEntry,
    this.comparisonEntry,
    required this.comparisonMode,
    this.shimmer = false,
  });

  Color _rankColor(BuildContext context, int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return ColorPalette.textAccent(context);
    }
  }

  Color _valueChipColor(BuildContext context, PodiumEntry<T> entry) {
    if (entry.color != null) {
      return fromHex(entry.color!);
    }
    return ColorPalette.accent(context);
  }

  Widget _buildSingleSide({
    required BuildContext context,
    required int rank,
    PodiumEntry<T>? entry,
    bool large = true,
    bool shimmer = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _rankColor(context, rank),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (shimmer) ...[
            Expanded(
              child: Shimmer.fromColors(
                baseColor: ColorPalette.shimmerSecondary(context),
                highlightColor: ColorPalette.shimmerTertiary(context),
                child: Container(
                  height: 16,
                  width: 36,
                  decoration: BoxDecoration(
                    color: ColorPalette.surface(context),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(10, 10),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (entry != null) ...[
            Expanded(
              child: entry.item.buildDetailsLine(
                context: context,
                podium: PodiumContext(rank: rank, value: entry.value),
                large: large,
              ),
            ),
          ] else ...[
            Expanded(child: SizedBox()),
          ],
          const SizedBox(width: 8),
          if (shimmer) ...[
            Shimmer.fromColors(
              baseColor: ColorPalette.shimmerSecondary(context),
              highlightColor: ColorPalette.shimmerTertiary(context),
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: ColorPalette.accent(context),
                  borderRadius: BorderRadius.all(
                    Radius.circular(32),
                  ),
                ),
              ),
            ),
          ] else if (entry != null) ...[
            if (rank <= 3)
              buildValueChip(
                context,
                entry.value,
                _valueChipColor(context, entry),
                large: true,
              )
            else ...[
              Text(
                entry.value.toString(),
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: comparisonMode
          ? IntrinsicHeight(
              child: Row(
                children: [
                  if (baseEntry != null) ...[
                    Expanded(
                      child: _buildSingleSide(
                        context: context,
                        entry: baseEntry,
                        large: false,
                        rank: baseRank!,
                      ),
                    ),
                  ] else
                    Expanded(child: SizedBox()),
                  Container(
                    width: 1,
                    color: ColorPalette.divider(context),
                  ),
                  if (comparisonEntry != null) ...[
                    Expanded(
                      child: _buildSingleSide(
                        context: context,
                        entry: comparisonEntry,
                        large: false,
                        rank: comparisonRank!,
                      ),
                    ),
                  ] else if (shimmer) ...[
                    Expanded(
                      child: _buildSingleSide(
                        context: context,
                        large: false,
                        shimmer: true,
                        rank: baseRank!,
                      ),
                    ),
                  ] else
                    Expanded(child: SizedBox()),
                ],
              ),
            )
          : _buildSingleSide(
              context: context,
              entry: baseEntry,
              rank: baseRank!,
            ),
    );
  }
}
