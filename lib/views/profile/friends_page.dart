import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';

class FriendsPage extends StatefulWidget {
  final AppUser currentUser;
  final AppUser displayedUser;

  final List<AppUser> friends;
  final List<AppUser> receivedRequests;
  final List<AppUser> sentRequests;

  final bool isMe;

  const FriendsPage({
    super.key,
    required this.currentUser,
    required this.displayedUser,
    required this.friends,
    required this.receivedRequests,
    required this.sentRequests,
    required this.isMe,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    if (widget.isMe) {
      _tabController = TabController(length: 3, vsync: this);
    }
  }

  List<AppUser> _filter(List<AppUser> list) {
    if (searchQuery.isEmpty) return list;

    return list
        .where((user) =>
            user.displayName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMe
        ? "Mes amis"
        : "Amis de ${widget.displayedUser.displayName}";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            child: widget.isMe
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_filter(widget.friends),
                          type: FriendListType.friends),
                      _buildList(_filter(widget.receivedRequests),
                          type: FriendListType.received),
                      _buildList(_filter(widget.sentRequests),
                          type: FriendListType.sent),
                    ],
                  )
                : _buildList(_filter(widget.friends),
                    type: FriendListType.friends),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildList(List<AppUser> users, {required FriendListType type}) {
    if (users.isEmpty) {
      return const Center(child: Text("Aucun utilisateur"));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return FriendListItem(
          user: user,
          type: type,
        );
      },
    );
  }
}

enum FriendListType { friends, received, sent }

class FriendListItem extends StatelessWidget {
  final AppUser user;
  final FriendListType type;

  const FriendListItem({
    super.key,
    required this.user,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photoUrl ?? ""),
      ),
      title: Text(user.displayName),
      subtitle: Text(user.email ?? ""),
      trailing: _buildTrailing(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    switch (type) {
      case FriendListType.friends:
        return IconButton(
          icon: const Icon(Icons.person_remove),
          onPressed: () {
            // TODO remove friend
          },
        );

      case FriendListType.received:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // TODO accept
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // TODO refuse
              },
            ),
          ],
        );

      case FriendListType.sent:
        return IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            // TODO cancel request
          },
        );
    }
  }
}
