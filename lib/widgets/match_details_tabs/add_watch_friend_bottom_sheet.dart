import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/watch_together/friend_item.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class AddWatchFriendBottomSheet extends StatefulWidget {
  final String matchId;
  final String ownerId;
  final List<FriendItem> friends;

  const AddWatchFriendBottomSheet({
    super.key,
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
                translate.ajouteLesAmisAvecQuiTuAsRegardeLeMatch,
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
                    hintText: translate.rechercherUnAmi,
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
                    ? Center(
                        child: Text(
                          translate.aucunAmiTrouve,
                          style: TextStyle(
                            color: ColorPalette.textPrimary(
                              context,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (item.user.photoUrl != null &&
                                      item.user.photoUrl!.isNotEmpty)
                                  ? CachedNetworkImageProvider(
                                      item.user.photoUrl!)
                                  : null,
                              child: (item.user.photoUrl == null ||
                                      item.user.photoUrl!.isEmpty)
                                  ? Text(
                                      (item.user.displayName.isNotEmpty)
                                          ? item.user.displayName[0]
                                              .toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: ColorPalette.textPrimary(
                                          context,
                                        ),
                                      ),
                                    )
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
                                      color: ColorPalette.warning(context),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      translate.enAttente,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            ColorPalette.textPrimary(context),
                                      ),
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

                                    await RepositoryProvider
                                        .notificationRepository
                                        .notifyNewWatchTogetherInvitation(
                                      ownerUserId: item.user.uid,
                                      matchId: widget.matchId,
                                      authorId: widget.ownerId,
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
