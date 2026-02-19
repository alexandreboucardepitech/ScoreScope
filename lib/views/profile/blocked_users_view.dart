import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:scorescope/widgets/profile/profile_action.dart';

class BlockedUsersView extends StatefulWidget {
  final AppUser currentUser;

  const BlockedUsersView({
    super.key,
    required this.currentUser,
  });

  @override
  State<BlockedUsersView> createState() => _BlockedUsersViewState();
}

class _BlockedUsersViewState extends State<BlockedUsersView> {
  bool _isLoading = true;
  String _searchQuery = "";

  List<_BlockedEntry> _blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final blockedFriendships =
        await RepositoryProvider.amitieRepository.fetchBlockedUsers(
      widget.currentUser.uid,
      'blocking',
    );

    List<_BlockedEntry> entries = [];

    for (final amitie in blockedFriendships) {
      final blockedUserId = amitie.secondUserId;

      final user =
          await RepositoryProvider.userRepository.fetchUserById(blockedUserId);

      if (user == null) continue;

      entries.add(
        _BlockedEntry(
          user: user,
          amitie: amitie,
        ),
      );
    }

    setState(() {
      _blockedUsers = entries;
      _isLoading = false;
    });
  }

  List<_BlockedEntry> _filter(List<_BlockedEntry> list) {
    if (_searchQuery.isEmpty) return list;

    return list
        .where((entry) => entry.user.displayName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _handleAction(String action, AppUser user) async {
    try {
      if (action == 'unblock') {
        await RepositoryProvider.amitieRepository
            .unblockUser(widget.currentUser.uid, user.uid);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur débloqué")),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du déblocage")),
      );
    } finally {
      if (mounted) {
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(_blockedUsers);

    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        title: Text(
          "Utilisateurs bloqués",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          "Aucun utilisateur bloqué",
                          style: TextStyle(
                            color: ColorPalette.textSecondary(context),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final entry = filtered[index];

                          return _BlockedListItem(
                            user: entry.user,
                            currentUser: widget.currentUser,
                            amitie: entry.amitie,
                            onActionRequested: _handleAction,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: ColorPalette.tileBackground(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorPalette.border(context)),
          ),
        ),
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }
}

class _BlockedEntry {
  final AppUser user;
  final Amitie amitie;

  _BlockedEntry({
    required this.user,
    required this.amitie,
  });
}

class _BlockedListItem extends StatelessWidget {
  final AppUser user;
  final AppUser currentUser;
  final Amitie amitie;
  final void Function(String action, AppUser user)? onActionRequested;

  const _BlockedListItem({
    required this.user,
    required this.currentUser,
    required this.amitie,
    this.onActionRequested,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileView(user: user)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: ColorPalette.pictureBackground(context),
        backgroundImage:
            user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null
            ? Text(
                user.displayName[0].toUpperCase(),
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      title: Text(
        user.displayName,
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: ProfileAction(
        user: user,
        amitie: amitie,
        isMe: false,
        currentUserId: currentUser.uid,
        onActionRequested: (action) {
          onActionRequested?.call(action, user);
        },
      ),
    );
  }
}
