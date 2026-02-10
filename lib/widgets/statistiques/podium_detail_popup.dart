import 'package:flutter/material.dart';
import 'package:scorescope/models/stats/podium_entry.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';

class PodiumDetailsPopup<T extends PodiumDisplayable> extends StatefulWidget {
  final String title;
  final int watchedMatchesCount;
  final List<PodiumEntry<T>> entries;

  const PodiumDetailsPopup({
    super.key,
    required this.title,
    required this.watchedMatchesCount,
    required this.entries,
  });

  @override
  State<PodiumDetailsPopup<T>> createState() => _PodiumDetailsPopupState<T>();
}

class _PodiumDetailsPopupState<T extends PodiumDisplayable>
    extends State<PodiumDetailsPopup<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<PodiumEntry<T>> _filteredEntries;

  @override
  void initState() {
    super.initState();
    _filteredEntries = widget.entries;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = widget.entries.where((entry) {
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
            icon: Icon(
              Icons.close,
              color: ColorPalette.textSecondary(context),
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
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: _filteredEntries.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: ColorPalette.divider(context),
          ),
          itemBuilder: (context, index) {
            final entry = _filteredEntries[index];
            final rank = widget.entries.indexOf(entry) + 1;

            return _PodiumRow(
              rank: rank,
              entry: entry,
            );
          },
        ),
      ),
    );
  }
}

class _PodiumRow<T extends PodiumDisplayable> extends StatelessWidget {
  final int rank;
  final PodiumEntry<T> entry;

  const _PodiumRow({
    required this.rank,
    required this.entry,
  });

  Color _rankColor(BuildContext context) {
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

  Color _valueChipColor(BuildContext context) {
    if (entry.color != null) {
      return fromHex(entry.color!);
    }
    return ColorPalette.accent(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _rankColor(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: entry.item.buildDetailsLine(
              context: context,
              podium: PodiumContext(rank: rank, value: entry.value),
            ),
          ),
          const SizedBox(width: 8),
          if (rank <= 3)
            buildValueChip(
              context,
              entry.value,
              _valueChipColor(context),
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
      ),
    );
  }
}
