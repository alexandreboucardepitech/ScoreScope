import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/get_friendship_action_snackbar_message.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:scorescope/widgets/profile/profile_action.dart';

class FriendsPage extends StatefulWidget {
  final AppUser currentUser;
  final AppUser displayedUser;
  final bool isMe;

  const FriendsPage({
    super.key,
    required this.currentUser,
    required this.displayedUser,
    required this.isMe,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;

  List<Amitie> _friendships = [];

  List<_FriendEntry> _friends = [];
  List<_FriendEntry> _receivedRequests = [];
  List<_FriendEntry> _sentRequests = [];

  int _currentTabIndex = 0;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    if (widget.isMe) {
      _tabController = TabController(length: 3, vsync: this);
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            _currentTabIndex = _tabController.index;
          });
        }
      });
    }

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final friendships = await RepositoryProvider.amitieRepository
        .fetchFriendshipsForUser(widget.displayedUser.uid);

    _friendships = friendships;

    await _separateFriendships();

    setState(() => _isLoading = false);
  }

  Future<void> _separateFriendships() async {
    List<_FriendEntry> friends = [];
    List<_FriendEntry> received = [];
    List<_FriendEntry> sent = [];

    for (Amitie amitie in _friendships) {
      final isCurrentUserFirst = amitie.firstUserId == widget.currentUser.uid;

      final isDisplayedUserFirst =
          amitie.firstUserId == widget.displayedUser.uid;

      final otherUserId =
          isDisplayedUserFirst ? amitie.secondUserId : amitie.firstUserId;

      final user =
          await RepositoryProvider.userRepository.fetchUserById(otherUserId);

      if (user == null) continue;

      if (amitie.status == "accepted") {
        friends.add(_FriendEntry(user: user, amitie: amitie));
      } else if (amitie.status == "pending" && widget.isMe) {
        if (isCurrentUserFirst) {
          sent.add(_FriendEntry(user: user, amitie: amitie));
        } else {
          received.add(_FriendEntry(user: user, amitie: amitie));
        }
      }
    }

    _friends = friends;
    _receivedRequests = received;
    _sentRequests = sent;
  }

  List<_FriendEntry> _filter(List<_FriendEntry> list) {
    if (_searchQuery.isEmpty) return list;

    return list
        .where((entry) => entry.user.displayName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String getNbAmisLabel() {
    int count;
    String label;

    if (!widget.isMe) {
      count = _friends.length;
      label = "amis";
    } else {
      switch (_currentTabIndex) {
        case 0:
          count = _friends.length;
          label = "amis";
          break;
        case 1:
          count = _receivedRequests.length;
          label = "demandes reçues";
          break;
        case 2:
          count = _sentRequests.length;
          label = "demandes envoyées";
          break;
        default:
          count = 0;
          label = "";
      }
    }
    return "$count $label";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.isMe
                ? "Mes amis"
                : "Amis de ${widget.displayedUser.displayName}",
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: ColorPalette.buttonPrimary(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                getNbAmisLabel(),
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        bottom: widget.isMe
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Amis"),
                  Tab(text: "Reçues"),
                  Tab(text: "Envoyées"),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.isMe
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(_friends, "Aucun ami"),
                          _buildList(_receivedRequests, "Aucune demande reçue"),
                          _buildList(_sentRequests, "Aucune demande envoyée"),
                        ],
                      )
                    : _buildList(_friends, "Aucun ami"),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  void _handleFriendAction(String action, AppUser user) async {
    try {
      switch (action) {
        case 'send':
          await RepositoryProvider.amitieRepository
              .sendFriendRequest(widget.currentUser.uid, user.uid);
          break;
        case 'cancel':
          await RepositoryProvider.amitieRepository
              .removeFriend(widget.currentUser.uid, user.uid);
          break;
        case 'accept':
          await RepositoryProvider.amitieRepository
              .acceptFriendRequest(widget.currentUser.uid, user.uid);
          break;
        case 'remove':
          await RepositoryProvider.amitieRepository
              .removeFriend(widget.currentUser.uid, user.uid);
          break;
      }

      // await _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getFriendshipActionSnackbarMessage(action))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de l'action sur l'utilisateur.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadData();
        });
      }
    }
  }

  Widget _buildList(List<_FriendEntry> list, String emptyText) {
    final filtered = _filter(list);

    if (filtered.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];

        return FriendListItem(
          user: entry.user,
          amitie: entry.amitie,
          currentUser: widget.currentUser,
          isMe: widget.currentUser.uid == entry.user.uid,
          onActionRequested: _handleFriendAction,
        );
      },
    );
  }
}

class _FriendEntry {
  final AppUser user;
  final Amitie amitie;

  _FriendEntry({required this.user, required this.amitie});
}

class FriendListItem extends StatelessWidget {
  final AppUser user;
  final Amitie? amitie;
  final AppUser currentUser;
  final bool isMe;
  final void Function(String action, AppUser user)? onActionRequested;

  const FriendListItem({
    super.key,
    required this.user,
    required this.currentUser,
    required this.isMe,
    this.amitie,
    this.onActionRequested,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileView(user: user)),
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
          color: isMe
              ? ColorPalette.textAccent(context)
              : ColorPalette.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: isMe
          ? null
          : ProfileAction(
              user: user,
              amitie: amitie,
              isMe: isMe,
              currentUserId: currentUser.uid,
              onActionRequested: (action) {
                onActionRequested?.call(action, user);
              },
            ),
    );
  }
}
