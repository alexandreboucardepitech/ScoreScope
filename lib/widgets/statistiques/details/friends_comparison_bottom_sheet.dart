import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class FriendsComparisonBottomSheet extends StatefulWidget {
  final Map<AppUser, int> friendsMatchesCount;

  const FriendsComparisonBottomSheet(
      {super.key, required this.friendsMatchesCount});

  @override
  State<FriendsComparisonBottomSheet> createState() =>
      _FriendsComparisonBottomSheetState();
}

class _FriendsComparisonBottomSheetState
    extends State<FriendsComparisonBottomSheet> {
  late Map<AppUser, int> _filteredFriends;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFriends = Map.fromEntries(
      widget.friendsMatchesCount.entries.where((e) => e.value > 0),
    );
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = Map.fromEntries(
        widget.friendsMatchesCount.entries.where((e) =>
            e.value > 0 && e.key.displayName.toLowerCase().contains(query)),
      );
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
    return Container(
      height: size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.background(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ColorPalette.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Text(
            'Comparer avec un ami',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher…',
              hintStyle: TextStyle(color: ColorPalette.textSecondary(context)),
              prefixIcon: Icon(Icons.search,
                  color: ColorPalette.textSecondary(context)),
              filled: true,
              fillColor: ColorPalette.surfaceSecondary(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Friends list
          Expanded(
            child: _filteredFriends.isEmpty
                ? Center(
                    child: Text(
                      'Aucun ami à afficher',
                      style:
                          TextStyle(color: ColorPalette.textSecondary(context)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredFriends.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: ColorPalette.divider(context)),
                    itemBuilder: (context, index) {
                      final entry = _filteredFriends.entries.elementAt(index);
                      final user = entry.key;
                      final nbMatchs = entry.value;

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(user),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorPalette.border(context),
                                      width: 2),
                                  shape: BoxShape.circle,
                                  color: ColorPalette.border(context),
                                  image: user.photoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(user.photoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: user.photoUrl == null
                                    ? Text(
                                        user.displayName.characters.first
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color:
                                              ColorPalette.textPrimary(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ),
                              Text(
                                '$nbMatchs matchs regardés',
                                style: TextStyle(
                                  color: ColorPalette.textSecondary(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorPalette.accent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
