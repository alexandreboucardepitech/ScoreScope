import 'package:flutter/material.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/watch_together/friend_item.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class AddWatchFriendBottomSheet extends StatefulWidget {
  final String matchId;
  final String ownerId;
  final List<FriendItem> friends;

  const AddWatchFriendBottomSheet({
    required this.matchId,
    required this.ownerId,
    required this.friends,
  });

  @override
  State<AddWatchFriendBottomSheet> createState() =>
      AddWatchFriendBottomSheetState();
}

class AddWatchFriendBottomSheetState extends State<AddWatchFriendBottomSheet> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.friends.where((f) {
      return f.user.displayName.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Ajoute les amis avec qui tu as regardé le match",
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // 🔍 Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  style: TextStyle(color: ColorPalette.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: "Rechercher un ami...",
                    hintStyle:
                        TextStyle(color: ColorPalette.textSecondary(context)),
                    prefixIcon: Icon(Icons.search,
                        color: ColorPalette.textSecondary(context)),
                    filled: true,
                    fillColor: ColorPalette.surfaceSecondary(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => search = value);
                  },
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text("Aucun ami trouvé"),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (item.user.photoUrl != null &&
                                      item.user.photoUrl!.isNotEmpty)
                                  ? NetworkImage(item.user.photoUrl!)
                                  : null,
                              child: (item.user.photoUrl == null ||
                                      item.user.photoUrl!.isEmpty)
                                  ? Text((item.user.displayName.isNotEmpty)
                                      ? item.user.displayName[0].toUpperCase()
                                      : '?')
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  item.user.displayName,
                                  style: TextStyle(
                                      color: ColorPalette.textPrimary(context),
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                for (Equipe equipe
                                    in item.equipesPreferees) ...[
                                  buildTeamLogo(
                                    context,
                                    equipe.logoPath,
                                    clickable: false,
                                    equipeId: equipe.id,
                                    size: 28,
                                    user: item.user,
                                  ),
                                ]
                              ],
                            ),
                            trailing: item.alreadyInvited
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "En attente",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  )
                                : null,
                            enabled: !item.alreadyInvited,
                            onTap: item.alreadyInvited
                                ? null
                                : () async {
                                    await RepositoryProvider
                                        .watchTogetherRepository
                                        .createWatchTogether(
                                      matchId: widget.matchId,
                                      ownerId: widget.ownerId,
                                      friendId: item.user.uid,
                                    );

                                    Navigator.pop(context);
                                  },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
